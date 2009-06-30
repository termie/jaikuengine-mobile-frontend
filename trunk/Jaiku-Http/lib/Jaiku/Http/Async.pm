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

#
# An asynchronous HTTP client using Danga::Socket.
#
# SSL code based on DJabberd::Connection and DJabberd::Stanza::StartTLS
# by Brad Fitzpatrick (bradfitz@google.com).
#
# TODO(mikie): The SSL code is not totally understood by me and Brad says it's
# flaky. It doesn't have a certificate policy either.
#
package Jaiku::Http::Async;
use strict;
use fields qw(response_data request cb connection uri seen_urls);
use Time::HiRes;
use Jaiku::Http::DNSResolver;
use URI;

use vars qw{$VERSION};
$VERSION = "0.01";

# Takes an HTTP::Request and a callback, calls the callback with a
# HTTP::Response on success or undef and an error message on failure.
sub new {
  my ($class, $request, $cb, %opts) = @_;
  die "must supply a request" unless($request);
  die "must supply a callback" unless($cb);
  my $timeout = delete $opts{timeout};
  $timeout ||= 60;
  my $version = delete $opts{http_version};
  $version ||= "1.1";
  # Check for redirect loops.
  my $seen_urls = delete $opts{seen_urls};
  $seen_urls ||= { };
  die "unknown option " . (keys %opts)[0] if (%opts);
  my $uri = $request->uri();
  if ($seen_urls->{$uri->as_string()}) {
    $cb->(undef, "Redirect loop at " . $uri->as_string());
    return undef;
  }
  $seen_urls->{$uri->as_string()} = 1;
  $request->protocol("HTTP/$version");
  if ($uri->port() == 80) {
    $request->init_header('Host' => $uri->host());
  } else {
    $request->init_header('Host' => $uri->host_port());
  }
  $request->init_header('Connection' => 'close');

  my $content = $request->content();
  my $len = length($content);
  $request->init_header('Content-Length' => $len) if ($len);
  $request->init_header('User-Agent' => 'jaiku-http-async/0.1');
  my $host = $uri->host;

  my $self = fields::new($class);
  $self->{request} = $request;
  $self->{cb} = $cb;
  $self->{uri} = $uri;
  $self->{seen_urls} = $seen_urls;
  my $resolver = Jaiku::Http::DNSResolver->get();
  my $start_time = Time::HiRes::time();
  $resolver->resolve_a($host, sub {
      my ($endpoint, $error) = @_;
      my $elapsed = Time::HiRes::time() - $start_time;
      $self->_connect($endpoint, $error, $timeout - $elapsed);
  });

  return $self;
}

# After the DNS resolution, either tell the callback of an error in it or try
# connecting to the server.
sub _connect {
  my ($self, $endpoint, $error, $timeout) = @_;
  die "must specify timeout" unless($timeout);
  my $cb = $self->{cb};
  if (!$endpoint) {
    $cb->(undef, $error);
  } else {
    Jaiku::Http::Async::Connection->new(
        $endpoint->address(),
        $self->{request},
        $self->{cb},
        $self->{uri},
        $self->{seen_urls},
        $timeout);
  }
}

package Jaiku::Http::Async::Connection;
use strict;
use base 'Danga::Socket';
use fields (
    'request',      # HTTP::Request we'll send to the server
    'uri',          # URI of the request
    'headers',      # string: headers received
    'data',         # string: body received, in transfer-encoding
    'cb',           # subref to call on completion
    'state',        # connecting/connected for handling event_write
    'ssl',          # write_when_readable uri
    'response',     # Parsed HTTP::Response
    'body',         # parsed body
    'remain_in_chunk',  # how much we still expect for current chunk
    'chunked',      # bool: Transfer-Encoding: Chunked
    'length',       # integer: Content-Length
    'timer',        # Danga timer for timeout
    'seen_urls',    # hash containing URLs we've fetched, for redirect loop
                    # detection
    'start_time',   # time we started, so we can update timeout on redirect
    'timeout',      # when to give up
    'write_when_readable',  # SSL handshake state flag
);
use Crypt::SSLeay;
use HTTP::Response;
use IO::Handle;
use Net::SSLeay qw(die_now die_if_ssl_error);
use Socket;

Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

