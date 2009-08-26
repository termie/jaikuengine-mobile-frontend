package DJabberd::Connection::ClientIn;
use strict;
use base 'DJabberd::Connection';
use Jaiku::Tuple::UserGiven;
use Jaiku::MessageQueue::Client;
#use Jaiku::Tuple::UserPic;
use Jaiku::Presence;
use DJabberd::Util qw(exml);
#use Devel::StackTrace;
use Jaiku::XMLSplit;
use Jaiku::RawXML;
use Data::Dumper;
use XML::Simple;
use Jaiku::Tuple::FeedItem;
use Jaiku::Stream;
use Jaiku::BBData::All;
use Data::UUID;
use Digest::MD5;
use Jaiku::Tuple::ThreadRequest;
use Jaiku::Tuple::ThreadRequestReply;
use Jaiku::Tuple::GivenCityName;
use Jaiku::Tuple::GivenCellName;

use fields (
            # {=server-needs-client-wanted-roster-state}
            'requested_roster',      # bool: if user has requested their roster,

            'got_initial_presence',  # bool: if user has already sent their initial presence
            'is_available',          # bool: is an "available resource"
            'directed_presence',     # the jids we have sent directed presence too
            'pend_in_subscriptions', # undef or arrayref of presence type='subscribe' packets to be redelivered when we become available
            'queued_presences',      # presences we will send to the client on 'resume'
            'queued_tuples',         # tuples that will be send batched
            'last_sent',             # what was the last presence we sent to the client
            'is_suspended',
            'last_presence',         # what we will re-send on keepalive
            'clientversion',
            'device_id',
            'messagequeue',
            'pline_tupleid',
            'id_by_tupleid', 'int_id',
            'waiting_on_initial_pline', 'pline_timer', 'sent_mc2',
            'auth_params',
            'geo_in_flight',
            );

#my %connections_by_deviceid=();

sub note_pend_in_subscription {
    my ($self, $pres_packet) = @_;
    if ($self->is_available) {
        # can send it now if we're online
        $pres_packet->deliver($self->vhost);
    } else {
        # keep it on a list and deliver it later, when we get initial presence
        push @{$self->{pend_in_subscriptions} ||= []}, $pres_packet;
    }
}

sub directed_presence {
    my $self = shift;
    return keys %{$self->{directed_presence}};
}

sub add_directed_presence {
    my ($self, $to_jid) = @_;
    ($self->{directed_presence} ||= {})->{$to_jid} = 1;
}

sub clear_directed_presence {
    my $self = shift;
    delete $self->{directed_presence};
}

sub requested_roster {
    my $self = shift;
    return $self->{requested_roster};
}

sub set_requested_roster {
    my ($self, $val) = @_;
    $self->{requested_roster} = $val;
}

sub set_available {
    my ($self, $val) = @_;
    $self->{is_available} = $val;
}

sub is_available {
    my $self = shift;
    return $self->{is_available};
}

# called when a presence broadcast is received.  on first time,
# returns tru.
sub is_initial_presence {
    my $self = shift;
    return 0 if $self->{got_initial_presence};
    return $self->{got_initial_presence} = 1;
}

sub supports_buddyimg {
    return ( ($_[0]->{clientversion} || 0) > 1);
}

sub hash {
    return Digest::MD5::md5_hex( shift() );
}

use Jaiku::HTTPClient;
use Flickr::API;

sub photoid_request {
    my $photoid=shift;
    $photoid=~s/photoid//;
    $photoid=~s/[:]+//g;
    $photoid=~s!/!!g;
    if ($photoid ne "") {
        return new Flickr::API::Request({
            method=>'flickr.photos.getSizes',
            args=> { photo_id=>$photoid } } );
    }
}

sub photoid_info_request {
    my $photoid=shift;
    $photoid=~s/photoid//;
    $photoid=~s/[:]+//g;
    $photoid=~s!/!!g;
    if ($photoid ne "") {
        return new Flickr::API::Request({
            method=>'flickr.photos.getInfo',
            args=> { photo_id=>$photoid } } );
    }
}

sub send_photoid {
    my $self=shift;
    my $msg=shift;
    my $photoid=shift;
    my $request=photoid_request($photoid);

    if ( $request ) {
        my $flickr_client=Jaiku::HTTPClient::get_client;
        $flickr_client->flickr_request($request, sub { $self->send_from_photoid($msg, @_); });
    } else {
        $self->send_from_photoid($msg);
    }
}

sub small_from_response {
    my $resp=shift;
    return undef unless($resp);
    my $url;

    eval {
        my @sizes=grep { $_->{name} eq "sizes" } @{$resp->{tree}->{children}};
        @sizes=grep { $_->{name} eq "size" } @{$sizes[0]->{children}};
        my @small=grep { $_->{attributes}->{label} eq "Small" } @sizes;
        $url=$small[0]->{attributes}->{source};
    };
    return $url;
}

sub photopage_from_response {
    my $resp=shift;
    return undef unless($resp);
    my $url;

    eval {
        my @photo=grep { $_->{name} eq "photo" } @{$resp->{tree}->{children}};
        my @urls=grep { $_->{name} eq "urls" } @{$photo[0]->{children}};
        @urls=grep { $_->{name} eq "url" } @{$urls[0]->{children}};
        my @page=grep { $_->{attributes}->{type} eq "photopage" } @urls;
        $url=$page[0]->{children}->[0]->{content};
    };
    return $url;
}


sub send_from_photoid {
    my $self=shift;
    my $msg=shift;
    my $resp=shift;
    my $url=small_from_response($resp);

    if ($url) {
        $self->response("url $url");
    }
    eval { DJabberd::Connection::JaikuPresence::handle_presenceline(
            $self, $self->bound_jid->node . " " . $msg . $url); };
    $self->response($@) if ($@);
}

