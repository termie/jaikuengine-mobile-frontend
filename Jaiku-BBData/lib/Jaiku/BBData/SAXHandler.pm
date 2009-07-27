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
# SAX parser that turns parser events into DJabberd XMLElements.
# Code mostly taken from DJabberd::SAXHandler by bradfitz@google.com but
# modified not to require a DJabberd connection and server.
#
# Once created, it'll call the given callback function with the elements
# it has created each time it sees a full top-level element.
#
package Jaiku::BBData::SAXHandler;
use strict;
use base qw(XML::SAX::Base);
use DJabberd::XMLElement;
use DJabberd::SAXHandler;

sub new {
  my ($class, $cb) = @_;
  my $self = $class->SUPER::new;
  $self->{cb} = $cb;

  $self->{"capture_depth"} = 0;  # on transition from 1 to 0, stop capturing
  $self->{"on_end_capture"} = undef;  # undef or $subref->($doc)
  $self->{"events"} = [];  # capturing events
  return $self;
}

sub set_cb {
  my ($self, $cb) = @_;
  $self->{cb} = $cb;
  if (!$cb) {
    # when sax handler is being put back onto the freelist...
    $self->{on_end_capture} = undef;
  }
}

# called when somebody is about to destroy their reference to us, to make
# us clean up.
sub cleanup {
  my $self = shift;
  $self->{on_end_capture} = undef;
}

sub depth {
  return $_[0]{capture_depth};
}

use constant EVT_START_ELEMENT => DJabberd::SAXHandler::EVT_START_ELEMENT;
use constant EVT_END_ELEMENT => DJabberd::SAXHandler::EVT_END_ELEMENT;
use constant EVT_CHARS     => DJabberd::SAXHandler::EVT_CHARS;

sub start_element {
  my ($self, $data) = @_;
  my $cb = $self->{cb};

  if ($self->{capture_depth}) {
    push @{$self->{events}}, [EVT_START_ELEMENT, $data];
    $self->{capture_depth}++;
    return;
  }

  # start capturing...
  $self->{"events"} = [
             [EVT_START_ELEMENT, $data],
             ];
  $self->{capture_depth} = 1;

  $self->{on_end_capture} = sub {
    my ($doc, $events) = @_;
    my $nodes = DJabberd::SAXHandler::_nodes_from_events($events);
    $cb->($nodes);
  };
  return;
}

sub characters {
  my ($self, $data) = @_;

  if ($self->{capture_depth}) {
    push @{$self->{events}}, [EVT_CHARS, $data];
  }
}

sub end_element {
  my ($self, $data) = @_;

  if ($self->{capture_depth}) {
    push @{$self->{events}}, [EVT_END_ELEMENT, $data];
    $self->{capture_depth}--;
    return if $self->{capture_depth};
    my $doc = undef;
    if (my $cb = $self->{on_end_capture}) {
      $cb->($doc, $self->{events});
    }
    return;
  }
}

1;
