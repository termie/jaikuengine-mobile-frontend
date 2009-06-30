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
use Test::More tests => 4;
use DJabberd::Jaiku::Transforms;

my $post_api = {
  'created_at' => '2008-02-15 01:02:03',
  'uuid' => '12345',
  'actor' => 'popular@jaiku.com',
  'extra' => {
    'title' => 'test entry 1'
  }
};

my $post_api_in = {
  uuid => '12345',
  message => 'test entry 1',
  nick => 'popular@jaiku.com',
};

my $post_mobile = {
  'created' => '2008-02-15 01:02:03',
  'uuid' => '12345',
  'authornick' => 'popular@jaiku.com',
  'content' => 'test entry 1',
};

my $post_mobile_transformed =
    DJabberd::Jaiku::Transforms::api_to_feeditem($post_api);
is_deeply($post_mobile_transformed, $post_mobile);

my $post_api_transformed =
   DJabberd::Jaiku::Transforms::feeditem_to_api($post_mobile);
is_deeply($post_api_transformed, $post_api_in);

my $comment_api = {
  'created_at' => '2008-02-15 01:02:08',
  'uuid' => '12348',
  'actor' => 'popular@jaiku.com',
  'extra' => {
    'entry_uuid' => '12345',
    'content' => 'test entry comment 1',
    'entry_title' => 'test entry 1',
    'entry_actor' => 'popular@jaiku.com',
  }
};

my $comment_api_in = {
  uuid => '12348',
  entry_uuid => '12345',
  content => 'test entry comment 1',
  nick => 'popular@jaiku.com',
};

my $comment_mobile = {
  'created' => '2008-02-15 01:02:08',
  'uuid' => '12348',
  'authornick' => 'popular@jaiku.com',
  'content' => 'test entry comment 1',
  'parentuuid' => '12345',
  'parenttitle' => 'test entry 1',
  'parentauthornick' => 'popular@jaiku.com',
};

my $comment_mobile_transformed =
    DJabberd::Jaiku::Transforms::api_to_feeditem($comment_api);
is_deeply($comment_mobile_transformed, $comment_mobile);

my $comment_api_transformed =
   DJabberd::Jaiku::Transforms::feeditem_to_api($comment_mobile);
is_deeply($comment_api_transformed, $comment_api_in);

