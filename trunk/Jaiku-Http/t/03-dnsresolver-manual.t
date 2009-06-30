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
use Test::More tests => 9;

use Jaiku::Http::DNSResolver;
use Net::DNS::Packet;

my $resolver = Jaiku::Http::DNSResolver->new();

my $no_results = $resolver->get_record("A", "host1");
is($no_results->[0], Jaiku::Http::DNSResolver::NO_DATA());
is($no_results->[1], "host1");

$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 100 A 10.0.0.1") ]);

my $one_result = $resolver->get_record("A", "host1");
is($one_result->[0]->address(), '10.0.0.1');

$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 100 A 10.0.1.0"),
      Net::DNS::RR->new("host1 100 A 10.0.1.1") ]);

my $return_from_random = 0;

Jaiku::Http::DNSResolver::set_random( sub { return $return_from_random; } );

$one_result = $resolver->get_record("A", "host1");
is($one_result->[0]->address(), '10.0.1.0');
$one_result = $resolver->get_record("A", "host1");
is($one_result->[0]->address(), '10.0.1.0');
$return_from_random = 1;
$one_result = $resolver->get_record("A", "host1");
is($one_result->[0]->address(), '10.0.1.1');

Jaiku::Http::DNSResolver::set_random(undef);
$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 100 IN CNAME host2"),
      Net::DNS::RR->new("host2 100 A 10.0.2.1") ]);
$one_result = $resolver->get_record("A", "host1");
is($one_result->[0]->address(), '10.0.2.1');

$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 100 IN CNAME host2"),
      Net::DNS::RR->new("host2 100 IN CNAME host3"),
      Net::DNS::RR->new("host3 100 IN CNAME host4"),
      Net::DNS::RR->new("host4 100 IN CNAME host5"),
      Net::DNS::RR->new("host5 100 IN CNAME host6"),
      Net::DNS::RR->new("host6 100 IN CNAME host7"),
      Net::DNS::RR->new("host7 100 IN CNAME host8"),
    ]);
my $recursed = $resolver->get_record("A", "host1");
is($recursed->[0], Jaiku::Http::DNSResolver::RECURSION_DEPTH_EXCEEDED());

$resolver->failed_query("A", "host1", 100);
my $failed = $resolver->get_record("A", "host1");
is($failed->[0], Jaiku::Http::DNSResolver::FAILED());
