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

package DNSClient;
use strict;
use Danga::Socket;
use Jaiku::Http::DNSLookup;

sub run_query {
  my ($query_packet, $server_port) = @_;
  my ($reply, $error, $done);

  my $dns_cb = sub {
    ($reply, $error) = @_;
    $done = 1;
  };
  Jaiku::Http::DNSLookup->set_server('127.0.0.1', $server_port);
  my $dns = Jaiku::Http::DNSLookup->new(
      query_packet => $query_packet,
      callback => $dns_cb,
      timeout => 1.0,
  );

  Danga::Socket->SetPostLoopCallback(sub {
      return !$done;
  });
  Danga::Socket->SetLoopTimeout(100);
  Danga::Socket->EventLoop();

  return ($reply, $error);
}

1;
