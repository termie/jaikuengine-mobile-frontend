#!/usr/bin/perl
use strict;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

use Data::Dumper;
use Digest::SHA1;
use Jaiku::BBData::All;
use Jaiku::Tuple::FeedItem;
use Jaiku::Tuple::ThreadRequest;
use Test::More tests => 3;
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

$pa->send_xml("<clientversion value='7' xmlns='http://www.cs.helsinki.fi/group/context'/>");
while (my $xml = $pa->recv_xml(1)) {
  if ($xml =~ /tuple/) {
    if ($xml =~ /id>(\d+)<id/) {
      $pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>$1</ack>");
    }
  }
  # ignore all initial data
}

my $tuple = Jaiku::Tuple::ThreadRequest::make();
my $uuid = '1' . "0" x 26 . '12345';
my $request = Jaiku::BBData::ThreadRequest->new();
$request->postuuid()->set_value($uuid);
$tuple->set_data($request);
$tuple->tuplemeta()->subname()->set_value($uuid);
$tuple->tupleuuid()->set_value($uuid);
$tuple->tupleid()->set_value(1);
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
like($post, qr/3<\/tuplevalue/, "got count");
