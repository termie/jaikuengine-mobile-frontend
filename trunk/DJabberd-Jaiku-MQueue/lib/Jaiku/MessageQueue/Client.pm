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
package Jaiku::MessageQueue::Client;

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

# Copyright 2008 Google Inc. All rights reserved.
# Author: mikie@google.com (Mika Raento)

# This class implements a reliable propagation of changed data from
# Jaiku-on-Appengine to the mobile client.
# The propagation logic is:
# 1 have a (possibly empty) persisted anchor
#   1.1 set transient anchor to anchor - fudge
# 2 ask for changes since the transient anchor
# 3 send them to the client, noting the uuids
#   3.1 don't send items whose uuids we have already seen
# 4 update the transient anchor:
#    4.1 ts <- max(items' timestamp)
#    4.2 transient anchor <- min(ts, servertime - fudge)
# 5 goto 2
#
# On client acking data (or having no pending items and receiving a server
# timestamp) we set the persisted anchor to that.

use strict;
use fields qw(
  anchors features seen_uuids connections syncqueues timers
  pending_gets pending_uuids connection_generation
  pending_tuples until_messagecount suspended_features
  backends storages expensive_uuids acked_uuids
  thread_uuids);
use Data::Dumper;
use DJabberd::Jaiku::API;
use Jaiku::Backend::API;
use Jaiku::Presence;
use Jaiku::Storage::API;
use Jaiku::Storage::Simple;
use Jaiku::SyncQueue;
#use Jaiku::BBData::Tuple;
use Scalar::Util;
#use Jaiku::RawXML;

# The kinds of data the client wants from the queue is identified
# by feature strings.
use constant FEATURE_BUDDYIMG => "BUDDYIMG";
use constant FEATURE_PRESENCE => "PRESENCE";
use constant FEATURE_FEED => "FEED";

# For each kind of data we keep an anchor (the datetime the client has
# acked all data up to). These constants are used to identify the
# different anchors in the storage.
use constant ANCHOR_CONTACTS => 1;
use constant ANCHOR_PRESENCE => 2;
use constant ANCHOR_FEED => 3;

use constant MAX_IN_FLIGHT => 10;
use constant MAX_TRIES => 5;

our ($g_backend,
     $g_client,
     $g_storage,
     $g_poll_interval);

our $logger = DJabberd::Log->get_logger();
#$g_storage = Jaiku::Storage::Simple->new();

sub get_client {
  return $g_client ||= new Jaiku::MessageQueue::Client;
}

sub anchor_from_feature {
  my ($feature) = @_;
  if ($feature eq FEATURE_BUDDYIMG) {
    return ANCHOR_CONTACTS;
  } elsif ($feature eq FEATURE_PRESENCE) {
    return ANCHOR_PRESENCE;
  } elsif ($feature eq FEATURE_FEED) {
    return ANCHOR_FEED;
  }
  return undef;
}

sub _subtract_propagation_delay {
  my ($dt) = @_;
  $dt = Jaiku::Presence::formatted_to_datetime($dt);
  $dt -= 30;
  return Jaiku::Presence::mysql_datetime($dt);
}

sub set_backend {
  my ($class, $backend) = @_;
  $g_backend = $backend;
}

sub backend {
  my ($self, $nick, $device_id) = @_;
  if ($g_backend) {
    return $g_backend;
  }
  my $nickdev = nick_dev([$nick, $device_id]);
  return $self->{backends}->{$nickdev};
}

sub storage {
  my ($self, $nick, $device_id) = @_;
  if ($g_storage) {
    return $g_storage;
  }
  my $nickdev = nick_dev([$nick, $device_id]);
  return $self->{storages}->{$nickdev};
}

sub set_storage {
  my ($class, $storage) = @_;
  if (!$storage) {
    die "storage must be defined"
  }
  $g_storage = $storage;
}