use constant POLLIN        => 1;
use constant POLLOUT       => 4;

use constant SSL_ERROR_WANT_READ     => 2;
use constant SSL_ERROR_WANT_WRITE    => 3;

sub new {
  my ($class, $ip, $request, $cb, $uri, $seen_urls, $timeout) = @_;
  die "must specify timeout" unless($timeout);

  my $sock;
  my $proto = getprotobyname('tcp');
  socket $sock, PF_INET, SOCK_STREAM, $proto;
  unless ($sock && defined fileno($sock)) {
      $cb->(undef, "Cannot alloc socket");
      return;
  }
  my $port = $uri->port();
  connect($sock, Socket::sockaddr_in($port, Socket::inet_aton($ip)));
  IO::Handle::blocking($sock, 0);

  my $self = $class->SUPER::new($sock);
  $self->watch_write(1);
  $self->{request} = $request;
  $self->{headers} = '';
  $self->{cb} = $cb;
  $self->{uri} = $uri;
  $self->{body} = '';
  $self->{seen_urls} = $seen_urls;
  $self->{start_time} = Time::HiRes::time();
  $self->{timeout} = $timeout;

  $self->{state} = "connecting";

  $self->{timer} = Danga::Socket->AddTimer(
      $timeout, sub {
          $self->_report_error("request timed out");
          $self->{timer} = undef;
          $self->close('timeout');
      }
  );

  return $self;
}

sub _report_error {
  my ($self, $msg) = @_;
  my $cb = $self->{cb};
  return unless ($cb);
  $cb->(undef, $msg);
  $self->{cb} = undef;
}

sub event_read {
  my Jaiku::Http::Async::Connection $self = shift;
  # For async SSL:  if a session renegotiation is in progress,
  # our previous write wants us to become readable first.
  # We then go back into the write path (by flushing the write
  # buffer) and it then does a read on this socket.
  if (my $ar = $self->{write_when_readable}) {
    $self->{write_when_readable} = 0;
    $self->watch_read($ar->[0]);  # Restore previous readability state.
    $self->watch_write(1);
    return;
  }

  my $bref;
  if (my $ssl = $self->{ssl}) {
    my $data = Net::SSLeay::read($ssl);

    my $errs = Net::SSLeay::print_errs('SSL_read');
    if ($errs) {
      $self->_report_error("SSL Read error: $errs");
      $self->close("SSL Read error: $errs");
      return;
    }

    # Net::SSLeays buffers internally, so if we didn't read anything, it's
    # in its buffer.
    return unless $data && length $data;
    $bref = \$data;
  } else {
    # Non-ssl mode.
    $bref = $self->read(20_000);
  }
  return $self->close('nothing from read') unless defined $bref;
  #print STDERR "READ $$bref\n";

  unless (defined($self->{data})) {
    # Still reading headers.
    $self->{headers} .= $$bref;
    if ($self->{headers} =~ /(.*?\r?\n\r?\n)(.*)/s) {
      # Found end of headers.
      $self->{headers} = $1;
      $self->{data} = $2;
      my $resp = HTTP::Response->parse($self->{headers});
      $self->{response} = $resp;
      my $encoding = $resp->headers->header('Transfer-Encoding');
      if ($encoding && $encoding =~ /\bchunked\b/i) {
        $self->{chunked} = 1;
        $self->{remain_in_chunk} = 0;
      } elsif (my $len = $resp->headers->header('Content-Length')) {
        $self->{length} = $len;
        if ($len == 0) {
          $self->done();
          return;
        }
      }
      $self->parse_body();
    }
  } else {
    # In the body
    $self->{data} .= $$bref;
    $self->parse_body();
  }
}

