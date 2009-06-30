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

use strict;
use lib 't/lib';

use Data::Dumper;
use Jaiku::PullItem;
use Test::More tests => 9;
use Test::Exception;

my $payload = "xx";
my $uuid = "1234567890123456";
my $timestamp = 1;

my $item = Jaiku::PullItem->new(timestamp => $timestamp,
                                uuid => $uuid,
                                payload => \$payload);
ok($item);
is($item->uniqueid(), $uuid);
is($item->payload(), \$payload);
is($item->timestamp(), $timestamp);

throws_ok {
    $item = Jaiku::PullItem->new(uuid => $uuid,
                                 payload => \$payload);
    } qr/timestamp/;

throws_ok {
    $item = Jaiku::PullItem->new(timestamp => $timestamp,
                                 uuid => $uuid);
    } qr/payload/;

throws_ok {
    $item = Jaiku::PullItem->new(timestamp => $timestamp,
                                 uuid => "xx",
                                 payload => $payload);
    } qr/exactly 16 bytes/;

my $uuid_hex = "01020304050607080900010203040506";
$uuid = "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x00\x01\x02\x03\x04\x05\x06";
is(length($uuid), 16);
my $item2 = Jaiku::PullItem->new(timestamp => $timestamp,
                                 uuid => $uuid_hex,
                                 payload => $payload);
ok($item2->uniqueid() eq $uuid);
