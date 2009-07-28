#!/usr/bin/perl
use strict;
use Digest::SHA1;
use Test::Exception;
use Test::More tests => 2;
use lib 't/lib';
BEGIN { require 'jaiku-appengine.pl' }

my $server = Test::DJabberd::Server->new(id => 1);
$server->start();
my $pa = Test::DJabberd::Client->new(
    server => $server, name => "popular",
    password => Digest::SHA1::sha1_hex("baz"));
$pa->login();
ok(1);

$pa = Test::DJabberd::Client->new(
    server => $server, name => "popular",
    password => Digest::SHA1::sha1_hex("baz1"));

throws_ok {
  $pa->login();
} qr/bad password/;
