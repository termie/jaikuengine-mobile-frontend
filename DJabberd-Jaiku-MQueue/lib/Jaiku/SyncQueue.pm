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
# A SyncQueue keeps track of anchors based on items to be sent and
# items acked/discarded.
# The anchor is the upper limit of timestamps the client has acked.

use strict;
use warnings;

package Jaiku::SyncQueue;

use fields qw(queued by_timestamp no_items_at anchor queued_count);
use Heap::Fibonacci;

sub new {
  my Jaiku::SyncQueue $self;
  my %opts;
  ($self, %opts) = @_;
  $self = fields::new($self) unless ref $self;
  $self->{anchor} = { };
  $self->{queued} = { };
  $self->{queued_count} = 0;

  return $self;
}

# Indicate that there is a new item queued to be sent. Returns undef if that
# doesn't change the anchor, or the new anchor.
sub queue {
  my ($self, $anchortype, $id, $timestamp) = @_;
  die "must provide a anchor" unless(defined($anchortype));
  die "must provide a timestamp" unless(defined($timestamp));
  $self->{queued_count}++;
  $self->{by_timestamp}->{$anchortype} ||= Heap::Fibonacci->new();
  my $min_elem = $self->{by_timestamp}->{$anchortype}->top();
  my $elem = Jaiku::SyncQueue::Elem->new(timestamp => $timestamp,
                                         anchor => $anchortype);
  die "could not create element" unless($elem);
  $self->{by_timestamp}->{$anchortype}->add($elem);
  $self->{queued}->{$id} = $elem;
  if (!$self->{anchor}->{$anchortype} ||
      !$min_elem ||
      $timestamp lt $self->{anchor}->{$anchortype}) {
    $self->{anchor}->{$anchortype} = $timestamp;
    return $timestamp;
  }
  return undef;
}

# Indicate that an item has been sent (or discarded). Returns undef if that
# doesn't change the anchor, or the new anchor.
sub dequeue {
  my ($self, $id) = @_;
  return if (!defined($id));
  my $elem = delete $self->{queued}->{$id};
  if (!defined($elem)) {
    die "$id not queueud";
  }
  return undef unless($elem);
  $self->{queued_count}--;
  my $anchortype = $elem->anchortype();
  $self->{by_timestamp}->{$anchortype}->delete($elem);
  my $min_elem = $self->{by_timestamp}->{$anchortype}->top();
  if ($elem->timestamp() eq $self->{anchor}->{$anchortype} || !$min_elem) {
    if ($min_elem) {
      return undef if ($self->{anchor}->{$anchortype} eq
                       $min_elem->timestamp());
      $self->{anchor}->{$anchortype} = $min_elem->timestamp();
    } elsif ($self->{no_items_at}->{$anchortype} &&
             $self->{no_items_at}->{$anchortype} gt $elem->timestamp()) {
      $self->{anchor}->{$anchortype} = $self->{no_items_at}->{$anchortype};
    } else {
      return undef;
    }
    return $self->{anchor}->{$anchortype};
  }
  return undef;
}

# Return the current anchor.
sub anchor {
  my ($self, $anchortype) = @_;
  return $self->{anchor}->{$anchortype};
}

# Indicate that at the given timestamp there are no items to be sent. Returns
# undef if that doesn't change the anchor, or the new anchor.
sub no_items_at {
  my ($self, $anchortype, $timestamp) = @_;
  $self->{no_items_at}->{$anchortype} = $timestamp;
  $self->{by_timestamp}->{$anchortype} ||= Heap::Fibonacci->new();
  return undef if ($self->{by_timestamp}->{$anchortype}->top());
  return undef if ($self->{anchor}->{$anchortype} &&
                   $self->{anchor}->{$anchortype} gt $timestamp);
  $self->{anchor}->{$anchortype} = $timestamp;
  return $timestamp;
}

# Set the initial anchor value for anchortype.
sub set_anchor {
  my ($self, $anchortype, $timestamp) = @_;
  $self->{anchor}->{$anchortype} = $timestamp;
  return $timestamp;
}

sub queued_count {
  my ($self) = @_;
  return $self->{queued_count};
}

sub anchortype {
  my ($self, $id) = @_;
  return if (!defined($id));
  my $elem = $self->{queued}->{$id};
  return undef unless($elem);
  return $elem->anchortype();
}

# Introspection methods for tests

sub queued {
  my ($self, $id) = @_;
  return $self->{queued}->{$id};
}

# The Heap::Elem::Str is broken in Heap 0.80, we want to use our own element.
package Jaiku::SyncQueue::Elem;
use strict;
use vars qw(@ISA);
use Heap::Elem;

@ISA = qw(Heap::Elem);

sub cmp {
  my ($self, $other) = @_;
  return ($self->[0]->{timestamp} cmp $other->[0]->{timestamp});
}

sub anchortype {
  my ($self) = @_;
  return $self->[0]->{anchor};
}

sub timestamp {
  my ($self) = @_;
  return $self->[0]->{timestamp};
}

1;