sub connect_to_messagequeue {
    my $self=shift;
    die "has not authenticated" unless ($self->{auth_params});
    #print STDERR "CONNECTING " . $self->bound_jid->node . "\n";
    return if ($self->{messagequeue});
    $self->{device_id}="" .
        hash($self->bound_jid->as_string) unless($self->{device_id});

#    if (exists $connections_by_deviceid{$self->{device_id}}) {
#       $self->log->info("closing previous instance of " .
#                       $self->bound_jid . " : " . $self->{device_id});
#       $connections_by_deviceid{$self->{device_id}}->close();
#    }
#    $connections_by_deviceid{$self->{device_id}}=$self;
    my @features=('TEST');
    if ( $self->supports_buddyimg() ) {
        push(@features, 'BUDDYIMG');
    }
    if ( $self->supports_presence() ) {
        push(@features, 'PRESENCE');
    }
    if ( $self->supports_presenceline_sync() ) {
        push(@features, 'PLINE');
    }
    if ( $self->supports_feed() ) {
        push(@features, 'FEED');
    }
    if ( $self->supports_channels() ) {
        push(@features, 'CHANNEL');
    }

    $self->{sent_mc2}=1;

    $self->{messagequeue}=Jaiku::MessageQueue::Client::get_client;
    #print STDERR "connecting to mqueue with id " . $self->server->{c2s_port} . "\n";
    $self->{messagequeue}->connected( $self->server->{c2s_port},
        $self->bound_jid->node, $self->{device_id}, \@features,
        $self, $self->{clientversion}, $self->{auth_params} );
    #}
    if ( $self->supports_messagecount2() ) {
        $self->messagecount2(0);
    }
}

sub supports_persistent_presence() {
    return ( ($_[0]->{clientversion} || 0) >= 3);
}
sub supports_feed() {
    return ( ($_[0]->{clientversion} || 0) >= 5 || ($_[0]->bound_jid->resource ne "Context") );
}
sub supports_channels() {
    return ( $_[0]->bound_jid->resource ne "Context" );
}

sub supports_presence {
    return ( ! ($_[0]->bound_jid->resource =~ /bot$/) );
}

sub supports_servertime() {
    return ( ($_[0]->{clientversion} || 0) >= 6);
}
sub send_servertime() {
    my $self=shift;
    my $time=new Jaiku::BBData::Time("servertime");
    $time->set_value(Jaiku::Presence::current_timestamp());
    $time->set_type_attributes;
    $self->write($time->as_xml);
}

sub on_initial_presence {
    my $self = shift;
    unless ( $self->supports_persistent_presence() ) {
        #$self->send_presence_probes;
    }
    $self->send_pending_sub_requests;
    $self->send_presenceline_to_client;
    $self->connect_to_messagequeue;
    unless ($self->{clientversion}) {
        $self->on_clientversion;
    }

    $self->vhost->hook_chain_fast('OnInitialPresence',
                                  [ $self ], {});
}

sub presence_type_attr {
    return "xmlns='http://www.cs.helsinki.fi/group/context' id='" .
        Jaiku::Presence::TypeID . "' major_version='" .
        Jaiku::Presence::TypeVersion . "' minor_version='0' module='" .
        Jaiku::Presence::TypeUID . "'";
}

sub response {
        my $self=shift;
        $self->send_message(@_);
}

my %icons;

sub send_message {
        my $self=shift;
        my $text=shift;
        my $link=shift;
        my $icon=shift;
        my $thumbnail=shift;
        my $tuple=shift;

        my $stanza;
        my $xml = DJabberd::XMLElement->new("", "message", { type=>"chat" },
            []);
        $stanza=DJabberd::Message->downbless($xml);
        my $jid=new DJabberd::JID('jaiku@jaiku.com/Server');
        $stanza->set_from($jid);
        $stanza->set_to($self->bound_jid);
        my $body=DJabberd::XMLElement->new("", "body", { },
                [ $text ]);
        $stanza->push_child($body);

        if ($link || $icon || $thumbnail ) {
                my $hbody=DJabberd::XMLElement->new("http://www.w3.org/1999/xhtml", "body", { }, [ ]);
                my $html=DJabberd::XMLElement->new("http://jabber.org/protocol/xhtml-im", "html",
                        { }, [ $hbody ]);
                if (0 && $icon) {
                        my $name=$icons{$icon};
                        unless ($name) {
                                my $jaiku=Jaiku::logical_to_db("jaiku");
                                ($name)=Jaiku::dbh("jaiku")->selectrow_array(
                                        "SELECT url FROM $jaiku.icon WHERE id=?", undef, $icon);
                                $name="eiole" unless ($name);
                                $icons{$icon}=$name;
                        }
                        unless ($name eq "eiole") {
                                my $img=DJabberd::XMLElement->new("", "img", {
                                        src => "http://jaiku.com/images/icons/$name" }, [ ]);
                                $hbody->push_child($img);
                        }
                }
                if (0 && $thumbnail) {
                        my $img=DJabberd::XMLElement->new("", "img", {
                                src => $thumbnail }, [ ]);
                        $hbody->push_child($img);
                }
                my $main_html;
                if ($link) {
                        $main_html=DJabberd::XMLElement->new("", "a",
                                { href=>$link }, [ $text ]);
                } else {
                        $main_html=$text;
                }
                $hbody->push_child($main_html);
                $stanza->push_child($html);
        }
        $stanza->push_child($tuple) if ($tuple);
        $self->write($stanza->as_xml);

}

