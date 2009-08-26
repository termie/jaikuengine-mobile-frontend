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
# DJabberd Plugin that stores presence received from the Jaiku S60 client into
# the Jaiku-on-appengine backend.

package DJabberd::Jaiku::PresenceDb;
use strict;
use base 'DJabberd::Plugin';
use warnings;
use DJabberd::Jaiku::Transforms;
use DJabberd::XMLParser;
use Data::Dumper;
use Jaiku::BBData::SAXHandler;
use Jaiku::BBData::Presence;

our $logger = DJabberd::Log->get_logger();

sub register {
  my ($self, $vhost) = @_;
  my $presence_cb = sub {
    my ($vh, $cb, $stanza) = @_;
    unless ($stanza->isa("DJabberd::Presence")) {
      $cb->decline;
      return;
    }
    my $jid = $stanza->from_jid;
    # The S60 client sets resource to 'Context'.
    if ($jid && $jid->resource eq "Context" &&
           ( ($stanza->type || "available") eq "available") ) {
      $self->store_presence($jid, $stanza, $cb, $vhost);
    } else {
      $cb->decline;
    }
  };
  $vhost->register_hook("switch_incoming_client", $presence_cb);
}

my $parsed_element;
my $saxhandler = Jaiku::BBData::SAXHandler->new(sub {
    $parsed_element = $_[0]->[0]; });

sub store_presence {
  my ($self, $jid, $stanza, $cb, $vhost)=@_;

  # The S60 client sends the structured presence info in the 'status' element
  # of the presence stanza. The status element contains a timestamp + XML
  # (escaped). We need to get the status element contents, split the timestamp
  # and parse the XML into a Jaiku::BBData::Presence object.

  my $status_elem;
  foreach my $child ($stanza->children()) {
    my ($ns, $name) = $child->element();
    if ($name eq "status") {
      $status_elem = $child;
      last;
    }
  }
  if (! $status_elem) {
    return $cb->decline();
  }
  my $content = join("", $status_elem->children());
  $content =~ s/^\s+//;
  $content =~ s/\s+$//;
  my ($timestamp, $presence_xml);
  if ($content =~ /(\d{8}T\d{6})(<.*>)/) {
    ($timestamp, $presence_xml) = ($1, $2);
  } else {
    return $cb->decline();
  }

  my $parser = DJabberd::XMLParser->new(Handler => $saxhandler);
  $parsed_element = undef;
  $parser->parse_chunk($presence_xml);
  $parser->finish_push();

  if (!$parsed_element) {
    $cb->decline();
    return $cb->stop_chain();
  }

  my $presence = Jaiku::BBData::Presence->downbless($parsed_element);
  my $api = DJabberd::Jaiku::API->get($vhost);

  # HACK
  # We don't want to parse the presence more than once but the connection
  # wants to handle the parsed data too. However, it may not actually
  # have the method so let's trap errors.
  my $conn = $vhost->find_jid($jid);
  eval { $conn->handle_parsed_presence($presence, $api); };
  $logger->warn($@) if ($@);

  my $api_handler = sub {
    my ($parsed, $error) = @_;
    if ($error) {
      $logger->warn("Error storing presence $error");
    }
    if (!$parsed || $parsed->{status} ne 'ok') {
      $cb->decline($error);
    }
    return $cb->stop_chain();
  };
  my $for_api = DJabberd::Jaiku::Transforms::presence_to_api(
      $presence->as_parsed());
  $for_api->{senders_timestamp} = $timestamp;
  # We deliberately use only the node of the JID to make testing easier (so
  # that the domain that DJabberd thinks it runs under doesn't have to match
  # 'jaiku.com').
  # TODO(mikie): fix this if we want to support several domains on the same
  # backend.
  $api->presence_set(
      callback => $api_handler,
      nick => $jid->node(),
      %$for_api);
}

1;
