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
use Test::More tests => 4;
use HTTP::Response;
use HTTP::Status;
use lib 't/lib';
use HTTPTest;

my $response_code = 200;
my $content = "<html><head><title>Hi<body>Hi!";
my $content_type = "text/html";
my $server_port = 10080;

# HTTP::Daemon sends a chunked reply if the content field of the response is a
# coderef. The coderef is called until it returns undef, and each return
# becomes a chunk in the reply.
my $responder = sub {
  my ($conn, $request) = @_;
  my $offset = 0;
  my $chunk_length = 10;
  my $response = HTTP::Response->new(
      $response_code,
      "OK",
      [ "Content-type", $content_type ],
      sub {
        my $ret = substr($content, $offset, $chunk_length);
        $offset += $chunk_length;
        return $ret;
      }
  );
  if ($request->method() eq 'GET') {
    $conn->send_response($response);
  } else {
    $conn->send_error(RC_FORBIDDEN)
  }
};

my $request = HTTP::Request->new(
    GET => 'http://127.0.0.1:' . $server_port . '/');

my ($reply, $error) = HTTPTest::run_test(
  $responder, $server_port, $request);

ok($reply, "got reply " . ($error || ""));
is($reply->code(), $response_code);
is($reply->content(), $content);
is($reply->header("Content-type"), $content_type);