sub got_message {
    my $self=shift;
    my $tuple=shift;
    #print STDERR "GOT_MESSAGE " . $tuple->as_xml . "\n";

    if (! $tuple->data ) {
        $self->acked($tuple->tupleid->value);
        return;
    }

    if ($self->bound_jid->resource eq "Context" && $self->{clientversion}<7) {
        my $data=$tuple->data->{data};
        $data=~s/\t/ /g;
        $tuple->data->{data}=$data;
    }

    if ($tuple->tuplemeta->moduleuid->value==Jaiku::Presence::UID &&
        $tuple->tuplemeta->moduleid->value==Jaiku::Presence::ID) {
        #print STDERR "PRESENCE " . $tuple->as_xml . "\n";

        unless ( $self->supports_persistent_presence() ) {
                my $stanza;
                my $jid=new DJabberd::JID($tuple->tuplemeta->subname->value . '@jaiku.com/Context');
                eval { $stanza=DJabberd::Presence->available( 
                        from=>$jid); };
                if ($@) { print STDERR $@; }
                $stanza->set_to($self->bound_jid);
                my $status=$tuple->data->as_xml;
                $stanza->push_child( new DJabberd::XMLElement("", "status", {}, [ $status ]) );
                $self->send_stanza($stanza);
                $self->{messagequeue}->acked($self->bound_jid->node, $self->{device_id}, 
                        0);
        } else {
                $self->replace_tupleid($tuple);
                $self->send_stanza($tuple);
                return;
                my $status=$tuple->data->as_xml;
                #$self->log->info("PRESENCE RAW1 $status");
                #print STDERR "PRESENCE RAW2 $status\n";
                my $ts=substr($status, 0, 15);
                my $xml=substr($status, 15);
                #print STDERR "PRESENCE XML $xml\n";
                $xml=~s/presencev2/tuplevalue/g;
                my $type=presence_type_attr();
                $xml=~s/<tuplevalue>/<tuplevalue $type>/;
                my $timestamp="<sent>" . $ts . "</sent>";
                $xml=~s!</tuplevalue>!$timestamp</tuplevalue>!;
                #$self->log->info("PRESENCE new $xml");
                $tuple->set_data( new Jaiku::RawXML($xml) );
                $tuple->tuplemeta->subname->set_value($tuple->tuplemeta->subname->value . '@jaiku.com');
        }
    } elsif (Jaiku::Tuple::UserGiven::is_usergiven($tuple->tuplemeta->moduleuid->value,
                $tuple->tuplemeta->moduleid->value)) {
              if ($self->{last_presence} && $self->{last_presence}->stanza()) {
                #print STDERR "LAST PRESENCE 1" .  $self->{last_presence}->stanza()->as_xml() . "\n";
              }
              #print STDERR "GOT_USERGIVEN " . $tuple->as_xml . "\n";
        $self->replace_tupleid($tuple);
        my $not_avail_yet=0;
        my $prev_id=$self->{pline_tupleid};
        my $new_id=$tuple->tupleid->value;
        $self->{pline_tupleid}=$new_id;
        if ($prev_id && $new_id != $prev_id) {
            $self->acked($prev_id);
        } else {
            if ($prev_id) { $self->acked(0); }
        }
        unless ( $self->{last_presence} ) {
            $self->{last_presence}=new Jaiku::Presence;
            $not_avail_yet=1;
        }
        $self->{last_presence}->set_status_from_usergiven(
                $tuple->data->as_xml );
        if ($self->{last_presence}->stanza()) {
          #print STDERR "LAST PRESENCE 2" .  $self->{last_presence}->stanza()->as_xml() . "\n";
        }
        $self->send_from_presenceline( $not_avail_yet );
    } elsif (Jaiku::Tuple::FeedItem::is_feeditem($tuple->tuplemeta->moduleuid->value,
                $tuple->tuplemeta->moduleid->value)) {
        #print STDERR "FEEDITEM TO " . $self->bound_jid . "\n";
        my $type_id=$tuple->data->as_xml;
        $type_id=~/id=.(\d+)/;
        $type_id=$1;
        if ( $self->bound_jid->resource eq "Context") {
            $self->replace_tupleid($tuple);
            eval {
            #print STDERR "TYPE ID $type_id\n";
            if ($type_id==56 || $type_id==57) {
                    my $row=XMLin($tuple->data->as_xml);
                    foreach my $k (keys %$row) {
                        $row->{$k}="" if (ref $row->{$k});
                    }
                    if ($type_id==56) {
                        $tuple->set_data(Jaiku::Stream::streamdata_to_feeditem($row));
                    } else {
                        $tuple->set_data(Jaiku::Stream::streamcomment_to_feeditem($row));
                    }
            }
            };
            if ($@) { print STDERR $@; $self->logger->warn($@); $self->acked($tuple->tupleid->value); }
            else { $self->send_or_queue_tuple($tuple); }
            return;
        }
        
        $self->log->info("Sending feeditem as message to " . $self->bound_jid || "");
        eval {
        my $parsed=XMLin($tuple->data->as_xml);
        $parsed->{location}=$parsed->{content} if ($parsed->{kind} eq "presence");
        foreach my $k ( qw(content title authornick location postauthornick posttitle channelname) ) {
            delete $parsed->{$k} if (ref $parsed->{$k} eq "HASH");
            delete $parsed->{$k} if ($parsed->{$k} eq "");
        }
        if ($type_id==56) { $parsed->{content}=$parsed->{title}; }
        unless ($parsed->{content} ) { $parsed->{content}=$parsed->{title}; }
        my $text = $parsed->{authornick} . ": " . 
                $parsed->{content};

        $text .= " @" . $parsed->{postauthornick} if ($parsed->{postauthornick});
        $text .= " ('" . $parsed->{posttitle} . "')" if ($parsed->{posttitle});
        $text .= " on " . $parsed->{channelname} if ($parsed->{channelname});
        $text .= " in " . $parsed->{location} if ($parsed->{location});
                $self->replace_tupleid($tuple);
        $self->send_message($text, $parsed->{linkedurl}, $parsed->{iconid}, $parsed->{thumbnailurl}, $tuple);

        $self->acked($tuple->tupleid->value);
        };
        if ($@) {
            $self->acked($tuple->tupleid->value);
            $self->log->warn($@) if ($@);
        }
    } else {
        #print STDERR "TUPLE TO " . $self->bound_jid . "\n";
        #$self->log->info("Sending tuple " . $tuple->as_xml . " to " . $self->bound_jid || "");
            $self->replace_tupleid($tuple);
        $self->send_or_queue_tuple($tuple);
    }
}

