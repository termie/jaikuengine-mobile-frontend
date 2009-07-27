# Copyright (c) 2007-2009 Google Inc.
# Copyright (c) 2006-2007 Jaiku Ltd.
# Copyright (c) 2002-2006 Mika Raento and Renaud Petit
#
# This software is licensed at your choice under either 1 or 2 below.
#
# 1. Perl (Artistic) License
#
# This library is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# 2. Gnu General Public license 2.0
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#
# This file is part of the JaikuEngine mobile frontend.
package Jaiku::Storage::API;

#
# A storage module for DJabberd-Jaiku-MessageQueue that stores anchors
# via the Jaiku API.

package Jaiku::Storage::API;

use fields qw(api pending_anchor_puts);
use strict;
use warnings;
use MIME::Base64;
use Storable qw(freeze thaw);

our $g_put_interval = 5;  # s

sub new {
  my Jaiku::Storage::API $self = shift;
  my ($api) = @_;
  $self = fields::new($self) unless ref $self;
  $self->{api} = $api;
  return $self;
}

sub _anchor_key {
  my ($id, $anchor) = @_;
  my $key =  'djabberd/' . $id . '/anchors/';
  if ($anchor) {
    $key .= $anchor;
  }
  return $key;
}

sub _uuids_key {
  my ($id) = @_;
  my $key =  'djabberd/' . $id . '/pending_uuids';
  return $key;
}

sub _acked_uuids_key {
  my ($id) = @_;
  my $key =  'djabberd/' . $id . '/acked_uuids';
  return $key;
}

# Storage methods

# Gets the anchors for the given client id.
# Calls the callback with a hash reference containing
# { anchor_type => anchor }
sub get_anchors {
  my ($self, $nick, $id, $cb) = @_;
  my $api = $self->{api};
  my $prefix = _anchor_key($id);
  my $prefix_len = length($prefix);
  my $handler = sub {
    my ($parsed, $error) = @_;
    if (!$parsed || $parsed->{status} ne 'ok') {
      $cb->(undef, $error);
      return;
    }
    my $ret = {};
    foreach my $keyvalue (@{$parsed->{rv}->{keyvalues}}) {
      my $keyname = $keyvalue->{keyname};
      $keyname = substr($keyname, $prefix_len);
      $ret->{$keyname} = $keyvalue->{value};
    }
    $cb->($ret, undef);
  };
  $api->keyvalue_prefix_list(callback => $handler,
                             nick => $nick,
                             keyname => $prefix);
}

sub _make_put_handler {
  my ($cb) = @_;
  die "must have callback" unless($cb);
  my $handler = sub {
    my ($parsed, $error) = @_;
    if (!$parsed || $parsed->{status} ne 'ok') {
      $cb->(undef, $error);
    } else {
      $cb->(1, undef);
    }
  };
  return $handler;
}

sub set_anchor {
  # We don't want to write to appengine too often, so instead of writing
  # directly we kick off a timer and write at most every 5 seconds.
  # Whichever way we do it the writes may of course get ordered the wrong way
  # due to network latency - this will just mean at most sending some data
  # twice to the client.
  # ('Whicever' modulo adding a version tag to the writes)
  my ($self, $nick, $id, $anchor, $value, $cb) = @_;
  die "must have callback" unless($cb);
  my $api = $self->{api};
  my $pending = $self->{pending_anchor_puts}->{$nick}->{$id}->{$anchor};
  if ($pending) {
    $pending->{value} = $value;
    $cb->(1, undef);
    return;
  }
  my $handler = _make_put_handler($cb);
  $pending = { value => $value };
  $self->{pending_anchor_puts}->{$nick}->{$id}->{$anchor} = $pending;
  my $timer = Danga::Socket->AddTimer($g_put_interval, sub {
    print STDERR "STORING ANCHORS" . $pending->{value} . "\n";
    delete $self->{pending_anchor_puts}->{$nick}->{$id}->{$anchor};
    $api->keyvalue_put(callback => $handler,
                       nick => $nick,
                       keyname => _anchor_key($id, $anchor),
                       value => $pending->{value})
  });
}

sub _make_uuids_handler {
  my ($cb) = @_;
  die "must have callback" unless($cb);
  my $handler = sub {
    my ($parsed, $error) = @_;
    if (!$parsed || $parsed->{status} ne 'ok') {
      $cb->(undef, $error);
      return;
    }
    my $value = $parsed->{rv}->{value};
    eval {
      $value = thaw(decode_base64($value));
      $cb->($value, undef);
    };
    if ($@) {
      $cb->(undef, $@);
    }
  };
  return $handler;
}

sub get_seen_uuids {
  my ($self, $nick, $id, $cb) = @_;
  my $api = $self->{api};
  my $handler = _make_uuids_handler($cb);
  $api->keyvalue_get(callback => $handler,
                     nick => $nick,
                     keyname => _uuids_key($id));
}

sub set_seen_uuids {
  my ($self, $nick, $id, $uuids, $cb) = @_;
  my $api = $self->{api};
  my $value = encode_base64(freeze($uuids), '');
  my $handler = _make_put_handler($cb);
  $api->keyvalue_put(callback => $handler,
                     nick => $nick,
                     keyname => _uuids_key($id),
                     value => $value);
}

sub get_acked_uuids {
  my ($self, $nick, $id, $cb) = @_;
  my $api = $self->{api};
  my $handler = _make_uuids_handler($cb);
  $api->keyvalue_get(callback => $handler,
                     nick => $nick,
                     keyname => _acked_uuids_key($id));
}

sub set_acked_uuids {
  my ($self, $nick, $id, $uuids, $cb) = @_;
  my $api = $self->{api};
  my $value = encode_base64(freeze($uuids), '');
  my $handler = _make_put_handler($cb);
  $api->keyvalue_put(callback => $handler,
                     nick => $nick,
                     keyname => _acked_uuids_key($id),
                     value => $value);
}

sub disconnected() {
  my ($self, $nick, $id) = @_;
  delete $self->{pending_anchor_puts}->{$nick}->{$id};
}

1;
