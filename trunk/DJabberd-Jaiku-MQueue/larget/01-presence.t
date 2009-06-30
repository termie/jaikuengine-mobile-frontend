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
BEGIN {
  use lib 't/lib';
  require 'mqueue-test.pl';
  require '../DJabberd/t/lib/jaiku-appengine.pl';
}

use Data::Dumper;
use Date::Parse;
use Test::More tests => 6;
use Jaiku::Presence qw(formatted_to_datetime mysql_datetime current_time);

use Jaiku::Backend::API;

my $api = get_jaiku_api();

my $backend = Jaiku::Backend::API->new($api);

my $result;
my $cb = sub {
  ($result) = @_;
};

$api->presence_set(callback => sub { },
                   nick => 'jaiku@jaiku.com',
                   presenceline => {
                       description => 'pl',
                       since => '2008-09-10 12:13:14' });


$backend->get_presence("popular", "", $cb);

ok(! $result->[2]);
is($#{$result->[0]}, 0);
my $pullitem = $result->[0]->[0];
my $tuple = $pullitem->payload();
is($tuple->tuplemeta()->subname()->value(), 'jaiku@jaiku.com');
ok(formatted_to_datetime($tuple->expires()->value()) >
  current_time() + 1 * 365 * 24 * 60 * 60);

my $anchor = $result->[1];
$backend->get_presence("popular", $anchor, $cb);
is($#{$result->[0]}, 0);

my $anchor_date = formatted_to_datetime($anchor);
$anchor_date += 60 * 60;
$anchor = mysql_datetime($anchor_date);
$backend->get_presence("popular", $anchor, $cb);
is($#{$result->[0]}, -1);