sub handle_parsed_presence {
  my ($self, $parsed, $api) = @_;
  print STDERR "\nHANDLE_PARSED_PRESENCE\n";
  if ($self->{geo_in_flight}) {
    print STDERR "Not getting geo because already in flight\n";
    return;
  }
  #print STDERR Dumper($parsed->as_parsed());
  my $id = $parsed->cellid()->mappedid()->value();
  if (!$id) {
    print STDERR "Not getting geo because no mapped id\n";
    return;
  }
  my $city = $parsed->city()->value() || "";
  my $base = $parsed->baseinfo()->current()->basename()->value() || "";
  my $cellname = $parsed->cellname()->value() || $base;
  if ($city ne "" && $cellname ne "") {
    print STDERR "Not getting geo because names known\n";
    # no names to fetch
    return;
  }
  my $parsed_cellid = $parsed->cellid();
  my $cell_to_api = {
      cell_id => $parsed_cellid->cellid()->value(),
      location_area_code => $parsed_cellid->locationareacode()->value(),
      mobile_network_code => $parsed_cellid->mnc()->value(),
      mobile_country_code => $parsed_cellid->mcc()->value(),
  };
  my $lang;
  if ($parsed_cellid->mcc() == 244) {
    $lang = "fi_FI";
  }
  my $callback_inner = sub {
    print STDERR "GOT GEOLOCATION RESPONSE 2\n";
    my ($parsed, $error) = @_;
    if (!$parsed) {
      print STDERR "GEOLOCATION ERROR $error";
      return;
    }
    if ($self->{closed}) {
      print STDERR "CLOSED\n";
      return;
    }
    my $address = $parsed->{location}->{address};
    print STDERR Dumper($address);
    if ($city eq "") {
      $city = $address->{city};
      if ($city ne "") {
        my $tuple = Jaiku::Tuple::GivenCityName::make($id, $city);
        $self->send_stanza($tuple);
      }
    }
    if ($cellname eq "") {
      my @parts;
      push (@parts, $address->{postal_code});
      push (@parts, $address->{street});
      $cellname = join(", ", grep { defined($_) } @parts);
      if ($cellname ne "") {
        my $tuple = Jaiku::Tuple::GivenCellName::make($id, $cellname);
        $self->send_stanza($tuple);
      }
    }
  };
  my $callback = sub {
    print STDERR "GOT GEOLOCATION RESPONSE\n";
    $self->{geo_in_flight} = 0;
    eval { $callback_inner->(@_) };
    print STDERR "$@" if ($@);
  };
  print STDERR "SENDING GEOLOCATION QUERY\n";
  $api->get_geolocation(callback => $callback, lang => $lang, %$cell_to_api);
  $self->{geo_in_flight} = 1;
}

sub replace_tupleid {
        my $self=shift;
        my $tuple=shift;
    my $dont_keep_mapping=shift;
        $self->{int_id}++;
        $self->{id_by_tupleid}->{$self->{int_id}}=$tuple->tupleuuid->value unless($dont_keep_mapping);
        $tuple->tupleid->set_value($self->{int_id});
}

sub supports_presenceline_sync {
    return ( ($_[0]->{clientversion} || 0) >= 1);
}

sub send_presenceline_to_client {
    my $self = shift;
    unless ( $self->supports_presenceline_sync() ) {
        $self->{waiting_on_initial_pline} = 2;
        return;
    }
    my $pres = $self->{last_presence};

    if ($pres && $pres->{stanza_status_ts} && $pres->{stanza_status_ts} ne "00000101T000000") {
        #print STDERR "STANZA_TS " . $pres->{stanza_status_ts} . "\n";
        $self->{waiting_on_initial_pline} = 2;
        if ($self->{pline_timer}) {
            $self->{pline_timer}->cancel;
            $self->{pline_timer}=undef;
        }
    }
    $self->{waiting_on_initial_pline} ||= 0;
    if ($self->{waiting_on_initial_pline}==0) {
        #print STDERR "SETTING TIMER FOR PLINE\n";
        $self->{waiting_on_initial_pline}=1;
        $self->{pline_timer}=Danga::Socket->AddTimer(15, sub {
            #print STDERR "PLINE TIMER CALLBACK\n";
            $self->{pline_timer}=undef;
            $self->{waiting_on_initial_pline}=2;
            $self->send_presenceline_to_client;
        });
        return;
    }
    return if ($self->{waiting_on_initial_pline}==1);
    #print STDERR "WAITING ON PLINE 2\n";

    return unless ($pres && $pres->{status_ts});
    if ($pres->{stanza_status_ts} && $pres->{status_ts} gt $pres->{stanza_status_ts}) {
        my $ts=$pres->{status_ts};
        my $now=Jaiku::Presence::current_timestamp();
        unless ($self->supports_servertime()) {
                $ts=$pres->shift_outgoing_ts( $ts );
                $now=$pres->shift_outgoing_ts( $now );
        }
        my $tuple=Jaiku::Tuple::UserGiven::make( $pres->{status}, $ts, $now );
        $tuple->tupleid->set_value( $self->{pline_tupleid} );
        $self->replace_tupleid($tuple);
        $self->write($tuple->as_xml);
    } else {
        $self->acked($self->{pline_tupleid});
    }
    $self->{pline_tupleid}=0;
}

sub send_presence_probes {
    my $self = shift;

    my $send_probes = sub {
        my $roster = shift;
        # go through rosteritems who we're subscribed to
        my $from_jid = $self->bound_jid;
        foreach my $it ($roster->to_items) {
            my $probe = DJabberd::Presence->probe(to => $it->jid, from => $from_jid);
            #print STDERR "PROBE to " . $it->jid . "\n";

            # if we know the other side trusts us, let's avoid us internally not
            # trusting ourselves and doing more work in Presence.pm than we need to,
            # reloading lots of roster items and such.
            if ($it->subscription->sub_from) {
                $probe->{dont_load_rosteritem} = 1;
            }

            $probe->procdeliver($self->vhost);
        }
    };

    $self->vhost->get_roster($self->bound_jid, on_success => $send_probes);
}

sub send_pending_sub_requests {
    my $self = shift;
    return unless $self->{pend_in_subscriptions};
    foreach my $pkt (@{ $self->{pend_in_subscriptions} }) {
        $pkt->deliver($self->vhost);
    }
    $self->{pend_in_subscriptions} = undef;
}

