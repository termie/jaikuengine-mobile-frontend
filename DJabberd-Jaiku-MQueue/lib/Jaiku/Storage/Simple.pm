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
package Jaiku::Storage::Simple;


package Jaiku::Storage::Simple;

use fields qw(anchors uuids acked);
use strict;
use Storable qw(freeze thaw);
use warnings;

my $filename = "/home/mikie/tmp/simplestorage";

sub new {
  my Jaiku::Storage::Simple $self = shift;
  $self = fields::new($self) unless ref $self;
  $self->read();
  return $self;
}

sub _readfile {
  my ($filename) = @_;
  open(INPUT, "<$filename") || return undef;
  binmode(INPUT);
  my $data;
  my $buffer;
  while (read(INPUT, $buffer, 128 * 1024)) {
    $data .= $buffer;
  }
  close(INPUT);
  return $data;
}

sub read {
  my ($self) = @_;
  my $data = _readfile($filename);
  if ($data) {
    my $read = thaw($data);
    $self->{anchors} = $read->{anchors};
    $self->{uuids} = $read->{uuids};
    $self->{acked} = $read->{acked};
  }
}

sub write {
  my ($self) = @_;
  if (!open(OUTPUT, ">$filename")) {
    die "cannot open $filename for writing";
    return;
  }
  my $data = { anchors => $self->{anchors}, uuids => $self->{uuids},
               acked => $self->{acked} };
  print OUTPUT freeze($data);
  close(OUTPUT);
}

# Storage methods

# Gets the anchors for the given client id.
# Calls the callback with a hash reference containing
# { anchor_type => anchor }
sub get_anchors {
  my ($self, $nick, $device_id, $cb) = @_;
  $cb->($self->{anchors}->{$nick}->{$device_id});
}

sub set_anchor {
  my ($self, $nick, $device_id, $anchor, $value, $cb) = @_;
  $self->{anchors}->{$nick}->{$device_id}->{$anchor} = $value;
  $self->write();
  $cb->(1);
}

sub get_seen_uuids {
  my ($self, $nick, $device_id, $cb) = @_;
  $cb->($self->{uuids}->{$nick}->{$device_id});
}

sub set_seen_uuids {
  my ($self, $nick, $device_id, $uuids, $cb) = @_;
  $self->{uuids}->{$nick}->{$device_id} = $uuids;
  $self->write();
  $cb->(1);
}

sub get_acked_uuids {
  my ($self, $nick, $device_id, $cb) = @_;
  $cb->($self->{acked}->{$nick}->{$device_id});
}

sub set_acked_uuids {
  my ($self, $nick, $device_id, $uuids, $cb) = @_;
  $self->{acked}->{$nick}->{$device_id} = $uuids;
  $self->write();
  $cb->(1);
}

sub disconnected() {
  my ($self, $id) = @_;
  #delete $self->{anchors}->{$id};
  #delete $self->{uuids}->{$id};
}

1;
