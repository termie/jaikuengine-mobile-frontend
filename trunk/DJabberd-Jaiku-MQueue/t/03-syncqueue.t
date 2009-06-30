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

use Jaiku::SyncQueue;
use Test::More tests => 31;

my $AT = 1;
my $AT2 = 2;
my $q = Jaiku::SyncQueue->new();
ok($q);
my $initial = $q->set_anchor($AT, "0100");
is($initial, "0100");

is($q->set_anchor($AT2, "1100"), "1100");

my $ts = "0010";
my $id1 = "1";

my $anchor = $q->queue($AT, $id1, $ts);
is($anchor, $ts);
is($ts, $q->anchor($AT));
is($q->queued_count(), 1);

is($q->queue($AT2, 11, "1010"), "1010");
is($q->queued_count(), 2);

ok(!defined($q->dequeue($AT, $id1)));
is($q->queued_count(), 1);

$ts = "0020";
$anchor = $q->queue($AT, $id1, $ts);
is($anchor, $ts);
is($ts, $q->anchor($AT));
is($q->queued_count(), 2);


my $id2 = "2";
my $id3 = "3";
my $ts2 = "0020";
my $ts3 = "0030";

$anchor = $q->queue($AT, $id2, $ts2);
ok(!defined($anchor));
is($q->queued_count(), 3);

$anchor = $q->queue($AT, $id3, $ts3);
ok(!defined($anchor));
is($q->queued_count(), 4);

$anchor = $q->dequeue($id1);
ok(!defined($anchor), "anchor is " . ($anchor || ""));
is($q->queued_count(), 3);

$anchor = $q->dequeue($id2);
is($ts3, $anchor);
is($q->queued_count(), 2);

$anchor = $q->dequeue($id3);
is($anchor, undef);
is($q->queued_count(), 1);

my $ts4 = "0040";
$anchor = $q->no_items_at($AT, $ts4);
is($ts4, $anchor);
is($ts4, $q->anchor($AT));

my $ts5 = "0050";
my $ts6 = "0060";
$anchor = $q->queue($AT, $id3, $ts5);
is($q->queued_count(), 2);
is($ts5, $anchor);
$anchor = $q->no_items_at($AT, $ts6);
ok(!defined($anchor));
$anchor = $q->dequeue($id3);
is($anchor, $ts6);
is($q->queued_count(), 1);

$q->dequeue(11);
is($q->queued_count(), 0);
