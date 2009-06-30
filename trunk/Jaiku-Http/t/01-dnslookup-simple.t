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
use Test::More tests => 5;

use DNSTest;
use Net::DNS::Packet;

use constant HOST_NAME => 'simple1.example.org';
use constant HOST_IP   => '10.0.0.1';

my ($reply, $error) = DNSTest::run_single(
    [ AnswerWithA->new(HOST_NAME, HOST_IP) ],
    Net::DNS::Packet->new(HOST_NAME, "A", "IN")
);

ok($reply, "got reply");
my @a = grep { $_->isa('Net::DNS::RR::A') } $reply->answer();
is($#a, 0, "got one A records");
is($a[0]->address(), HOST_IP);

($reply, $error) = DNSTest::run_single(
    [ AnswerWithA->new("x" . HOST_NAME, HOST_IP) ],
    Net::DNS::Packet->new(HOST_NAME, "A", "IN")
);

ok($reply, "got reply");
@a = grep { $_->isa('Net::DNS::RR::A') } $reply->answer();
is($#a, -1, "got no A records");

