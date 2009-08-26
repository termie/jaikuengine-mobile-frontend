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
# Base module for Jaiku API calls.

package Jaiku::API;
use strict;
use Data::Dumper;
use Devel::Peek;
use Digest::SHA1;
use fields qw(
    base_url consumer_key consumer_secret token_key
    token_secret async_http domain);
use HTTP::Request;
use JSON;
use Net::OAuth;
use utf8;

use vars qw($VERSION);
$VERSION = "0.1";

my $json = JSON->new();

# Create a new API object.
# Parameters:
#   base_url => a URI object that has the correct schema, host and port for the
#               server
#   domain => the JaikuEngine domain, defaults to jaiku.com
#   consumer_key and _secret => OAuth consumer data
#   token_key and _secret    => OAuth access token data
#   async_http => a coderef that takes a HTTP::Request and a callback
#                 and calls the callback with an HTTP::Response or
#                 undef and an error message on completion of HTTP request.
#                 Optional, but needed for making actual calls.
sub new {
  my ($self, %opts) = @_;
  $self = fields::new($self) unless(ref($self));
  foreach my $f (qw(base_url consumer_key consumer_secret token_key
                    token_secret)) {
    die "Must specify $f" unless($opts{$f});
    $self->{$f} = delete $opts{$f};
  }
  foreach my $f (qw(async_http)) {
    $self->{$f} = delete $opts{$f};
  }
  $self->{domain} = delete $opts{domain} || 'jaiku.com';
  die "Unknown option " . (keys(%opts))[0] if (%opts);
  $self->{base_url}->path('/api/json');

  return $self;
}

sub clone {
  my ($self, %overrides) = @_;
  my %opts;
  foreach my $f (qw(base_url consumer_key consumer_secret token_key
                    token_secret async_http domain)) {
    $opts{$f} = $self->{$f};
  }
  foreach my $key (keys %overrides) {
    $opts{$key} = $overrides{$key};
  }
  return Jaiku::API->new(%opts);
}

# Takes a HTTP method and a set of parameters (key-value pairs) and returns an
# OAuth-authenticated request as an HTTP::Request.
sub request_from_method_and_parameters {
  my ($self, $method, %params) = @_;
  my $url = $self->{base_url}->as_string();
  my $timestamp = delete $params{timestamp} || time();
  my $nonce = delete $params{_nonce} ||
      Digest::SHA1::sha1_hex(rand() . rand() .  rand());;
  my $use_json = 1;
  if (defined($params{use_json_params})) {
    $use_json = delete $params{use_json_params};
  }
  foreach my $key (keys %params) {
    if (!defined($params{$key}) ||
        $params{$key} eq '') {
      delete $params{$key};
    }
  }
  my $nick = delete $params{nick};
  if ($nick) {
    if ($nick !~ /\@/) {
      $nick .= '@' . $self->{domain};
    }
    $params{nick} = $nick;
  }
  if ($use_json) {
    my $jsonified = $json->encode(\%params);
    %params = ( json_params => $jsonified );
  }
  my $oauth_request = Net::OAuth->request('protected resource')->new(
      consumer_key => $self->{consumer_key},
      consumer_secret => $self->{consumer_secret},
      token => $self->{token_key},
      token_secret => $self->{token_secret},
      request_url => $url,
      request_method => $method,
      signature_method => 'HMAC-SHA1',
      timestamp => $timestamp,
      nonce => $nonce,
      extra_params => \%params,
  );
  $oauth_request->sign();

  my $request;
  if ($method eq "GET") {
    $request = HTTP::Request->new($method => $oauth_request->to_url());
  } elsif ($method eq "POST") {
    $request = HTTP::Request->new($method => $self->{base_url});
    $request->content($oauth_request->to_post_body());
  } else {
    die "Unsupported http method $method";
  }
  #print STDERR "sending " . $request->as_string() . "\n";
  return $request;
}

# Takes a HTTP::Response and an error string, checks the response for success
# and if successful, parses the content of the response as JSON. Returns the
# parsed perl hashref or undef and an error on failure.
sub parse_response {
  my ($self, $response, $error, $request_string) = @_;
  #print STDERR $response->as_string();
  return (undef, $error) unless($response);
  return (undef, "Request failed: " . $response->as_string() .
                 " for request " . $request_string)
     unless($response->is_success());

  my $body = $response->content();
  return (undef, "No content") unless($body && length($body));

  my $parsed;
  eval { $parsed = $json->decode($body); };
  return (undef, "Failed to parse json from " . $body . " $!" .
                 " for request " . $request_string)
               unless ($parsed);
  #print STDERR "REQUEST $request_string\n";
  #print STDERR "RESPONSE " . Dumper($parsed);

  return $parsed;
}

