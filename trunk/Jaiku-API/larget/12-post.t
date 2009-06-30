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
use Test::More tests => 6;
use Data::Dumper;
use Devel::Peek;
use LWP;
use URI;
use utf8;

use Jaiku::API;
use lib 't/lib';
use API;

my $ua = LWP::UserAgent->new();
my $api = API::make(async_http => sub {
    my ($request, $callback) = @_;
    my $response = $ua->request($request);
    $callback->($response);
    });

my ($parsed, $error);
my $cb = sub { ($parsed, $error) = @_; };

my $body = "First post! with umlauts \xc3\xa4\xc3\xb6";
utf8::decode($body);

$api->post(callback => $cb,
           nick => 'popular',
           message => $body,
           location => "city",
           extra => { thumbnail_url =>
             'http://farm4.static.flickr.com/3563/3343788441_139322344a_t.jpg'});

ok($parsed);
is($parsed->{status}, 'ok', Dumper($parsed));

my $parent_uuid= $parsed->{rv}->{uuid};
$api->entry_add_comment_with_entry_uuid(
  callback => $cb,
  nick => 'popular',
  content => 'first comment!',
  entry_uuid => $parent_uuid);
ok($parsed);
is($parsed->{status}, 'ok', Dumper($parsed));

$api->entry_get_comments_with_entry_uuid(
  callback => $cb,
  entry_uuid => $parent_uuid);
ok($parsed);
is($parsed->{status}, 'ok', Dumper($parsed));
