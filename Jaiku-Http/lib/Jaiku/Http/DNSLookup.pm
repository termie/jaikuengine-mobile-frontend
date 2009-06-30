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
# A single DNS query using Danga::Socket and Net::DNS::Resolver.
# This class does no recursion or other checking of the response, that should
# be done by the caller (reasoning being that if the query returns multiple
# records, only some CNAMEs need to be followed, the different records may have
# different TTLs etc. so it makes sense to do that at a cache level).
#
# Loosely based on DJabberd::DNS by Brad Fitzpatrick (bradfitz@google.com).
#
# Usage:
#   my $query_packet = Net::DNS::Packet->new("$hostname", "A", "IN");
#   my $dns = Jaiku::Http::DNSLookup->new(
#     $query_packet,
#     sub { my ($result, $error) = @_; ... });
# The callback receives either the result as a Net::DNS::Packet object, or if an
# error occurred it receives undef and an error description.
#
# Note: this only tries UDP and hence can not get results beyound 512 bytes.

package Jaiku::Http::DNSLookup;
use strict;
use base 'Danga::Socket';
use Carp qw(croak);
use fields ('callback',
            'timer');
use Net::DNS;

my $resolver = Net::DNS::Resolver->new;
my $number_of_lookups = 0;

sub set_server {
  my ($class, $server_ip, $server_port) = @_;
  $resolver = Net::DNS::Resolver->new(
    nameservers => [ $server_ip ],
    port        => $server_port,
  );
}

sub number_of_lookups {
  return $number_of_lookups;
}

sub new {
  my ($class, %opts) = @_;
  my $callback = delete $opts{callback};
  croak("No callback given") unless ($callback);
  my $query_packet = delete $opts{query_packet};
  croak("No query given") unless ($query_packet);
  my $timeout = delete $opts{timeout};
  $timeout ||= 45.0;
  croak("Unknown option " . (values %opts)[0]) if (values(%opts));

  my $sock = $resolver->bgsend($query_packet);
  my $self = $class->SUPER::new($sock);

  $self->{callback}        = $callback;

  $self->{timer}           =
    Danga::Socket->AddTimer($timeout, sub {
        $callback->(undef,
                    "DNS lookup for '" . $query_packet->string() . "' timed out");
        $self->close();
    });

  $self->watch_read(1);
  $number_of_lookups++;
  return $self;
}

sub event_read {
  my ($self) = @_;

  my $sock = $self->{sock};
  my $cb   = $self->{callback};
  $self->{timer}->cancel();
  my $packet = $resolver->bgread($sock);
  $self->close();
  $cb->($packet);
}

1;
