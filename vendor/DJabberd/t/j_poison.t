#!/usr/bin/perl
use strict;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

use Data::Dumper;
use Digest::SHA1;
use Test::More tests => 31;
use Time::HiRes;

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

my $POISON_MAX = 5;

for (my $i = 0; $i <= $POISON_MAX; $i++) {
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
  # messagecount
  $xml = $pa->recv_xml(1);
  ok($xml, $xml);
  # messagecount2
  $xml = $pa->recv_xml(1);
  ok($xml, $xml);

  # presence from jaiku
  $xml = $pa->recv_xml(1);
  if ($i < $POISON_MAX) {
    ok($xml, "got tuple as should $xml");
  } else {
    is($xml, undef, "discarded poison tuple");
  }
  $pa->disconnect();
}