sub parse_body {
  my $self=shift;
  if ($self->{chunked}) {
    # Chunked encoding.
    my $remaining = $self->{remain_in_chunk};
    while (length($self->{data})) {
      if ($remaining < 0) {
        $self->_report_error("cannot parse chunked response");
        $self->close('cannot parse chunked response');
        return;
      }
      if ($remaining) {
        my $data = $self->{data};
        my $append = substr($data, 0, $remaining);
        $self->{body} .= $append;
        $self->{remain_in_chunk} -= length($append);
        substr($data, 0, length($append)) = '';
        $self->{data} = $data;
      }
      if ($self->{remain_in_chunk} == 0 && length($self->{data})) {
        $self->{data} =~ /^\r?\n?([0-9a-f]+[^\r\n]*)\r?\n(.*)/si || last;
        my $rest = $2;
        my $len = "0x" . $1;
        $len=oct($len);
        if ($len == 0) {
          $self->done();
          last;
        }
        $self->{remain_in_chunk} = $len;
        $self->{data} = $rest;
      }
      $remaining = $self->{remain_in_chunk};
    }
  } elsif(my $len = $self->{length}) {
    # Got Content-length from the server.
    if (length($self->{data}) >= $len) {
      $self->{body} = $self->{data};
      $self->done();
    }
  } else {
    # Just wait for the connection to close.
    $self->{body} .= $self->{data};
    $self->{data} = '';
  }
}

sub done {
  my $self = shift;
  return unless ($self->{cb});
  if (my $timer = delete $self->{timer}) {
    $timer->cancel();
  }
  $self->{response}->content($self->{body}) if ($self->{response});
  if (!defined($self->{response})) {
    $self->{cb}->(undef, "Unknown error (shouldn't get here)");
  } elsif ($self->{response}->is_redirect()) {
    my $location = $self->{response}->header("Location");
    if (!$location) {
      $self->{cb}->(undef, "Got a redirect with no Location");
    } else {
      my $location_uri;
      eval { $location_uri = URI->new($location); };
      if (!$location_uri) {
        $self->{cb}->(undef, "Got redirect but couldn't parse URI $location");
      } else {
        my $request = $self->{request};
        $request->uri($location_uri);
        my $elapsed = Time::HiRes::time() - $self->{start_time};
        Jaiku::Http::Async->new($request, $self->{cb},
                                seen_urls => $self->{seen_urls},
                                timeout => $self->{timeout} - $elapsed);
      }
    }
  } else {
    $self->{cb}->($self->{response});
  }
  $self->{cb} = undef;
}

sub close {
  my Jaiku::Http::Async::Connection $self = shift;
  my $msg = shift;
  if (my $timer = delete $self->{timer}) {
    $timer->cancel();
  }
  if ($self->{cb}) {
    # Not considered done yet.
    if ($self->{response} && !$self->{chunked} && !$self->{length}) {
      # No Content-length and no chunked: closing the connection is the correct
      # indication of end of body.
      $self->done();
    } else {
      $self->_report_error("Connection closed: $msg");
    }
  }
  if (my $ssl = $self->{ssl}) {
    Net::SSLeay::free($ssl);
    $self->{ssl} = undef;
  }
  $self->SUPER::close();
}

sub event_err {
  my ($self) = @_;
  if (defined($self->{response}) && !$self->{chunked} && !$self->{length}) {
    $self->done();
  } else {
    $self->_report_error("Connection closed");
  }
  $self->close();
}

sub event_hup {
  my ($self) = @_;
  $self->event_err();
}

sub event_write {
  my Jaiku::Http::Async::Connection $self = shift;
  if ($self->{state} eq "connecting") {
    $self->{state} = "connected";
    $self->on_connected();
  } else {
    if ($self->write(undef)) {
      $self->watch_write(0);
    }
  }
}