sub close {
    my $self = shift;
    return if $self->{closed};
    $self->{pline_timer}->cancel if ($self->{pline_timer});
    $self->log->info("Closing " . $self->bound_jid || "");
    #print STDERR "CLIENT DISCONNECTED " . $self->bound_jid . "\n";
    #my $trace = Devel::StackTrace->new;
    #print STDERR $trace->as_string; # like carp
    #delete $connections_by_deviceid{$self->{device_id}};

    if ($self->{messagequeue}) {
        $self->{messagequeue}->disconnected( $self->bound_jid->node, $self->{device_id} );
    }
    my $resource="";
    if (my $jid = $self->bound_jid) {
        $resource=$jid->resource();
    }
    # send an unavailable presence broadcast if we've gone away
    if ($self->is_available) {
        # set unavailable here, BEFORE we sent out unavailable stanzas,
        # so if the stanzas 'bounce' or otherwise write back to our full JID,
        # they'll either drop/bounce instead of writing to what will
        # soon be a dead full JID.
        $self->set_available(0);

        if ($resource ne "Context") {
                my $unavail = DJabberd::Presence->unavailable_stanza;
                $unavail->broadcast_from($self);
        }
    }

    if (my $jid = $self->bound_jid) {
        $self->vhost->unregister_jid($jid, $self);
        if ($resource ne "Context") {
                DJabberd::Presence->forget_last_presence($jid);
        }
    }

    if ($self->vhost && $self->vhost->are_hooks("ConnectionClosing")) {
        $self->vhost->run_hook_chain(phase => "ConnectionClosing",
                                     args  => [ $self ],
                                     methods => {
                                         fallback => sub {
                                         },
                                     },
                                     );

    }
    $self->SUPER::close;
}

sub namespace {
    return "jabber:client";
}

sub on_stream_start {
    my DJabberd::Connection $self = shift;
    my $ss = shift;
    return $self->close unless $ss->xmlns eq $self->namespace; # FIXME: should be stream error

    $self->{in_stream} = 1;
    #$self->log->info("EXTRA NS " . $ss->extra_ns);
    $self->{extra_namespace} = $ss->extra_ns;

    my $to_host = $ss->to;
    my $vhost = $self->server->lookup_vhost($to_host);
    return $self->close_no_vhost($to_host)
        unless ($vhost);

    $self->set_vhost($vhost);

    # FIXME: bitch if we're starting a stream when we already have one, and we aren't
    # expecting a new stream to start (like after SSL or SASL)
    $self->start_stream_back($ss,
                             namespace  => 'jabber:client',
                             features   => qq{<auth xmlns='http://jabber.org/features/iq-auth'/>},
                             );
}

# XXX andy: override
sub stream_id {
    my $self = shift;
    if ($self->version->as_string eq '0.0') {
        $self->log->warn('no version set, entering compatibility mode');
        return '';
    }
    return $self->{stream_id} ||= Digest::SHA1::sha1_hex(rand() . rand() . rand());
}

sub is_server { 0 }

sub acked {
    my $self=shift;
    my $id=shift;
    if ( ($self->{id_by_tupleid}->{$id} || '') ne '') {
        my $tmp=$id;
        $id=$self->{id_by_tupleid}->{$id};
        delete $self->{id_by_tupleid}->{$tmp};
    } else {
      # internally generated, no need to ack up
      return;
    }
    #print STDERR "ACKING $id " . $self->bound_jid . "\n";
    $self->log->info("ACKING $id " . $self->bound_jid);
    $self->{messagequeue}->acked($self->bound_jid->node, $self->{device_id}, $id);
}

sub request_messagecount {
    my $self=shift;
    return unless ($self->supports_messagecount());

    $self->{messagequeue}->messagecount(
            $self->bound_jid->node, $self->{device_id} );
    $self->log->info("getting messagecount");
    return;
}

sub resume {
    my $self=shift;

    $self->{is_suspended}=0;
    $self->{messagequeue}->resume_features(
            $self->bound_jid->node, $self->{device_id}, [ "PRESENCE", "BUDDYIMG", "FEED" ] );
    $self->request_messagecount();
    $self->send_queued_presences;
    $self->send_queued_tuples;
}

sub suspend {
    my $self=shift;

    $self->log->info("suspended " . $self->bound_jid);
    $self->{is_suspended}=1;
    $self->{messagequeue}->suspend_features(
            $self->bound_jid->node, $self->{device_id}, [ "PRESENCE", "BUDDYIMG", "FEED" ] );
    $self->{queued_presences}={};
}

sub handle_feeditem2 {
    my $self=shift;
    my $node=shift;
    my $flickr_client=shift;
    my $request2=shift;
    my $cb=shift;
    unless ($request2) {
        $cb->($node);
        return;
    }
    $flickr_client->flickr_request($request2, sub { 
            my $resp=shift;
            my $url=photopage_from_response($resp);
            #print STDERR "URL2 $url\n";
            $node->data->linkedurl->set_value($url);
            $cb->($node);
        });
}

sub handle_feeditem {
    my $self=shift;
    my $node=shift;
    my $cb=sub {
        my $node=shift;
        $self->{messagequeue}->received_message( $self->server->{c2s_port},
                $self->bound_jid->node, $self->{device_id},
                $node, sub { $self->ack_to_client(@_) } );
    };
    if ($node->data->kind->value eq "photo") {
        my $url=$node->data->thumbnailurl->value;
        #print STDERR "URL $url\n";
        my $request=photoid_request($url);
        my $request2=photoid_info_request($url);
        if ($request) {
            my $flickr_client=Jaiku::HTTPClient::get_client;
            $flickr_client->flickr_request($request, sub { 
                    my $resp=shift;
                    my $url=small_from_response($resp);
                    #print STDERR "URL2 $url\n";
                    $node->data->thumbnailurl->set_value($url);
                    $self->handle_feeditem2($node, $flickr_client, $request2, $cb);
                });
            return;
        }
    }
    $cb->($node);
}

my %element2class = (
             "{jabber:client}iq"       => 'DJabberd::IQ',
             "{jabber:client}message"  => 'DJabberd::Message',
             "{jabber:client}presence" => 'DJabberd::Presence',
             "{urn:ietf:params:xml:ns:xmpp-tls}starttls"  => 'DJabberd::Stanza::StartTLS',
             );

