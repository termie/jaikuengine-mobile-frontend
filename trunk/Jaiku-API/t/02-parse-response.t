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

#

use strict;
use Test::More tests => 7;
use HTTP::Response;
use URI;

use Jaiku::API;
use lib 't/lib';
use API;

my $api = API::make();

my $json = '{"status": "ok", "rv": {"privacy": 3, "nick": "popular@jaiku.com",
    "password": "baz", "type": "user", "extra": {"follower_count": 3,
      "contact_count": 2, "icon": "default/animal_3"}}}';

my $response = HTTP::Response->new(200);
$response->content($json);

my ($parsed, $error) = $api->parse_response($response);
ok($parsed);
is($parsed->{status}, 'ok');

($parsed, $error) = $api->parse_response(undef, "nw error");
ok(!$parsed);
is($error, "nw error");

($parsed, $error) = $api->parse_response(HTTP::Response->new(403));
ok(!$parsed);

$response->content("xx");
($parsed, $error) = $api->parse_response($response);
ok(!$parsed);
like($error, qr/parse/i);