sub _create_storage_and_backend {
  my ($self, $connection, $nick, $device_id, $auth_params) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  my $api = DJabberd::Jaiku::API->get($connection->vhost());
  print STDERR "CREATING WITH " . Dumper($auth_params) . "\n";
  $api = $api->clone(token_key => $auth_params->{key_},
                     token_secret => $auth_params->{secret});
  if (!$g_storage) {
    $self->{storages}->{$nickdev} = Jaiku::Storage::API->new($api);
  }
  if (!$g_backend) {
    $self->{backends}->{$nickdev} = Jaiku::Backend::API->new($api);
  }
  if (!$g_poll_interval) {
    $g_poll_interval = 15;  # sec
  }
}

sub log_error {
  print STDERR "MQUEUE_CLIENT ERR: ", shift, "\n";
  $logger->warn(@_);
}

sub log_info {
  print STDERR "MQUEUE_CLIENT INFO: ", shift, "\n";
  $logger->info(@_);
}

sub new {
  my Jaiku::MessageQueue::Client $self = shift;
  $self=fields::new($self) unless ref $self;
  $self->{connection_generation} = { };

  log_info("starting messagequeue client");
  return $self;
}

sub nick_dev {
  my $args=shift;
  return lc($args->[0] . "." . $args->[1]);
}

sub get_anchors {
  my ($self, $nick, $device_id) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  my $to_get = 3;
  my $generation = $self->{connection_generation}->{$nickdev};
  my $storage = $self->storage($nick, $device_id);
  $storage->get_anchors($nick, $device_id, sub {
    my ($anchors) = @_;
    foreach my $key (keys %{$anchors}) {
      $anchors->{$key} = _subtract_propagation_delay($anchors->{$key});
    }
    if (!$anchors->{ANCHOR_FEED()}) {
      $anchors->{ANCHOR_FEED()} =
          Jaiku::Presence::mysql_datetime(Jaiku::Presence::current_time() -
                                          2 * 24 * 60 * 60);
    }
    $self->{anchors}->{$nickdev} = $anchors;
    $to_get--;
    if ($generation != $self->{connection_generation}->{$nickdev}) {
      # This fetch was for a previous connection, discard.
      return;
    }
    if ($to_get == 0) {
      $self->_set_poll_timer($nick, $device_id, 0.1);
    }
  });
  $storage->get_seen_uuids($nick, $device_id, sub {
    my ($uuids) = @_;
    $self->{pending_uuids}->{$nickdev} = $uuids;
    $to_get--;
    if ($generation != $self->{connection_generation}->{$nickdev}) {
      # This fetch was for a previous connection, discard.
      return;
    }
    if ($to_get == 0) {
      $self->_set_poll_timer($nick, $device_id, 0.1);
    }
  });
  $storage->get_acked_uuids($nick, $device_id, sub {
    my ($uuids) = @_;
    $self->{acked_uuids}->{$nickdev} = $uuids;
    $to_get--;
    if ($generation != $self->{connection_generation}->{$nickdev}) {
      # This fetch was for a previous connection, discard.
      return;
    }
    if ($to_get == 0) {
      $self->_set_poll_timer($nick, $device_id, 0.1);
    }
  });
}

