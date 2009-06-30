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

#
# DJabberd authentication module that authenticates the user against the Jaiku
# API.
#
# Although this authentication module looks like it deals with plaintext
# passwords, Jaiku actually stores an SHA1 hash of the password and that's what
# we'll be checking against. The Jaiku mobile client for which this package is
# written sends us the SHA1 of what the user types in.

package DJabberd::Jaiku::Authen;
use strict;
use base 'DJabberd::Authen';
use Data::Dumper;
use DJabberd::Jaiku::API;
use Jaiku::API;

sub can_register_jids { 0 }
sub can_unregister_jids { 0 }
sub can_retrieve_cleartext { 0 }
sub can_check_digest { 1 }

sub check_digest {
  my ($self, $cb, %args) = @_;
  my $user = $args{username};
  my $digest = $args{'digest'};
  my $resource = $args{'resource'};
  my $conn = $args{'conn'};
  my $nonce = $conn->{stream_id};
  die "must have $nonce" unless($nonce);
  print STDERR "NONCE $nonce DIGEST $digest USER $user\n";
  my $api = DJabberd::Jaiku::API->get($conn->vhost());

  my $handler = sub {
    my ($parsed, $error) = @_;
    print STDERR Dumper($parsed);
    print STDERR Dumper($error);
    if (!$parsed || $parsed->{status} ne 'ok') {
      print STDERR "REJECTING ERR\n";
      return $cb->reject($error);
    }
    if ($parsed->{rv}) {
      print STDERR "ACCEPTING\n";
      return $cb->accept($parsed->{rv});
    } else {
      print STDERR "REJECTING BAD\n";
      return $cb->reject();
    }
  };
  $api->user_authenticate(
    nick => $user,
    nonce => $nonce,
    digest => $digest,
    callback => $handler);
}

1;
