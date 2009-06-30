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
# A caching DNS resolver.
# This module will follow CNAMEs and balance over multiple entries.
#
# Loosely based on DJabberd::DNS by Brad Fitzpatrick (bradfitz@google.com).
#
# Usage:
#   my $dns = Jaiku::Http::DNSResolver->get();
#   $dns->resolve_a(
#     "your_hostname",
#     sub { my ($result, $error) = @_; ... });
#
# The callback receives either the result as a Jaiku::Http::IPEndpoint object
# or if an error occurred it receives undef and an error description.
#
# This class keeps it alls it data by 'type' but only supports A lookups for
# now.

package Jaiku::Http::DNSResolver;
use strict;
use fields ('records',
            'failed',
            'timers',
            'cbs');
use Jaiku::Http::DNSLookup;
use List::Util;
use Time::HiRes;

use constant NO_DATA => 0;
use constant FAILED => 1;
use constant RECURSION_DEPTH_EXCEEDED => 2;

my $lookup_class = 'Jaiku::Http::DNSLookup';
my $timescale = 1;
my $default_random = sub { return rand(@_); };
my $random = $default_random;
my $resolver;

sub set_lookup_class {
  my ($new_class) = @_;
  $lookup_class = $new_class;
}

sub set_timescale {
  my ($new_timescale) = @_;
  $timescale = $new_timescale;
}

sub set_random {
  ($random) = @_;
  $random = $default_random unless($random);
}

sub get {
  $resolver ||= Jaiku::Http::DNSResolver->new();
  return $resolver;
}

sub new {
  my ($self) = @_;
  $self = fields::new($self) unless(ref($self));
  $self->{records} = { };
  $self->{failed} = { };
  $self->{timers} = { };
  return $self;
}

# Tries to resolve a single hostname to an IP address. Calls the callback with
# a Jaiku::Http::IPEndpoint or with undef and an error message.
# NOTE: if there are several simultaneous requests, the timeout and retransmit
# parameters will be taken from the first one.
sub resolve_a {
  my ($self, $hostname, $cb, %opts) = @_;
  my $type = "A";

  if ($hostname =~ /^\d+\.\d+\.\d+\.\d+$/) {
      # We already have the IP, lets not go looking it up.
      $cb->(Jaiku::Http::IPEndpoint->new_from_address($hostname));
      return;
  }
  if ($hostname =~ /^localhost(\.localdomain)?$/i) {
      # Resolve localhost directly so that we can run tests without network
      # TODO(mikie): use /etc/hosts instead. Q: what about non-unix?
      $cb->(Jaiku::Http::IPEndpoint->new_from_address("127.0.0.1"));
      return;
  }

  # We merge simultaneous requests for the same hostname to avoid unnecessary
  # DNS lookups and to return results as soon as the first one returns. The
  # pending callbacks are kept in $self->{cbs}->{$type}->{$hostname} and this
  # function is called recursively with $cb == undef when the callback has
  # already been stashed in there.
  if ($cb && $self->{cbs}->{$type}->{$hostname}) {
    push(@{$self->{cbs}->{$type}->{$hostname}}, $cb);
    return;
  }
  my $timeout = delete $opts{timeout};
  $timeout = 60.0 unless(defined($timeout));
  my $retransmit = delete $opts{retransmit};
  $retransmit = 4.0 unless(defined($retransmit));
  die "Unknown option " . (keys %opts)[0] if (%opts);
  my $existing = $self->get_record("A", $hostname);
  my ($result, $name) = @$existing;
  $| = 1;
  my $response;
  if (ref($result)) {
    my $endpoint = Jaiku::Http::IPEndpoint->new($result);
    $response = [ $endpoint ];
  } elsif ($result == RECURSION_DEPTH_EXCEEDED) {
    $response = [ undef, "Recursion limit exceeded for $hostname" ];
  } elsif ($result == FAILED) {
    $response = [ undef, "no such domain $hostname" ];
  } elsif ($timeout <= 0) {
    $response = [ undef, "$hostname lookup timed out" ];
  }

  if ($response) {
    my $cbs = delete $self->{cbs}->{$type}->{$hostname};
    $cb->(@$response) if ($cb);
    foreach my $cb (@$cbs) {
      $cb->(@$response);
    }
    return;
  }
  # NO_DATA
  # Note that this branch will get called several times if the lookup fails
  # and will only terminate if we receive a negative response (NXDOMAIN or no
  # data) or the timeout elapses.
  push(@{$self->{cbs}->{$type}->{$hostname}}, $cb) if ($cb);
  $name ||= $hostname;
  my $query_packet = Net::DNS::Packet->new($name, "A", "IN");
  my $start_time = Time::HiRes::time();
  my $lookup = $lookup_class->new(
    query_packet => $query_packet,
    callback => sub {
        my ($reply, $error) = @_;
        if ($reply) {
          $self->_handle_dns_reply("A", $name, $reply);
        }
        my $elapsed = Time::HiRes::time() - $start_time;
        $retransmit = List::Util::min($retransmit * 1.5, 45);
        $self->resolve_a(
          $hostname,
          undef,  # $cb == undef since it's been stashed away already.
          timeout => $timeout - $elapsed,
          retransmit => $retransmit);
    },
    timeout => List::Util::min($retransmit, $timeout),
  );
}

