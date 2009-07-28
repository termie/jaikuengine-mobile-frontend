#!/usr/bin/perl
use strict;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

use Data::Dumper;
use Digest::SHA1;
use Jaiku::BBData::All;
use Jaiku::Tuple::FeedItem;
use Test::More tests => 5;
use Time::HiRes;

sub receive_filter_avatars {
  my ($pa, $timeout) = @_;
  my $xml;
  while ($xml = $pa->recv_xml($timeout)) {
    last unless($xml);
    if ($xml =~ /phonenumberisverified/) {
      if ($xml =~ /id>(\d+)<id/) {
        $pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>$1</ack>");
      }
    } else {
      last;
    }
  }
  return $xml;
}

my $server = Test::DJabberd::Server->new(id => 1);
$server->start();
my $pa = Test::DJabberd::Client->new(
    server => $server, name => "popular",
    password => Digest::SHA1::sha1_hex('baz'),
    resource => "Context");
$pa->login();
ok(1);

my $message = Jaiku::BBData::FeedItem->new("tuplevalue");
my $uuid = "00" x 15 . "01";
$message->from_parsed({
    content => 'first post!',
    uuid => $uuid,
});
my $tuple = Jaiku::BBData::Tuple->new("tuple");
$tuple->from_parsed({
    tuplename => {
      module_uid => Jaiku::Tuple::FeedItem::UID,
      module_id => Jaiku::Tuple::FeedItem::ID,
      subname => $uuid },
    id => 1,
    uuid => $uuid,
});
$tuple->set_data($message);

$pa->send_xml("<clientversion value='7' xmlns='http://www.cs.helsinki.fi/group/context'/>");
while (my $xml = $pa->recv_xml(1)) {
  if ($xml =~ /tuple/) {
    if ($xml =~ /id>(\d+)<id/) {
      $pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>$1</ack>");
    }
  }
  # ignore all initial data
}

$pa->send_xml($tuple->as_xml());

my $xml1 = receive_filter_avatars($pa, 4);
my $xml2 = receive_filter_avatars($pa, 4);

my ($ack, $post);
if ($xml1 =~ /ack/) {
  $ack = $xml1;
  $post = $xml2;
} else {
  $ack = $xml2;
  $post = $xml1;
}
like($ack, qr/ack/, "acked $ack");
$post ||= '';
like($post, qr/first post/, "got post back $post");

$pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>1</ack>");

my $uuid2 = "00" x 15 . "02";
$tuple->tupleid()->set_value(2);
$tuple->tupleuuid()->set_value($uuid2);
$message->uuid()->set_value($uuid2);
$message->parentuuid()->set_value($uuid);
$pa->send_xml($tuple->as_xml());

$xml1 = receive_filter_avatars($pa, 4);
$xml2 = receive_filter_avatars($pa, 4);
if ($xml1 =~ /ack/) {
  $ack = $xml1;
  $post = $xml2;
} else {
  $ack = $xml2;
  $post = $xml1;
}

like($ack, qr/ack/, "acked $ack");

like($post, qr/0002/, "got post back $post");

$pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>2</ack>");
