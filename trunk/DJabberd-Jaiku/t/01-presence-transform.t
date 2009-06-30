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
use Test::More tests => 2;
use DJabberd::Jaiku::Transforms;

my $source = {
  city => 1, country => 1,
  citysince => 10, countrysince => 11,
  cell_name => 'cn',
  profile => {
    "profile.id" => 0,
    "profile.name" => 'n',
  },
  base => {
    "base.current" => {
      "base.id" => 2,
    },
  },
  "location.value" => {
    "location.mcc" => 3,
    "location.mnc" => 4,
  },
  useractivity => {
    active => 'a',
  },
  incall => 'ic',
  usergiven => {
    description => 'd',
  },
  "bt.presence" => {
    buddies => 'b'
  },
  devices => [
    { "bt.mac" => 'btm1' },
    { "bt.mac" => 'btm2' },
  ],
};

my $expected = {
  location => {
    city => { name => 1, since => 10 },
    country => { name => 1, since => 11 },
    base => {
      current => { id => 2 }
    },
    cell => {
      mcc => 3, mnc => 4,
      name => 'cn',
    },
  },
  profile => {
    id => 0,
    name => 'n'
  },
  activity => {
    active => 'a',
    incall => 'ic',
  },
  presenceline => {
    description => 'd',
  },
  bt => {
    buddies => 'b',
    neighbours => [
      { mac => 'btm1' },
      { mac => 'btm2' },
    ],
  }
};

my $got = DJabberd::Jaiku::Transforms::presence_to_api($source);

is_deeply($got, $expected);

my $reverse = DJabberd::Jaiku::Transforms::api_to_presence($expected);

is_deeply($reverse, $source);