# Return a record for the given name if we have one, selecting randomly if
# there are several records. Returns [record/NO_DATA/FAILED, $name].
sub get_balanced_record {
  my ($self, $type, $name) = @_;
  die "Only A records supported" if ($type ne "A");
  return [FAILED(), $name] if ($self->{failed}->{$type}->{$name});
  my $records = $self->{records}->{$type}->{$name};
  return [NO_DATA, $name] unless($records && @$records);
  return [$records->[0], $name] if ($#{$records} == 0);
  my $index = int($random->($#{$records}));
  return [$records->[$index], $name];
}

# Return a record for the given name, following CNAMEs.
# Returns [record/NO_DATA/FAILED/RECURSION_DEPTH_EXCEEDED, deepest name]
# so that further CNAME lookups can be made by the caller on the missing name.
sub get_record {
  my ($self, $type, $name, $recursion) = @_;
  $recursion ||= 0;
  return [FAILED(), $name] if ($self->{failed}->{$type}->{$name});
  return [RECURSION_DEPTH_EXCEEDED(), $name] if ($recursion > 5);
  my $record = $self->get_balanced_record($type, $name);
  return $record unless(ref($record->[0]));
  if ($record->[0]->isa(qw(Net::DNS::RR::CNAME))) {
    $name = $record->[0]->cname();
    return $self->get_record($type, $name, $recursion + 1);
  }
  return $record;
}

sub _set_timer {
  my ($self, $type, $name, $ttl, $coderef) = @_;
  my $old_timer = delete $self->{timers}->{$type}->{$name};
  $old_timer->cancel() if ($old_timer);
  my $timer = Danga::Socket->AddTimer(
      $ttl * $timescale, sub {
          delete $self->{timers}->{$type}->{$name};
          $coderef->();
  });
  $self->{timers}->{$type}->{$name} = $timer;
}

sub _handle_dns_reply {
  my ($self, $type, $name, $reply) = @_;
  my @answer = $reply->answer();
  $self->insert_records($type, \@answer);
  my $header = $reply->header();
  # We implement a reasonable subset of the behaviour specified in RFC 2308
  # (Negative Caching of DNS Queries).
  if ($header->rcode() eq "NXDOMAIN" ||
      ($header->rcode() eq "NOERROR" && $#answer == -1)) {
    my $ttl = 60 * 60;
    my @soa = $reply->authority();
    my $soa;
    $soa = $soa[0] if (@soa);
    if ($soa && $soa->isa('Net::DNS::RR::SOA')) {
      $ttl = $soa->minimum();
    }
    $self->failed_query($type, $name, $ttl);
  }
}

# Insert DNS responses into the cache. Adds a timer to remove them after the
# TTL expires.
# TODO(mikie): A better design would be to remove the entries that have expired
# when we try to read them: easier to get correct if we read the same record
# again somewhere.
sub insert_records {
  my ($self, $type, $records) = @_;
  die "Only A records supported" if ($type ne "A");
  my @filtered_records = grep {
      $_->isa('Net::DNS::RR::CNAME') ||
      $_->isa('Net::DNS::RR::A') } @$records;
  my %results;
  foreach my $r (@filtered_records) {
    push(@{$results{$r->name()}}, $r);
  }
  foreach my $name (keys %results) {
    $self->{records}->{$type}->{$name} = $results{$name};
    delete $self->{failed}->{$type}->{$name};
    my $ttl = $results{$name}->[0]->ttl();
    $self->_set_timer($type, $name, $ttl, sub {
        delete $self->{records}->{$type}->{$name}
    });
  }
}

# Mark a name as failed. Only to be called on NXDOMAIN or no data.
sub failed_query {
  my ($self, $type, $name, $ttl) = @_;
  $self->{failed}->{$type}->{$name} = 1;
  delete $self->{records}->{$type}->{$name};
  $self->_set_timer($type, $name, $ttl, sub {
      delete $self->{failed}->{$type}->{$name}
  });
}

1;

package Jaiku::Http::IPEndpoint;

use strict;

sub new {
  my ($class, $rr) = @_;
  return bless [ $rr->address(), 0 ], $class;
}

sub new_from_address {
  my ($class, $address) = @_;
  return bless [ $address, 0 ], $class;
}

sub address {
  my ($self) = @_;
  return $self->[0];
}

sub port {
  my ($self) = @_;
  return $self->[1];
}

1;