sub on_connected {
  my Jaiku::Http::Async::Connection $self = shift;

  if ($self->{uri}->scheme() eq "https") {
    $self->setup_ssl();
  }
  # Note that we must request watch_read() before
  # attempting to write, so that the request is remembered
  # when the SSL handshake ends.
  $self->watch_read(1);
  my $content = $self->{request}->content() || "";
  $self->{request}->content('');
  $self->{request}->uri(URI->new($self->{uri}->path_query()));
  my $to_write = $self->{request}->as_string("\r\n");
  # TODO(mikie): test encodings, check whether the decode() below is needed.
  utf8::decode($to_write);
  $to_write .= $content;
  $self->write($to_write);
  #print STDERR "WROTE $to_write\n";
}

sub starttls_socket_writerfunc {
  my ($conn) = @_;
  my $ssl = $conn->{ssl};
  return sub {
      my ($bref, $to_write, $offset) = @_;

      # Unless our event_read has been called, we don't want to try
      # to do any work now  and probably we should complain.
      # TODO(mikie): Should we error out here?
      if ($conn->{write_when_readable}) {
        warn "writer func called when we're waiting for readability first.\n";
        return 0;
      }

      my $str = substr($$bref, $offset, $to_write);
      my $written = Net::SSLeay::write($ssl, $str);

      if ($written == -1) {
        my $err = Net::SSLeay::get_error($ssl, $written);

        if ($err == SSL_ERROR_WANT_READ()) {
          $conn->write_when_readable;
          return 0;
        }
        if ($err == SSL_ERROR_WANT_WRITE()) {
          # unclear here.  it just wants to write some more?  okay.
          # easy enough.  do nothing?
          return 0;
        }

        # TODO(mikie): Report error to caller.
        my $errstr = Net::SSLeay::ERR_error_string($err);
        warn " SSL write err = $err, $errstr\n";
        Net::SSLeay::print_errs("SSL_write");
        $conn->close();
        return 0;
      }

      return $written;
  };
}


sub setup_ssl {
  my Jaiku::Http::Async::Connection $self = shift;

  my $ctx = Net::SSLeay::CTX_new();
  if (!$ctx) {
    $self->_report_error("Failed to create SSL_CTX $!");
    $self->close();
    return;
  }

  # TODO(mikie): Don't die on errors, report instead.
  $Net::SSLeay::ssl_version = 10;  # Insist on TLSv1
  Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
      and Net::SSLeay::die_if_ssl_error("ssl ctx set options");

  Net::SSLeay::CTX_set_mode($ctx, 1)  # enable partial writes
      and Net::SSLeay::die_if_ssl_error("ssl ctx set options");

  my $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
  $self->{ssl} = $ssl;

  my $fileno = $self->{sock}->fileno();
  Net::SSLeay::set_fd($ssl, $fileno);

  $Net::SSLeay::trace = 2;

  my $rv = Net::SSLeay::connect($ssl);
  if (!$rv) {
    $self->_report_error("SSL accept error on $self");
    $self->close();
    return;
  }

  $self->set_writer_func($self->starttls_socket_writerfunc())
}

# Called by Danga::Socket when a write doesn't fully go through.  by default it
# enables writability but we want to do nothing if we're waiting for a read for
# SSL.
sub on_incomplete_write {
  my ($self) = @_;
  return if $self->{write_when_readable};
  $self->SUPER::on_incomplete_write();
}

# called by SSL machinery to let us know a write is stalled on readability.
# so we need to (at least temporarily) go readable and then process writes.
sub write_when_readable {
  my $self = shift;

  # enable readability, but remember old value so we can pop it back
  my $prev_readable = ($self->{event_watch} & POLLIN) ? 1 : 0;
  $self->watch_read(1);
  $self->{write_when_readable} = [ $prev_readable ];

  # don't need to push/pop its state because Danga::Socket->write, called later,
  # will do the one final write, or if not all written, will turn on watch_write
  $self->watch_write(0);
}

1;
