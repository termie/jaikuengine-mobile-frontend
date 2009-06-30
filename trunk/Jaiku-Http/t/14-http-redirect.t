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

# Author: mikie@google.com (Mika Raento)

use strict;
use Test::More tests => 11;
use HTTP::Response;
use HTTP::Status;
use lib 't/lib';
use HTTPTest;

my $response_code = 200;
my $content = "<html>Hi!";
my $content_type = "text/html";
my $server_port = 10080;

my $responder = sub {
  my ($conn, $request) = @_;
  my $response = HTTP::Response->new(
      $response_code,
      "OK",
      [ "Content-type", $content_type ],
      $content
  );
  my $request_uri = $request->uri();
  my $redirect_to = $request_uri->clone();
  $redirect_to->path() =~ /redirect([0-9]*)/;
  my $count = $1 || 0;
  if (!$count) {
    $redirect_to->path('/');
  } elsif($count < 99) {
    # Do infinite redirects with 99.
    $count--;
    $redirect_to->path('/redirect' . $count);
  }
  my $redirect = HTTP::Response->new(
      302,
      "Moved",
      [ "Location", $redirect_to->as_string() ],
  );
  if ($request->method() eq 'GET') {
    if ($request_uri->path() =~ /redirect/) {
      $conn->send_response($redirect);
    } else {
      $conn->send_response($response);
    }
  } else {
    $conn->send_error(RC_FORBIDDEN)
  }
};

my $request = HTTP::Request->new(
    GET => 'http://127.0.0.1:' . $server_port . '/redirect');

my ($reply, $error) = HTTPTest::run_test(
  $responder, $server_port, $request);

ok($reply, "got reply " . ($error || ''));
is($reply && $reply->code(), $response_code);
is($reply && $reply->content(), $content);
is($reply && $reply->header("Content-type"), $content_type);

$request = HTTP::Request->new(
    GET => 'http://127.0.0.1:' . $server_port . '/redirect7');
($reply, $error) = HTTPTest::run_test(
  $responder, $server_port, $request);
ok($reply, "got reply " . ($error || ''));
is($error || '', '');
is($reply && $reply->code(), $response_code);
is($reply && $reply->content(), $content);
is($reply && $reply->header("Content-type"), $content_type);

$request = HTTP::Request->new(
    GET => 'http://127.0.0.1:' . $server_port . '/redirect99');
($reply, $error) = HTTPTest::run_test(
  $responder, $server_port, $request);
ok(!$reply, "got error");
like($error || "", qr/redirect loop/i);
