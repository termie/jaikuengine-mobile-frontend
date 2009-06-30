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
# A PullItem encapsulates data pulled from the backend.
#
# Each pullitem has a timestamp and a payload as well as unique
# identifier. The unique identifier can be either a uuid (for
# repeated items like posts) or a hash of the data. The hash may
# either be given or calculated from the payload.
#
# If there is no uuid and no hash, the payload must implement
# a function called hash that returns one.
#
# The unique identifier must be exactly 16 bytes.
#
# The payload should be a Jaiku::BBData::Tuple object, although
# this class doesn't care.
#
package Jaiku::PullItem;

use fields qw(timestamp uuid_or_hash payload);
use strict;
use warnings;

sub new {
  my Jaiku::PullItem $self;
  my %opts;
  ($self, %opts) = @_;
  $self = fields::new($self) unless ref $self;
  $self->{timestamp} = delete $opts{timestamp} || die "no timestamp";
  $self->{payload} = delete $opts{payload} || die "no payload";
  my $uuid_or_hash = delete $opts{uuid};
  $uuid_or_hash = delete $opts{hash} unless($uuid_or_hash);
  $uuid_or_hash = $self->{payload}->hash() unless($uuid_or_hash);
  $uuid_or_hash = _dehex_if_appropriate($uuid_or_hash);
  die "must give a uuid or a hash" if (!defined($uuid_or_hash));
  if (length($uuid_or_hash) != 16) {
    die "uuid or hash must be exactly 16 bytes, was '$uuid_or_hash', len: " .
        length($uuid_or_hash);
  }
  $self->{uuid_or_hash} = $uuid_or_hash;

  return $self;
}

sub timestamp {
  my ($self) = @_;
  return $self->{timestamp};
}

sub payload {
  my ($self) = @_;
  return $self->{payload};
}

sub uniqueid {
  my ($self) = @_;
  return $self->{uuid_or_hash};
}

sub _dehex_if_appropriate {
  my ($string) = @_;
  if (length($string) == 32 &&
      $string =~ /[0-9a-f]*/i) {
    $string =~ s/([0-9a-fA-F]{2})/pack('H2', $1)/gei;
  }
  return $string;
}

1;
