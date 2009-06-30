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


package Jaiku::Mock::Backend;

use fields qw(calls returns);
use strict;
use warnings;

sub new {
  my Jaiku::Mock::Backend $self = shift;
  $self = fields::new($self) unless ref $self;
  return $self;
}

# Backend methods
sub get_contacts {
  my ($self, $nick, $anchor, $cb) = @_;
  if (!defined($anchor)) {
    $anchor = "";
  }
  $self->{calls}->{get_contacts}++;
  $cb->(@{delete $self->{returns}->{get_contacts}->{$nick}->{$anchor} ||
        [ [], "0000", undef]});
}

sub get_presence {
  my ($self, $nick, $anchor, $cb) = @_;
  if (!defined($anchor)) {
    $anchor = "";
  }
  $self->{calls}->{get_presence}++;
  $cb->(@{delete $self->{returns}->{get_presence}->{$nick}->{$anchor} ||
        [ [], "0000", undef]});
}

# Introspection methods

sub number_of_calls {
  my ($self, $sub_name) = @_;
  return $self->{calls}->{$sub_name};
}

# Return value injection

sub set_return {
  my ($self, $sub_name, $nick, $anchor, $value) = @_;
  $self->{returns}->{$sub_name}->{$nick}->{$anchor} = $value;
}

1;
