#!/usr/bin/perl
use strict;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

use Data::Dumper;
use Test::More tests => 5;
use Time::HiRes;
use DJabberd::Jaiku::PresenceDb;

my $server = Test::DJabberd::Server->new(id => 1);
$server->start();
my $pa = Test::DJabberd::Client->new(
    server => $server, name => "popular", password => "baz",
    resource => "Context");
$pa->login();
ok(1);
my $api = get_jaiku_api();

my $presencev2="<presencev2><usergiven><since>20010101T010101</since><description>pl2</description></usergiven></presencev2>";
my $timestamp='20080910T121314';
$pa->send_xml("<clientversion value='7' xmlns='http://www.cs.helsinki.fi/group/context'/>");
$pa->send_xml("<presence><status>" . $timestamp . DJabberd::Util::exml($presencev2) . "</status></presence>");
# servertime
my $xml = $pa->receive_filter_avatars(1);
ok($xml, $xml);
# messagecount2
$xml = $pa->receive_filter_avatars(1);
ok($xml, $xml);
# messagecount
$xml = $pa->receive_filter_avatars(1);
ok($xml, $xml);

sleep 2;
my ($parsed, $error);
my $cb = sub { ($parsed, $error) = @_; };
$api->presence_set(callback => $cb,
                   nick => 'popular@jaiku.com',
                   presenceline => {
                     description => 'pl3',
                     since => '2008-09-11 12:11:14' });

$xml = '';
my $tries = 0;
while ($xml !~ /pl3/ && $tries < 15) {
  $xml = $pa->receive_filter_avatars(5);
  $tries++;
}
like($xml, qr/pl3/, "got presenceline $xml");
sleep 10;