# Makes a Jaiku API call.
# Parameters:
#   http_method => GET/POST (optional, default: GET)
#   callback => called on completion with the parsed response or undef and
#               an error message
#   any parameters for the api call (should at least contain 'method')
sub call {
  my ($self, %params) = @_;
  my $http_method = (delete $params{http_method} || "GET");
  my $callback = delete $params{callback};
  die "Must specify callback function" unless($callback);
  my $async_http = $self->{async_http} || die "No async_http function set";
  my $request = $self->request_from_method_and_parameters($http_method, %params);
  my $request_string = $request->as_string();

  $self->{async_http}->(
    $request,
    sub {
      my ($response, $error) = @_;
      my $parsed;
      ($parsed, $error) = $self->parse_response($response, $error, $request_string);
      if ($parsed && $parsed->{status} ne 'ok') {
        $error ||= '';
        $error .= " " . $parsed->{message} . " (code: " . $parsed->{code} .
            ")";
      }
      $callback->($parsed, $error);
    }
  );
}

sub actor_get {
  my ($self, %params) = @_;
  my $callback = delete $params{callback};
  die "Must specify callback function" unless($callback);
  my $nick = delete $params{nick};
  die "Must specify nick" unless($nick);
  $self->call(
      callback => $callback,
      method => 'actor_get',
      nick => $nick);
}

sub post {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify message" unless($params{message});
  $params{http_method} = 'POST';
  $params{method} = 'post';
  $self->call(%params);
}

sub entry_add_comment_with_entry_uuid {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify content" unless($params{content});
  die "Must specify entry_uuid" unless($params{entry_uuid});
  $params{http_method} = 'POST';
  $params{method} = 'entry_add_comment_with_entry_uuid';
  $self->call(%params);
}

sub entry_get_comments_with_entry_uuid {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify entry_uuid" unless($params{entry_uuid});
  $params{http_method} = 'GET';
  $params{method} = 'entry_get_comments_with_entry_uuid';
  $self->call(%params);
}

sub entry_get_comments {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify entry" unless($params{entry});
  $params{http_method} = 'GET';
  $params{method} = 'entry_get_comments';
  $self->call(%params);
}


sub keyvalue_put {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  die "Must specify keyname" unless($params{keyname});
  die "Must specify value" unless($params{value});
  $params{http_method} = 'POST';
  $params{method} = 'keyvalue_put';
  $self->call(%params);
}

sub keyvalue_get {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  die "Must specify keyname" unless($params{keyname});
  $params{method} = 'keyvalue_get';
  $self->call(%params);
}

sub keyvalue_prefix_list {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  die "Must specify keyname" unless($params{keyname});
  $params{method} = 'keyvalue_prefix_list';
  $self->call(%params);
}

sub presence_set {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  $params{http_method} = 'POST';
  $params{method} = 'presence_set';
  $self->call(%params);
}

sub presence_get {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  $params{method} = 'presence_get';
  $self->call(%params);
}

sub presence_get_contacts {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  $params{method} = 'presence_get_contacts';
  $self->call(%params);
}

sub user_authenticate {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  die "Must specify nonce" unless($params{nonce});
  die "Must specify digest" unless($params{digest});
  $params{method} = 'user_authenticate';
  $self->call(%params);
}

sub entry_get_actor_overview_since {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  $params{method} = 'entry_get_actor_overview_since';
  $self->call(%params);
}

sub actor_get_contacts_avatars_since {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify nick" unless($params{nick});
  $params{method} = 'actor_get_contacts_avatars_since';
  $self->call(%params);
}

sub get_avatar() {
  my ($self, %params) = @_;
  die "Must specify callback function" unless($params{callback});
  die "Must specify url" unless($params{url});
  my $callback = $params{callback};
  my $url = $params{url};
  my $image_url = $self->{base_url}->clone();
  $image_url->path('/image/' . $url . '_f.jpg');
  my $request = HTTP::Request->new('GET' => $image_url);
  $self->{async_http}->(
    $request,
    sub {
      my ($response, $error) = @_;
      my $data;
      if ($response && !$response->is_success()) {
        $error .= "Request failed: " . $response->as_string();
      } else {
        $data = $response->content();
      }
      $callback->($data, $error);
    }
  );
}

sub get_geolocation() {
  my ($self, %params) = @_;
  my $lang = delete $params{lang} || "en_GB";
  my $cellid = {};
  foreach my $cellid_part (qw(cell_id location_area_code mobile_country_code
                              mobile_network_code)) {
    die "must specify $cellid_part" unless (defined($params{$cellid_part}));
    $cellid->{$cellid_part} = delete $params{$cellid_part};
  }
  die "Must specify callback function" unless($params{callback});
  my $callback = delete $params{callback};

  my $request_body = {
    version => '1.0',
    host => 'mobile-fe.jaiku.com',
    radio_type => "gsm",
    request_address => JSON::true,
    address_language => $lang,
    cell_towers => [ $cellid ],
  };
  
  my $jsonified = $json->encode($request_body);
  my $url = "http://www.google.com/loc/json";
  
  my $request = HTTP::Request->new(POST => $url);
  $request->content($jsonified);

  $self->{async_http}->(
    $request,
    sub {
      my ($response, $error) = @_;
      my $data;
      if ($response && !$response->is_success()) {
        $error .= "Request failed: " . $response->as_string();
      } else {
        my $body = $response->content();
        eval { $data = $json->decode($body); };
        $error = "Failed to parse json from $body $!";
      }
      $callback->($data, $error);
    }
  );
}

1;