sub _get_data_from_backend {
  my ($self, $nick, $device_id) = @_;
  log_info("getting data for $nick");
  my $nickdev = nick_dev([$nick, $device_id]);
  log_info("GET DATA " . $nick . " " . $device_id);
  if ($self->{syncqueues}->{$nickdev}->queued_count() >= MAX_IN_FLIGHT) {
    log_info("NOT GETTING DATA BECAUSE TOO MANY IN FLIGHT");
    return;
  }
  my $generation = $self->{connection_generation}->{$nickdev};
  my $backend = $self->backend($nick, $device_id);
  for my $get_pair (
      [ FEATURE_BUDDYIMG, "get_contacts" ],
      [ FEATURE_PRESENCE, "get_presence" ],
      [ FEATURE_FEED,     "get_feeditems"]) {
    my ($feature, $get_method) = @$get_pair;
    if ($self->{features}->{$nickdev}->{$feature} &&
        !$self->{suspended_features}->{$nickdev}->{$feature}) {
      my $anchortype = anchor_from_feature($feature);
      if (!$self->{pending_gets}->{$nickdev}->{$anchortype}) {
        $self->{pending_gets}->{$nickdev}->{$anchortype} = 1;
        $backend->$get_method(
            $nick, $self->{anchors}->{$nickdev}->{$anchortype}, sub {
              $self->{pending_gets}->{$nickdev}->{$anchortype} = 0;
              if ($generation != $self->{connection_generation}->{$nickdev}) {
                # This fetch was for a previous connection, discard.
                return;
              }
              $self->_got_tuples_waiting($anchortype, $nick, $device_id, @{$_[0]});
        });
      }
    }
  }
}

sub _set_poll_timer {
  my ($self, $nick, $device_id, $wait) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  if (!$self->{syncqueues}->{$nickdev}) {
    # called too early
    return;
  }
  if (!$wait) {
    $wait = $g_poll_interval;
  }
  my $fire_time = POSIX::ceil(Time::HiRes::time() + $wait);
  my $existing = $self->{timers}->{$nickdev};
  if ($existing) {
    if ($fire_time < $existing->[0]) {
      $existing->cancel;
      delete $self->{timers}->{$nickdev};
    } else {
      return;
    }
  }
  my $generation = $self->{connection_generation}->{$nickdev};
  $self->{timers}->{$nickdev} = Danga::Socket->AddTimer($wait, sub {
    if ($generation != $self->{connection_generation}->{$nickdev}) {
      # This fetch was for a previous connection, discard.
      return;
    }
    delete $self->{timers}->{$nickdev};
    $self->_commit_acked_uuids($nick, $device_id);
    $self->_get_data_from_backend($nick, $device_id);
  });
}

sub connected {
  my ($self, $queue_id, $nick, $device_id,
      $features, $connection, $clientversion,
      $auth_params) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  $self->{connection_generation}->{$nickdev}++;
  $self->_create_storage_and_backend($connection, $nick, $device_id,
      $auth_params);

  log_info("CONNECTED " . $nick . " " . $device_id);
  $self->{connections}->{$nickdev} = $connection;
  $self->{syncqueues}->{$nickdev} = new Jaiku::SyncQueue;
  foreach my $feature (@$features) {
    log_info("FEATURE $feature");
    $self->{features}->{$nickdev}->{$feature} = 1;
  }

  $self->get_anchors($nick, $device_id);
}

sub suspend_features {
  my ($self, $nick, $device_id, $features) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  foreach my $feature (@$features) {
    $self->{suspended_features}->{$nickdev}->{$feature} = 1;
  }
}

sub resume_features {
  my ($self, $nick, $device_id, $features) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  foreach my $feature (@$features) {
    delete $self->{suspended_features}->{$nickdev}->{$feature};
  }
  $self->_set_poll_timer($nick, $device_id, 0.1);
}

sub _commit_acked_uuids {
  my ($self, $nick, $device_id) = @_;
  my $storage = $self->storage($nick, $device_id);
  my $nickdev = nick_dev([$nick, $device_id]);
  my $dirty = delete $self->{acked_uuids}->{$nickdev}->{dirty};
  return unless($dirty);
  $storage->set_acked_uuids($nick, $device_id,
                            $self->{acked_uuids}->{$nickdev} || {},
                            sub {
                              my ($ret, $error) = @_;
                              if (!$ret) {
                                log_error($error);
                              }
                            });
 }