sub on_stanza_received {
    my ($self, $node) = @_;

        print STDERR "GOT " . $node->as_xml() . "\n";
    if ($self->xmllog->is_info) {
      #$self->log_incoming_data($node);
    }

    #print STDERR "STAT ", $self->bound_jid, " ", $node->element, "\n";
    #$self->log->info("ELEMENT " . $node->element);
    if ($node->element eq "{http://www.cs.helsinki.fi/group/context}suspend") {
        $self->suspend;
        return;
    }
    if ($node->element eq "{http://www.cs.helsinki.fi/group/context}ack") {
#       print STDERR "ACK: " . $node->as_xml . "\n";
        my $id=$node->text();
        $self->acked($id);
        return;
    }
    if ($node->element eq "{http://www.cs.helsinki.fi/group/context}resume") {
        $self->log->info("resumed " . $self->bound_jid);
        $self->{sent_mc2}=0;
        $self->resume;
        return;
    }
    $self->send_queued_tuples;
    
    if ($node->element eq "{http://www.cs.helsinki.fi/group/context}keepalive") {
        print STDERR "KEEPALIVE " . $node->as_xml() . "\n";
        $self->log->info("keepalive");
        $self->send_keepalive();
        return;
    }
    if ($node->element eq "{http://www.cs.helsinki.fi/group/context}clientversion") {
        $self->{clientversion}=$node->attr("{}value");
        $self->{device_id}=$node->attr("{}device_id") if $node->attr("{}device_id");
        $self->on_clientversion;
        $self->log->info("clientversion " . $self->{clientversion});
        if ($self->supports_servertime) {
                $self->send_servertime;
        }
        $self->connect_to_messagequeue;
        $self->request_messagecount();
        return;
    }
    if ($node->element eq "{http://www.cs.helsinki.fi/group/context}tuple") {
        $node=Jaiku::BBData::Tuple->downbless($node);

        if (Jaiku::Tuple::ThreadRequest::is_threadrequest($node->tuplemeta->moduleuid->value,
                $node->tuplemeta->moduleid->value)) {
            $self->{messagequeue}->received_message( $self->server->{c2s_port},
                    $self->bound_jid->node, $self->{device_id},
                    $node, sub { $self->ack_to_client(@_) } );
        } elsif (Jaiku::Tuple::FeedItem::is_feeditem($node->tuplemeta->moduleuid->value,
                $node->tuplemeta->moduleid->value)) {
            $self->handle_feeditem($node)
        } else {
            $self->{messagequeue}->received_message( $self->server->{c2s_port},
                    $self->bound_jid->node, $self->{device_id},
                    $node, sub { $self->ack_to_client(@_) } );
        }
        $self->log->info("got tuple from client"); # . $node->as_xml);
        return;
    }

    my $class = $element2class{$node->element};
    if (! $class ) {
        $self->log->info("unknown stanza " . $node->element);
        return;
        #return $self->stream_error("unsupported-stanza-type");
    }

    $DJabberd::Stats::counter{"ClientIn:$class"}++;

    # same variable as $node, but down(specific)-classed.
    my $stanza = $class->downbless($node, $self);
    my $resource="";
    if (my $jid = $self->bound_jid) {
        $resource=$jid->resource();
    }
    if ($resource eq "Context" && $stanza->isa('DJabberd::Presence')) {
        $self->{last_presence}=new Jaiku::Presence unless($self->{last_presence});
        print STDERR "PRESENCE1 " . $stanza->as_xml . "\n";
        $self->{last_presence}->set_stanza($stanza->clone());
        print STDERR "LAST PRESENCE 0" .  $self->{last_presence}->stanza()->as_xml() . "\n";
        print STDERR $self->bound_jid->node . " got presence, wait flag " .
            ($self->{waiting_on_initial_pline} || 'undef');
        if ( defined($self->{waiting_on_initial_pline})) {
            if ($self->{waiting_on_initial_pline}<2) {
                $self->send_presenceline_to_client;
            }
            if ($self->{waiting_on_initial_pline}>1) {
                $stanza=$self->{last_presence}->stanza;
                #print STDERR "PRESENCE2 " . $stanza->as_xml . "\n";
            }
        } 
    }
    if ($stanza->isa('DJabberd::Message') && $stanza->to_jid->node eq "jaiku") {
        my @body=grep { $_->element =~/body/ } $stanza->children_elements;
        my $body=$body[0];
        return unless($body);
        my ($text, $photoid);
        if ($body->text=~/(.*)(photoid.*)/) {
            $text=$1;
            $photoid=$2;
            $self->send_photoid($text, $photoid);
            return;
        } else {
            $text=$body->text;
            $photoid="";
        }
        eval { DJabberd::Connection::JaikuPresence::handle_presenceline(
                $self, $self->bound_jid->node . " " . $body->text); };
        $self->response($@) if ($@);
        return;
    }

    $self->vhost->hook_chain_fast("filter_incoming_client",
                                  [ $stanza, $self ],
                                  {
                                      reject => sub { },  # just stops the chain
                                  },
                                  \&filter_incoming_client_builtin,
                                  );
}

sub ack_to_client {
    my $self=shift;
    my $ack=new Jaiku::BBData::Uint("ack");
    my $id=shift;
    my $data = shift;  # ignored, handled by messagequeue
    my $error = shift;
    if (!$id) {
      print STDERR "Failed to send message: $error\n";
      return;
    }
    $ack->set_value($id);
    $ack->set_type_attributes;
    $self->write($ack->as_xml);
}

