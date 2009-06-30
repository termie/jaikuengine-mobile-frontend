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


package Jaiku::Mock::Storage;

use fields qw(id string_ids anchors calls);
use strict;
use warnings;

sub new {
  my Jaiku::Mock::Storage $self = shift;
  $self = fields::new($self) unless ref $self;
  return $self;
}

# Storage methods

# Gets the anchors for the given nick and client id.
# Calls the callback with a hash reference containing
# { anchor_type => anchor }
sub get_anchors {
  my ($self, $nick, $id, $cb) = @_;
  $self->{calls}->{get_anchors}++;
  $cb->($self->{anchors}->{$nick}->{$id} || { });
}

sub get_seen_uuids {
  my ($self, $nick, $id, $cb) = @_;
  $self->{calls}->{get_seen_uuids}++;
  $cb->({ });
}

sub set_anchor {
  my ($self, $nick, $id, $anchortype, $anchor) = @_;
  $self->{anchors}->{$nick}->{$id}->{$anchortype} = $anchor;
  $self->{calls}->{set_anchor}++;
}

# Introspection functions
sub number_of_calls {
  my ($self, $sub_name) = @_;
  return $self->{calls}->{$sub_name};
}

sub anchor {
  my ($self, $nick, $id, $anchortype) = @_;
  return $self->{anchors}->{$nick}->{$id}->{$anchortype};
}

1;