sub disconnected {
  my ($self, $nick, $device_id) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  my $timer = $self->{timers}->{$nickdev};
  if ($timer) {
    $timer->cancel();
  }
  my $storage = $self->storage($nick, $device_id);
  $storage->set_seen_uuids($nick, $device_id,
                             $self->{pending_uuids}->{$nickdev} || {},
                             sub {
                               my ($ret, $error) = @_;
                               if (!$ret) {
                                 log_error($error);
                               }
                             });
  $self->_commit_acked_uuids($nick, $device_id);

  $storage->disconnected($nick, $device_id);
  foreach my $field qw(anchors features seen_uuids connections
                       syncqueues timers pending_gets pending_uuids
                       pending_tuples until_messagecount suspended_features
                       storages backends expensive_uuids acked_uuids
                       thread_uuids) {
    delete $self->{$field}->{$nickdev};
  }
}

sub acked {
  my ($self, $nick, $device_id, $id) = @_;
  return unless($id);
  log_info("acked message '$id'");
  my $nickdev = nick_dev([$nick, $device_id]);
  return if (delete $self->{thread_uuids}->{$nickdev}->{$id});
  my $syncqueue = $self->{syncqueues}->{$nickdev};
  my $anchortype = $syncqueue->anchortype($id);
  my $new_anchor = $syncqueue->dequeue($id);
  my $storage = $self->storage($nick, $device_id);
  if ($new_anchor) {
    $storage->set_anchor($nick, $device_id, $anchortype, $new_anchor, sub {
        my ($parsed, $error) = @_;
        if ($error) {
          log_error($error);
        }
    });
  }
  delete $self->{pending_uuids}->{$nickdev}->{$anchortype}->{$id};
  my $expensive = delete
      $self->{expensive_uuids}->{$nickdev}->{$id};
  if ($expensive) {
    $self->{acked_uuids}->{$nickdev}->{$id} = $expensive;
    $self->{acked_uuids}->{$nickdev}->{dirty} = 1;
  }
  $self->_set_poll_timer($nick, $device_id, 1);
}

sub messagecount {
  my ($self, $nick, $device_id) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  print STDERR "messagecount $nickdev\n";
  foreach my $feature (keys %{$self->{features}->{$nickdev}}) {
    my $anchortype = anchor_from_feature($feature);
    if ($anchortype) {
      $self->{until_messagecount}->{$nickdev}->{$anchortype} = 1;
    }
  }
}

sub received_message {
  my ($self, $queue_id, $nick, $device_id, $xml, $cb) = @_;
  my $backend = $self->backend($nick, $device_id);
  if (Jaiku::Tuple::ThreadRequest::is_threadrequest(
          $xml->tuplemeta()->moduleuid()->value(),
          $xml->tuplemeta()->moduleid()->value())) {
    my $nickdev = nick_dev([$nick, $device_id]);
    my $handler = sub {
      my ($id, $items, $error) = @_;
      $cb->($id, $items, $error);
      if (!$id) {
        # failed, logged by the connection.
        return;
      }
      $self->_send_from_threadrequest_results($nick, $device_id, $xml, $items);
    };
    $backend->received_message($nick, $xml, $handler);
  } else {
    $backend->received_message($nick, $xml, sub {
      $self->_set_poll_timer($nick, $device_id, 1);
      $cb->(@_);
    });
  }
}

sub received_request {
  my $self=shift;
  my $queue_id=shift;
  # nick, device_id, XMLElement, callback
  my $args=[ lc(shift()), shift, shift ];
  my $cb=shift;
}

sub _send_from_threadrequest_results {
  my ($self, $nick, $device_id, $request, $items) = @_;
  if (!$items) {
    return;
  }
  my $nickdev = nick_dev([$nick, $device_id]);
  my $conn = $self->{connections}->{$nickdev};
  my @to_send;
  my $postuuid = $request->data()->postuuid()->value();
  foreach my $item (@$items) {
    my $uuid = $item->tupleuuid()->value();
    if (!$self->{seen_uuids}->{$nickdev}->{$uuid}) {
      $self->{seen_uuids}->{$nickdev}->{$uuid} = 1;
      $self->{thread_uuids}->{$nickdev}->{$uuid} = 1;
      push(@to_send, $item);
    }
  }
  my $count = $#to_send + 1;
  my $reply = Jaiku::Tuple::ThreadRequestReply::make($postuuid, $count);
  $conn->got_message($reply);
  foreach my $to_send(@to_send) {
    $conn->got_message($to_send);
  }
}

