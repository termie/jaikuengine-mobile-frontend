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
#
# A simple DNS server for running tests

package DNSServer;
use strict;
use IO::Handle;
use Net::DNS::Server;
use fields qw(port methods child);

my $server_port = 10053;
my $child;

sub new {
  my ($self, $port) = @_;
  $self = fields::new($self) unless(ref($self));
  $self->{port} = $port || 10053;
  return $self;
}

sub start {
  my ($self) = @_;
  my $port = $self->{port};
  pipe(READ_CHILD_READY, WRITE_CHILD_READY);
  WRITE_CHILD_READY->autoflush(1);
  $child = fork();
  if (!$child) {
    _run_server(*WRITE_CHILD_READY{IO}, $port, $self->{methods});
    exit;
  } else {
    my $child_ready;
    read(READ_CHILD_READY, $child_ready, 1);
  }
  $self->{child} = $child;
}

sub add_method {
  my ($self, $method) = @_;
  push(@{$self->{methods}}, $method);
}

sub stop {
  my ($self) = @_;
  my $child = $self->{child};
  kill(9, $child);
  waitpid($child, 0)
}

sub port {
  my ($self) = @_;
  return $self->{port};
}

# Run in child process
sub _run_server {
  my ($WRITE_CHILD_READY, $server_port, $methods) = @_;
  die "methods not an array" unless(ref($methods) eq "ARRAY");
  die "methods empty" unless($#$methods > -1);
  my $server;
  while (!$server) {
    $server = Net::DNS::Server->new(
        '127.0.0.1:' . $server_port, $methods);
    sleep 0.1;
  }

  $server->get_question(0.1);
  print $WRITE_CHILD_READY "r";
  while ($server->get_question(60.0)) {
    while ($server->process()) {
      $server->send_response();
    }
  }
}

1;

package AnswerWithA;
use fields qw(ip name);
use vars qw(@ISA);
@ISA = qw(Net::DNS::Method);

sub new {
  my ($self, $name, $ip) = @_;
  $self = fields::new($self) unless(ref($self));
  $self->{name} = $name;
  $self->{ip} = $ip;
  return $self;
}

sub A {
  my ($self, $query, $answer) = @_;
  my $name = $self->{name};
  my $ip = $self->{ip};
  if ($query->qname() eq $self->{name}) {
    my $a = Net::DNS::RR->new("$name 86400 A $ip");
    $answer->push(pre => $a);
  }
  return Net::DNS::Method::NS_OK();
}

1;

package AnswerWithCName;
use fields qw(name cname);
use vars qw(@ISA);
@ISA = qw(Net::DNS::Method);

sub new {
  my ($self, $name, $cname) = @_;
  $self = fields::new($self) unless(ref($self));
  $self->{name} = $name;
  $self->{cname} = $cname;
  return $self;
}

sub A {
  my ($self, $query, $answer) = @_;
  my $name = $self->{name};
  my $cname = $self->{cname};
  if ($query->qname() eq $self->{name}) {
    my $a = Net::DNS::RR->new("$name 86400 IN CNAME $cname");
    $answer->push(pre => $a);
  }
  return Net::DNS::Method::NS_OK();
}

1;

package AnswerWithNXDomain;
use fields qw(name);
use vars qw(@ISA);
@ISA = qw(Net::DNS::Method);

sub new {
  my ($self, $name) = @_;
  $self = fields::new($self) unless(ref($self));
  $self->{name} = $name;
  return $self;
}

sub A {
  my ($self, $query, $answer) = @_;
  my $name = $self->{name};
  if ($query->qname() eq $self->{name}) {
    $answer->header()->rcode("NXDOMAIN");
    return Net::DNS::Method::NS_STOP();
  }
  return Net::DNS::Method::NS_OK();
}

1;

package AnswerEmpty;
use fields qw(name);
use vars qw(@ISA);
@ISA = qw(Net::DNS::Method);

sub new {
  my ($self, $name) = @_;
  $self = fields::new($self) unless(ref($self));
  $self->{name} = $name;
  return $self;
}

sub A {
  my ($self, $query, $answer) = @_;
  my $name = $self->{name};
  if ($query->qname() eq $self->{name}) {
    $answer->header()->rcode("NOERROR");
    return Net::DNS::Method::NS_STOP();
  }
  return Net::DNS::Method::NS_OK();
}

1;


