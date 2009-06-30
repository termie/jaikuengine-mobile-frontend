#!/usr/bin/perl
use strict;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

use Data::Dumper;
use Digest::SHA1;
use Test::More tests => 8;
use Time::HiRes;
sub receive_filter_avatars {
  my ($pa, $timeout) = @_;
  my $xml;
  while ($xml = $pa->recv_xml($timeout)) {
    last unless($xml);
    if ($xml =~ /phonenumberisverified/ || $xml =~/content/) {
      if ($xml =~ /id>(\d+)<id/) {
        $pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>$1</ack>");
      }
    } else {
      last;
    }
  }
  return $xml;
}

my ($parsed, $error);
my $cb = sub { ($parsed, $error) = @_; };
my $api = get_jaiku_api();
$api->presence_set(callback => $cb,
                   nick => 'celebrity@jaiku.com',
                   presenceline => {
                     description => 'pl',
                     since => '2008-09-10 12:11:14' });
is($parsed->{status}, 'ok') or diag(Dumper($parsed));

my $server = Test::DJabberd::Server->new(id => 1);
$server->start();
my $pa = Test::DJabberd::Client->new(
    server => $server, name => "popular",
    password => Digest::SHA1::sha1_hex("baz"),
    resource => "Context");
$pa->login();
ok(1);

$pa->send_xml("<clientversion value='7' xmlns='http://www.cs.helsinki.fi/group/context'/>");
# servertime
my $xml = $pa->recv_xml(1);
ok($xml, $xml);
# messagecount2
$xml = $pa->recv_xml(1);
ok($xml, $xml);
# messagecount
$xml = $pa->recv_xml(1);
ok($xml, $xml);

# presence from jaiku
$xml = receive_filter_avatars($pa, 1);
ok($xml, "got presence from jaiku " . ($xml || ''));

if ($xml =~ /<id>(\d+)</) {
  $pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>$1</ack>");
}
$api->presence_set(callback => $cb,
                   nick => 'popular@jaiku.com',
                   presenceline => {
                     description => 'pl3',
                     since => '2008-09-11 12:11:15' });

$xml = receive_filter_avatars($pa, 3);
is($xml, undef, "should not receive own presence" . ($xml || ''));

$api->presence_set(callback => $cb,
                   nick => 'celebrity@jaiku.com',
                   presenceline => {
                     description => 'pl2',
                     since => '2008-09-11 12:11:16',
                     xx => 'xx'},
                   location => 'London, UK');
$xml = receive_filter_avatars($pa, 3);
ok($xml, "got new presence from jaiku " . ($xml || ''));
