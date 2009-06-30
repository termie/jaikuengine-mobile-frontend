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
use Test::More tests => 8;

use lib 't/lib';
use DangaWaitLoop;
use Jaiku::Http::DNSResolver;
use Net::DNS::Packet;

my $resolver = Jaiku::Http::DNSResolver->new();

# Danga::Socket doesn't support mocking its clock and I don't want to mock
# Time::Hires globally so we bake in simulated time via a scaling factor.
my $timescale = 0.001;

Jaiku::Http::DNSResolver::set_timescale($timescale);
$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 10   A 10.0.0.1"),
      Net::DNS::RR->new("host2 1000 A 10.0.0.2") ]);

my $result = $resolver->get_record("A", "host1");
is($result->[0]->address(), '10.0.0.1');
$result = $resolver->get_record("A", "host2");
is($result->[0]->address(), '10.0.0.2');

DangaWaitLoop::wait($timescale * 10 * 2);
$result = $resolver->get_record("A", "host1");
is($result->[0], Jaiku::Http::DNSResolver::NO_DATA());
$result = $resolver->get_record("A", "host2");
is($result->[0]->address(), '10.0.0.2');

$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 10   A 10.0.0.1") ]);
$result = $resolver->get_record("A", "host1");
is($result->[0]->address(), '10.0.0.1');
$resolver->insert_records(
    "A",
    [ Net::DNS::RR->new("host1 100   A 10.0.0.1") ]);
DangaWaitLoop::wait($timescale * 10 * 2);
$result = $resolver->get_record("A", "host1");
is($result->[0]->address(), '10.0.0.1');

$resolver->failed_query("A", "host1", 10);
$result = $resolver->get_record("A", "host1");
is($result->[0], Jaiku::Http::DNSResolver::FAILED());
DangaWaitLoop::wait($timescale * 10 * 2);
$result = $resolver->get_record("A", "host1");
is($result->[0], Jaiku::Http::DNSResolver::NO_DATA());
