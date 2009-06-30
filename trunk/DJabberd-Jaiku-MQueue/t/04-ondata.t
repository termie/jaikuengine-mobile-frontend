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

use Test::More tests => 8;

my $client = Jaiku::MessageQueue::Client->get_client();

my $nick = "nick1";
my $device = "00";

my $connection = new MockConnection;
my $tuple = new Jaiku::BBData::Tuple;
my $uuid = "0" x 15 . 1;
my $timestamp = "0001";
my $tuple_pullitem = new Jaiku::PullItem(
  timestamp => $timestamp, payload => $tuple, uuid => $uuid);

is(storage()->anchor(
    $nick, $device, Jaiku::MessageQueue::Client::ANCHOR_PRESENCE()),
  undef);

backend()->set_return("get_presence", $nick, "",
                      [ [$tuple_pullitem], $timestamp, undef ]);
$client->connected(1, $nick, $device, [ "PRESENCE" ], $connection);
my $syncqueue = $client->syncqueue($nick, $device);
is(storage()->anchor(
    $nick, $device, Jaiku::MessageQueue::Client::ANCHOR_PRESENCE()),
  $timestamp);

is($#{$connection->tuples()}, 0);
ok($syncqueue->queued($uuid));

$client->acked($nick, $device, $uuid);
ok(!$syncqueue->queued($uuid));

is($syncqueue->anchor(Jaiku::MessageQueue::Client::ANCHOR_PRESENCE()), $timestamp);
is(storage()->anchor(
    $nick, $device, Jaiku::MessageQueue::Client::ANCHOR_PRESENCE()),
  $timestamp);

my $timestamp2 = "0002";
backend()->set_return("get_presence", $nick, "",
                      [ [], $timestamp2, undef ]);
$client->acked($nick, $device, undef);
is($syncqueue->anchor(Jaiku::MessageQueue::Client::ANCHOR_PRESENCE()),
   $timestamp2);

exit;

package MockConnection;
use fields qw(tuples);

sub new {
  my MockConnection $self = shift;
  $self = fields::new($self) unless ref $self;
  $self->{tuples} = [];
  return $self;
}

sub got_message {
  my ($self, $tuple) = @_;
  push(@{$self->{tuples}}, $tuple);
}

sub tuples {
  my ($self) = @_;
  return $self->{tuples};
}
