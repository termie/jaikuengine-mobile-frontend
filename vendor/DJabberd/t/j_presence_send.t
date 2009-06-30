#!/usr/bin/perl
use strict;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

use Data::Dumper;
use Test::More tests => 8;
use Time::HiRes;
use DJabberd::Jaiku::PresenceDb;

my $server = Test::DJabberd::Server->new(id => 1);
$server->start();
my $pa = Test::DJabberd::Client->new(
    server => $server, name => "popular", password => "baz",
    resource => "Context");
$pa->login();
ok(1);

my $presencev2="<presencev2><usergiven><since>20010101T010101</since><description>pl2</description></usergiven></presencev2>";
my $timestamp='20080910T121314';
$pa->send_xml("<clientversion value='7' xmlns='http://www.cs.helsinki.fi/group/context'/>");
$pa->send_xml("<presence><status>" . $timestamp . DJabberd::Util::exml($presencev2) . "</status></presence>");

# This is a slightly flaky test since it just assumes that the server has
# procesed the presence stanza after 2 seconds as we don't yet send anything
# else in the server on reception of presence.
# TODO(mikie): rewrite once presence is correctly reflected to buddies.

sleep 2;

my $api = get_jaiku_api();
my ($parsed, $error);
my $cb = sub { ($parsed, $error) = @_; };
$api->presence_get(callback => $cb, nick => 'popular@jaiku.com');
ok($parsed, 'presence_get returned');
is($parsed->{status}, 'ok', 'presence_get ok');
is($parsed->{rv}->{presence}->{extra}->{presenceline}->{description}, 'pl2',
    'presence is pl2') or diag(Dumper($parsed));
is($parsed->{rv}->{presence}->{extra}->{senders_timestamp}, $timestamp,
    'presence timestamp') or diag(Dumper($parsed));

$presencev2='<presence
type="available"><show>xa</show><status>20090219T134416&lt;presencev2>&lt;base>&lt;base.current>&lt;base.id>2&lt;/base.id>&lt;base.name>&lt;/base.name>&lt;base.arrived>20060815T220750&lt;/base.arrived>&lt;base.left>00000101T000000&lt;/base.left>&lt;/base.current>&lt;/base>&lt;city>&lt;/city>&lt;country>Finland&lt;/country>&lt;location.value>&lt;location.mcc>244&lt;/location.mcc>&lt;location.mnc>5&lt;/location.mnc>&lt;location.network>RADIOLINJA&lt;/location.network>&lt;location.lac>1800&lt;/location.lac>&lt;location.cellid>610&lt;/location.cellid>&lt;location.id>2&lt;/location.id>&lt;/location.value>&lt;cell_name>&lt;/cell_name>&lt;useractivity>&lt;active>true&lt;/active>&lt;since>20090219T134416&lt;/since>&lt;/useractivity>&lt;profile>&lt;profile.id>0&lt;/profile.id>&lt;profile.name>General&lt;/profile.name>&lt;profile.ringtype>0&lt;/profile.ringtype>&lt;profile.ringvolume>7&lt;/profile.ringvolume>&lt;profile.vibra>false&lt;/profile.vibra>&lt;/profile>&lt;usergiven>&lt;description>test&lt;/description>&lt;since>20020101T010101&lt;/since>&lt;/usergiven>&lt;bt.presence>&lt;buddies>0&lt;/buddies>&lt;other_phones>0&lt;/other_phones>&lt;own_laptops>1&lt;/own_laptops>&lt;own_desktops>1&lt;/own_desktops>&lt;own_pdas>1&lt;/own_pdas>&lt;/bt.presence>&lt;calendar>&lt;previous>&lt;start_time>00000101T000000&lt;/start_time>&lt;description>&lt;/description>&lt;end_time>00000101T000000&lt;/end_time>&lt;eventid>0&lt;/eventid>&lt;/previous>&lt;current>&lt;start_time>00000101T000000&lt;/start_time>&lt;description>&lt;/description>&lt;end_time>00000101T000000&lt;/end_time>&lt;eventid>0&lt;/eventid>&lt;/current>&lt;next>&lt;start_time>00000101T000000&lt;/start_time>&lt;description>&lt;/description>&lt;end_time>00000101T000000&lt;/end_time>&lt;eventid>0&lt;/eventid>&lt;/next>&lt;/calendar>&lt;citysince>00000101T000000&lt;/citysince>&lt;countrysince>00000101T000000&lt;/countrysince>&lt;devices>&lt;device>&lt;bt.mac>001262e353b1&lt;/bt.mac>&lt;bt.name>&lt;/bt.name>&lt;bt.majorclass>2&lt;/bt.majorclass>&lt;bt.minorclass>3&lt;/bt.minorclass>&lt;bt.serviceclass>4&lt;/bt.serviceclass>&lt;/device>&lt;/devices>&lt;generated>true&lt;/generated>&lt;connectivitymodel>0&lt;/connectivitymodel>&lt;incall>false&lt;/incall>&lt;/presencev2></status></presence>';
print STDERR "sending pres\n";
$pa->send_xml($presencev2);
print STDERR "pres sent\n";

sleep 2.2;

print STDERR "getting pres\n";
$api->presence_get(callback => $cb, nick => 'popular@jaiku.com');
print STDERR "pres got\n";
ok($parsed, 'presence_get 2 returned');
is($parsed->{status}, 'ok', 'presence_get 2 ok');
is($parsed->{rv}->{presence}->{extra}->{presenceline}->{description}, 'test',
  'presence 2 is test') or diag(Dumper($parsed));