my $ug;
sub send_as_streamdata {
    my $self=shift;
    my ($line, $ts)=@_;
    $ug ||= new Data::UUID;
    my $stream_item=new Jaiku::BBData::StreamData;        
    $stream_item->set_type_attributes;
    $stream_item->title->set_value($line);
    $stream_item->authornick->set_value($self->bound_jid->node);
    my $uuid=$ug->create_str();
    $uuid=~s/[-]//g;
    $uuid=lc($uuid);
    $stream_item->uuid->set_value($uuid);
    $stream_item->created->set_value($ts);
    my $tuple=new Jaiku::BBData::Tuple;
    $tuple->tuplemeta->moduleuid->set_value(0x200084C1);
    $tuple->tuplemeta->moduleid->set_value(Jaiku::Tuple::FeedItem::ID());
    $tuple->tuplemeta->subname->set_value("streamdata");
    my $expires_gmtime=Jaiku::Presence::current_time()+7*24*60*60;
    $tuple->expires->set_value(Jaiku::Presence::format_datetime($expires_gmtime));
    $tuple->set_data($stream_item);
    $tuple->tupleid->set_value(0);
    $tuple->set_type_attributes;
    print STDERR "sending received line to pqueue\n";
    $self->{messagequeue}->received_message( $self->server->{c2s_port},
            $self->bound_jid->node, $self->{device_id},
            $tuple->as_xml, sub { } );
}

sub set_presence_line {
    my $self=shift;
    my $not_avail_yet=0;
    unless ( $self->{last_presence} ) {
        $self->{last_presence}=new Jaiku::Presence;
        $not_avail_yet=1;
    }
    my $line=shift;
    my $ts=shift;
    my $extras=shift;
    my $xml_extras=shift;
    my $from_message=shift;
    foreach my $k (keys %$extras) {
        my $meth="set_$k";
        $self->{last_presence}->$meth( $extras->{$k} );
    }
    $self->{last_presence}->merge_xml( $xml_extras );
    #unless ( $self->supports_presenceline_sync() ) {
            $self->{last_presence}->set_status( ($line, $ts) );
    #}
    #print STDERR "SET_PRESENCE_LINE $_[0] $_[1] $_[2]";
    if ($self->{last_presence}->stanza) {
        if ($self->{last_presence}->stanza->as_xml =~ /generated/) {
            $self->send_as_streamdata($line, $ts);
        }
    }
    $self->send_from_presenceline($not_avail_yet);
}

sub send_from_presenceline {
    my $self=shift;
    my $not_avail_yet=shift;
    #print STDERR "SEND_FROM_PRESENCELINE\n";
    my $pres = $self->{last_presence};
    $self->send_presenceline_to_client;
    unless ($not_avail_yet) {
      return unless($pres->stanza);
      #print STDERR "STANZA " . $self->{last_presence}->stanza->as_xml . "\n";
      if ($pres->{status_ts} gt $pres->{stanza_status_ts}) {
        $self->vhost->hook_chain_fast("filter_incoming_client",
                                      [ $self->{last_presence}->stanza, $self ],
                                      {
                                          reject => sub { },  # just stops the chain
                                      },
                                      \&filter_incoming_client_builtin,
                                      );
      }
    }
}

sub supports_partial_presence {
    return 0;
    return ( ($_[0]->{clientversion} || 0) >= 4);
}

sub write_presence_tuple {
    my $self=shift;
    my $stanza=shift;
    if ($self->supports_partial_presence()) {
        eval {
        my $previous=$self->{last_sent}->{$stanza->tuplemeta->subname->value};
        print STDERR "DATA (partial)" . $stanza->data->as_xml . "\n";
        my $split=new Jaiku::XMLSplit($stanza->data->as_xml);
        my @new_elements=$split->elements;
        $self->{last_sent}->{$stanza->tuplemeta->subname->value}=\@new_elements;
        my %previous_by_name;
        if ($previous) {
            map { $previous_by_name{ $_->[0] } = $_->[1] } @$previous;
        }
        my $xml="<tuplevalue " . presence_type_attr() . ">";
        foreach my $el (@new_elements) {
            if ( $el->[1] ne $previous_by_name{ $el->[0] } ) {
                my $element=$el->[1];
                unless ($self->supports_servertime()) {
                    if ($self->{last_presence} && $el->[0]!~/calendar/) {
                        $element=$self->{last_presence}->shift_outgoing_time($element);
                    }
                }
                $xml .= $element;
            }
        }
        $xml .= "</tuplevalue>";
        #print STDERR "XML $xml\n";
        $stanza->set_data(new Jaiku::RawXML($xml));
        };
        if ($@) { print STDERR $@, "\n"; }
            else { $self->write($stanza->as_xml); }
    } else {
        return unless($stanza);
        my $element=$stanza->as_xml;
        print STDERR "DATA (full)" . $element . "\n";
        #$element=$self->{last_presence}->shift_outgoing_time($element) if ($self->{last_presence});
            $self->write($element);
    }
}

sub send_or_queue_tuple {
    my ($self, $tuple) = @_;
    unless ($self->{is_suspended}) {
        $self->write($tuple->as_xml);
        return;
    }
    my $identifier=$tuple->tupleid;
    my $prev=$self->{queued_tuples}->{$identifier};
    if (ref $prev) {
        $self->acked(0);
    }
    $self->{queued_tuples}->{$identifier}=$tuple;
}

sub send_queued_tuples {
    my $self=shift;
    if ($self->supports_messagecount2()) {
        my @tuples=keys %{$self->{queued_tuples}};
        my $count=$#tuples+1;
        unless ($self->{sent_mc2}) {
            $self->messagecount2($count);
            $self->{sent_mc2}=1;
        }
    }
    foreach my $tuple (values %{$self->{queued_tuples}}) {
        $self->write($tuple->as_xml);
    }
    $self->{queued_tuples}={};
}

