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

# Author: mikie@google.com (Mika Raento)

package HTTPServer;

use strict;
use fields qw(child port responder);
use HTTP::Daemon;
use HTTP::Request;
use HTTP::Status;
use IO::Handle;

sub new {
  my ($class, $responder, $port) = @_;
  my $self = fields::new($class);
  $self->{responder} = $responder;
  $self->{port} = $port;
  return $self;
}

sub port {
  my ($self) = @_;
  return $self->{port};
}

sub start {
  my ($self) = @_;
  pipe(READ_CHILD_READY, WRITE_CHILD_READY);
  WRITE_CHILD_READY->autoflush(1);
  my $child = fork();
  if ($child) {
    $SIG{__DIE__} = sub { $self->stop(); };
    my $child_ready;
    read(READ_CHILD_READY, $child_ready, 1);
    $self->{child} = $child;
    return;
  }
  $^P = 0;
  my $d = HTTP::Daemon->new(LocalPort => $self->port(),
                            ReuseAddr => 1);
  my $responder = $self->{responder};
  print WRITE_CHILD_READY "r";
  while (my $c = $d->accept()) {
    while (my $r = $c->get_request()) {
      $responder->($c, $r);
    }
    $c->close;
  }
  exit;
}

sub stop {
  my ($self) = @_;
  my $child = $self->{child};
  return unless($child);
  kill(9, $child);
  waitpid($child, 0);
  delete $SIG{__DIE__};
}

1;
