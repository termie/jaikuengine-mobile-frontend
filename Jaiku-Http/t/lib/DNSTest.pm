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
# Helper package for running DNS tests with a set of replying methods and some
# queries.
#
package DNSTest;

use strict;
use DNSClient;
use DNSResolverClient;
use DNSServer;

sub run_with_server {
  my ($methods, $coderef) = @_;
  my $server = DNSServer->new(10053);
  foreach my $method (@$methods) {
    $server->add_method($method);
  }
  $server->start();
  my $server_port = $server->port();
  $coderef->($server_port);
  $server->stop();
}

sub run_single {
  my ($methods, $query_packet) = @_;
  my ($reply, $error);
  run_with_server($methods, sub {
      my ($server_port) = @_;
      ($reply, $error) = DNSClient::run_query($query_packet, $server_port);
  });
  return ($reply, $error);
}

sub run_resolver_a {
  my ($methods, $hostname, %opts) = @_;
  my ($reply, $error);
  run_with_server($methods, sub {
      my ($server_port) = @_;
      ($reply, $error) =
          DNSResolverClient::run_a($hostname, $server_port, %opts);
  });
  return ($reply, $error);
}

1;