sub send_stanza {
    my ($self, $stanza) = @_;
    #print STDERR "send_stanza, dir: " . $stanza->is_directed() .
        #"isa" . $stanza->isa('DJabberd::Presence') . "\n";
  #print STDERR "SEND_STANZA" . $stanza->as_xml . "\n";
    if ($stanza->isa('DJabberd::Presence') && ($stanza->type || "available") eq "available") {
        if ($self->bound_jid->resource eq "Context" && $stanza->from_jid->resource ne "Context") {
            return;
        }
        if (0 && $self->{is_suspended}) {
            $self->{queued_presences}->{$stanza->from_jid}=$stanza->clone();
            return;
        }
        #print STDERR "checking last_presence: " . ($self->{last_presence} && $self->{last_presence}->need_to_shift) . "\n";
        unless ($self->supports_servertime()) {
            if ($self->{last_presence} && $self->{last_presence}->need_to_shift) {
                $stanza=$stanza->clone(),
                $self->{last_presence}->shift_outgoing_time($stanza);
            }
        }
        $self->log->info("sending presence stanza of " . $stanza->from_jid);
        $self->write($stanza->as_xml);
            return;
    }
    if ($stanza->isa('Jaiku::BBData::Tuple')) {
        if ($self->{is_suspended}) {
            my $subname=$stanza->tuplemeta->subname->value;
            $self->log->info("queueing presence tuple " . $stanza->tupleid->value . " of $subname" .
                " to " . $self->bound_jid);
            my $prev=$self->{queued_presences}->{$subname};
            #$self->log->info("PREV " . Dumper($prev));
            if (ref $prev) {
                $self->acked(0);
            }
            if (0) {
                    my $c;
                    eval {$c=$stanza->clone;
                    $self->{queued_presences}->{$subname}=$c; };
                    if ($@) {
                        $self->log->error("ERROR IN QUEUEING $@");
                    }
            } else {
                $self->{queued_presences}->{$subname}=$stanza;
            }
            #$self->log->info("NEW " . Dumper($c));
            return;
        } else {
            $self->log->info("sending presence tuple " . $stanza->tupleid->value . " of " . $stanza->tuplemeta->subname->value .
                " to " . $self->bound_jid);
            $self->write_presence_tuple($stanza);
            return;
        }
    }
    $self->SUPER::send_stanza($stanza);
}

sub send_keepalive {
    my $self=shift;
    my $presence=$self->{last_presence};
    return unless ( $presence );
    $presence->update_timestamp();
    #print STDERR "ST: " . $presence->stanza->as_xml . "\n";
    $self->vhost->hook_chain_fast("filter_incoming_client",
                                  [ $presence->stanza, $self ],
                                  {
                                      reject => sub { },  # just stops the chain
                                  },
                                  \&filter_incoming_client_builtin,
                                  );
}

sub send_queued_presences {
    my $self=shift;
    foreach my $stanza (values %{$self->{queued_presences}}) {
        if ($stanza->isa('DJabberd::Presence')) {
        unless ($self->supports_servertime()) {
            if ($self->{last_presence}) {
                $self->{last_presence}->shift_outgoing_time($stanza);
            }
        }
                $self->SUPER::send_stanza($stanza);
        } else {
                $self->log->info("sending presence tuple " . $stanza->tupleid->value . " of " . $stanza->tuplemeta->subname->value .
                        " to " . $self->bound_jid);
                $self->write_presence_tuple($stanza);
        }
    }
    $self->{queued_presences}={};
}

sub is_authenticated_jid {
    my ($self, $jid) = @_;
    my $bj = $self->bound_jid;
    return 0 unless $jid && $bj;
    return $bj->as_bare_string eq $jid->as_bare_string if $jid->is_bare;
    return $bj->as_string      eq $jid->as_string;
}

sub set_bound_jid {
    my ($self, $jid, $cb, $auth_params) = @_;
    $self->{auth_params} = $auth_params;
    $self->SUPER::set_bound_jid($jid);

}

sub on_clientversion {
    my $self=shift;
    my $line;
    if ($self->supports_presenceline_sync()) {
            $line='x';
    }
    $self->{vhost}->hook_chain_fast("GetPresenceLine", [ $self->bound_jid, $line ],
                { error => sub { }, set => 
                sub {
                        #print STDERR $self->bound_jid->node . " returned from GetPresenceLine\n";
                        shift;
                        $self->set_presence_line(@_);
                }
                });
}
 
sub supports_messagecount {
    return ( ($_[0]->{clientversion} || 0) >=5 );
}
sub supports_messagecount2 {
    return ( ($_[0]->{clientversion} || 0) >=7 );
}

sub messagecount {
    my ($self, $count)=@_;
    my $stanza=new Jaiku::BBData::Uint("messagecount");
    #print STDERR "MESSAGECOUNT $count\n";
    $self->log->info("sending messagecount $count");
    $stanza->set_type_attributes();
    $stanza->set_value($count);
    $self->write($stanza->as_xml);
}

sub messagecount2 {
    my ($self, $count)=@_;
    my $stanza=new Jaiku::BBData::Uint("messagecount2");
    #print STDERR "MESSAGECOUNT2 $count\n";
    $self->log->info("sending messagecount2 $count");
    $stanza->set_type_attributes();
    $stanza->set_value($count);
    $self->write($stanza->as_xml);
}


# This is not really a method, but gets invoked as a hookchain item
# so if you subclass this class, this will still get called

sub filter_incoming_client_builtin {
    my ($vhost, $cb, $stanza, $self) = @_;

    # <invalid-from/> -- the JID or hostname provided in a 'from'
    # address does not match an authorized JID or validated domain
    # negotiated between servers via SASL or dialback, or between a
    #  client and a server via authentication and resource binding.
    #{=clientin-invalid-from}
    my $from = $stanza->from_jid;

    if ($from && ! $self->is_authenticated_jid($from)) {
        # make sure it is from them, if they care to tell us who they are.
        # (otherwise further processing should assume it's them anyway)

        # libgaim quirks bug.  libgaim sends bogus from on IQ errors.
        # see doc/quirksmode.txt.
        if ($vhost->quirksmode && $stanza->isa("DJabberd::IQ") &&
            $stanza->type eq "error" && $stanza->from eq $stanza->to) {
            # fix up from address
            $from = $self->bound_jid;
            $stanza->set_from($from);
        } else {
            return $self->stream_error('invalid-from');
        }
    }

    # if no from, we set our own
    if (! $from) {
        my $bj = $self->bound_jid;
        $stanza->set_from($bj->as_string) if $bj;
    }

    $vhost->hook_chain_fast("switch_incoming_client",
                            [ $stanza ],
                            {
                                process => sub { $stanza->process($self) },
                                deliver => sub { $stanza->deliver($self) },
                            },
                            sub {
                                $stanza->on_recv_from_client($self);
                            });

}

1;