sub _got_tuples_waiting {
  my $self = shift;
  my ($anchortype, $nick, $device_id, $tuples, $server_time, $error) = @_;
  my $nickdev = nick_dev([$nick, $device_id]);
  push(@{$self->{pending_tuples}->{$nickdev}}, \@_);
  my $deleted = delete $self->{until_messagecount}->{$nickdev}->{$anchortype};
  if (! keys %{$self->{until_messagecount}->{$nickdev}}) {
    if ($deleted) {
      my $count = 0;
      my %seen_uuids;
      foreach my $pending (@{$self->{pending_tuples}->{$nickdev}}) {
        foreach my $pullitem (@{$pending->[3] || []}) {
          my $uuid = $pullitem->uniqueid();
          if ($self->{seen_uuids}->{$nickdev}->{$uuid} ||
              $seen_uuids{$uuid}) {
            next;
          }
          if ($self->{acked_uuids}->{$nickdev}->{_to_hex($uuid)}) {
            next;
          }
          $seen_uuids{$uuid} = 1;
          my $payload = $pullitem->payload();
          if (Jaiku::Tuple::UserGiven::is_usergiven(
                  $payload->tuplemeta()->moduleuid()->value(),
                  $payload->tuplemeta()->moduleid()->value())) {
            # skip presenceline as it may not get sent to the client
            next;
          }
          $count++;
        }
      }
      my $conn = $self->{connections}->{$nickdev};
      $conn->messagecount($count);
    }
    foreach my $pending (@{$self->{pending_tuples}->{$nickdev}}) {
      $self->_got_tuples(@$pending);
    }
    delete $self->{pending_tuples}->{$nickdev};
  }
}

sub _got_tuples {
  my ($self, $anchortype, $nick, $device_id, $tuples, $server_time, $error) =
      @_;
  log_info("_got_tuples");
  if (!defined($tuples)) {
    log_error("error getting tuples " . ($error || "without error message"));
    return;
  }
  $server_time = _subtract_propagation_delay($server_time);
  if (!$server_time) {
    die "did not get server time";
  }
  my $nickdev = nick_dev([$nick, $device_id]);
  my $conn = $self->{connections}->{$nickdev};
  if (!$conn) {
    # Disconnected while we were getting data.
    return;
  }
  my $syncqueue = $self->{syncqueues}->{$nickdev};
  my $got_some = 0;
  my $new_anchor;
  my $max_item_timestamp = "2001-01-01 00:00:00";
  my %old_pending;
  map { $old_pending{$_} = 1 }
      keys %{$self->{pending_uuids}->{$anchortype}};
  foreach my $pullitem (@$tuples) {
    die "no timestamp" unless($pullitem->timestamp());
    die "no uniqueid" unless($pullitem->uniqueid());
    if ($pullitem->timestamp() gt $max_item_timestamp) {
      $max_item_timestamp = $pullitem->timestamp();
    }
    delete $old_pending{_to_hex($pullitem->uniqueid())};
    if ($self->{seen_uuids}->{$nickdev}->{$pullitem->uniqueid()}) {
      next;
    }
    if ($self->{acked_uuids}->{$nickdev}->{_to_hex($pullitem->uniqueid())}) {
      next;
    }
    $self->{seen_uuids}->{$nickdev}->{$pullitem->uniqueid()} =
        $pullitem->timestamp();
    $self->{pending_uuids}->{$nickdev}->{$anchortype}->{_to_hex($pullitem->uniqueid())}++;
    if ($self->{pending_uuids}->{$nickdev}->{$anchortype}
            ->{_to_hex($pullitem->uniqueid())} > MAX_TRIES) {
      print STDERR "Skipping message after too many retries\n";
      next;
    }
    $new_anchor = $syncqueue->queue($anchortype,
                                    _to_hex($pullitem->uniqueid()),
                                    $pullitem->timestamp());
    log_info("sending message '" . _to_hex($pullitem->uniqueid()) . "'");
    $conn->got_message($pullitem->payload());
    if ($anchortype == ANCHOR_CONTACTS) {
      $self->{expensive_uuids}->{$nickdev}->{
          _to_hex($pullitem->uniqueid())} = $pullitem->timestamp();
    }
    $got_some = 1;
  }
  map { delete $self->{pending_uuids}->{$anchortype}->{$_} }
      keys %old_pending;
  my $new_transient_anchor = $max_item_timestamp;
  if ($server_time lt $new_transient_anchor) {
    $new_transient_anchor = $server_time;
  }
  die "no new_transient_anchor" unless($new_transient_anchor);
  if ($new_transient_anchor gt $self->{anchors}->{$nickdev}->{$anchortype}) {
    $self->{anchors}->{$nickdev}->{$anchortype} = $new_transient_anchor;
  }
  if (!$got_some) {
    $new_anchor = $syncqueue->no_items_at($anchortype, $server_time);
  }
  my $storage = $self->storage($nick, $device_id);
  if ($new_anchor) {
    $storage->set_anchor($nick, $device_id, $anchortype, $new_anchor,
                          sub {
                            my ($ret, $error) = @_;
                            if (!$ret) {
                              log_error($error);
                            }
                          });
  }
  $self->_set_poll_timer($nick, $device_id);
}

