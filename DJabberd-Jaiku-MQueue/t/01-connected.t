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
require 'mqueue-test.pl';
use Test::More tests => 5;

my $client = Jaiku::MessageQueue::Client->get_client();
my $storage = storage();
my $backend = backend();

my $nick = "nick1";
my $device = "00";

is($storage->number_of_calls("get_anchors"), undef, "storage not called");
$client->connected(1, $nick, $device, [ "BUDDYIMG", "PRESENCE" ]);
is($storage->number_of_calls("get_anchors"), 1, "called get_anchors");
is($storage->number_of_calls("get_seen_uuids"), 1, "called get_seen_uuids");

is($backend->number_of_calls("get_contacts"), 1, "called get_contacts");
is($backend->number_of_calls("get_presence"), 1, "called get_presence");
