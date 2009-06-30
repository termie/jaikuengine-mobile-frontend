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

use strict;
use lib 't/lib';
use Test::More tests => 6;

use DangaWaitLoop;
use DNSTest;
use Net::DNS::Packet;

use constant HOST_NAME => 'simple1.example.org';
use constant HOST_IP   => '10.0.0.1';
use constant HOST_CNAME => 'cname.example.org';

my $timescale = 0.0001;
Jaiku::Http::DNSResolver::set_timescale($timescale);

my ($reply, $error) = DNSTest::run_resolver_a(
    [ AnswerWithNXDomain->new(HOST_NAME) ],
    HOST_NAME,
);

is($reply, undef, "no reply on NXDOMAIN");
like($error, qr/no such domain/);


($reply, $error) = DNSTest::run_resolver_a(
    [ AnswerEmpty->new(HOST_NAME) ],
    HOST_NAME,
);

is($reply, undef, "no reply on no data");
like($error, qr/no such domain/);

# Negative cache TTL is 1 hour when there's no SOA record.
DangaWaitLoop::wait($timescale * (60 * 60 + 1));
($reply, $error) = DNSTest::run_resolver_a(
    [ AnswerEmpty->new("x") ],
    HOST_NAME,
    timeout => 0.5
);

is($reply, undef, "no reply on timed out");
like($error, qr/timed out/);