#sub messages_cb {
#  my $self=shift;
#  my $id=shift;
#  my $args=thaw shift;
#
#  my ($retval, $messages, $datahash)=@$args;
#  unless ($retval) {
#    log_error "getting messages error " . $retval;
#    return;
#  }
#  $self->{retrieval_ids}->{$id}++;
#  #log_info "MESSAGES_CB: $#$messages";
#  if ($#{$messages} > -1) {
#    $self->get_messages();
#  }
#
#  foreach my $row (@$messages) {
#    my ($message_id, $module_uid, $module_id, $subname, $expires,
#      $data_id, $nick, $device_id) = @$row;
#
#        if ($subname=~/^(\d+)\?(\d+)$/) {
#            $subname=$1;
#        }
#    my $data=$datahash->{$data_id};
#    $self->{message_ids}->{$message_id}=$id;
#    my $tuple=new Jaiku::BBData::Tuple;
#    $tuple->tupleuuid->set_value($message_id);
#    $tuple->tuplemeta->moduleuid->set_value($module_uid);
#    $tuple->tuplemeta->moduleid->set_value($module_id);
#    $tuple->tuplemeta->subname->set_value($subname);
#    $expires=~s/[:-]//g;
#    $expires=~s/ /T/;
#    $tuple->expires->set_value($expires);
#    $tuple->set_data( new Jaiku::RawXML($data) ) if ( ($data || "") ne "");
#    $tuple->set_type_attributes;
#
#    my $conn=$self->{connections}->{ nick_dev( [ $nick, $device_id ] ) };
#    if ($conn) {
#      eval { $conn->got_message($tuple); };
#      log_error "error notifying connection of new message " . $@  if($@);
#    }
#  }
#}
#

# Introspection methods for tests

sub syncqueue {
  my ($self, $nick, $device) = @_;
  return $self->{syncqueues}->{nick_dev([$nick, $device])};
}

sub _to_hex {
  my ($bytes) = @_;
  my $ret = '';
  foreach my $c (split(//, $bytes)) {
    $ret .= sprintf "%02x", ord($c);
  }
  return $ret;
}

1;
