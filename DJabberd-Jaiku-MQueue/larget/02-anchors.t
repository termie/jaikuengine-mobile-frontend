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
use Test::More tests => 4;

use Jaiku::Storage::API;

my $api = get_jaiku_api();

my $storage = Jaiku::Storage::API->new($api);

my ($result, $error);
my $cb = sub {
  ($result, $error) = @_;
};

my $nick = 'popular@jaiku.com';
my $id = 'dev1';

$storage->set_anchor($nick, $id, 1, '2', $cb);
ok($result);
$storage->set_anchor($nick, $id, 3, '4', $cb);
ok($result);

$storage->get_anchors($nick, $id, $cb);
is($result->{1}, '2');
is($result->{3}, '4');
