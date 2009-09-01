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
package Jaiku::Backend::API;

#
# A backend module for DJabberd-Jaiku-MessageQueue that retrieves pending data
# via the Jaiku API.

package Jaiku::Backend::API;

use fields qw(api);
use strict;
use warnings;

use Data::Dumper;
use DJabberd::Jaiku::Avatar;
use DJabberd::Jaiku::Transforms;
use Jaiku::BBData::All;
use Jaiku::Presence qw(formatted_to_datetime mysql_datetime
                       format_datetime current_time);
use Jaiku::PullItem;
use Jaiku::Tuple::FeedItem;
use Jaiku::Tuple::UserPic;
use Jaiku::Tuple::UserGiven;

sub new {
  my Jaiku::Backend::API $self = shift;
  my ($api) = @_;
  $self = fields::new($self) unless ref $self;
  $self->{api} = $api;
  return $self;
}

# Backend methods
sub received_message {
  my ($self, $nick, $xml, $cb) = @_;
  my $api = $self->{api};
  my $id = $xml->tupleid()->value();
  my $put_handler = sub {
    my ($parsed, $error) = @_;
    if (!$parsed || $parsed->{status} ne 'ok') {
      $cb->(undef, $error);
    } else {
      $cb->($id, undef);
    }
  };
  if (Jaiku::Tuple::FeedItem::is_feeditem(
          $xml->tuplemeta()->moduleuid()->value(),
          $xml->tuplemeta()->moduleid()->value())) {
    my $post = DJabberd::Jaiku::Transforms::feeditem_to_api(
        $xml->data()->as_parsed());
    $post->{callback} = $put_handler;
    $post->{nick} = $nick;
    if (!$post->{entry_uuid}) {
      $api->post(%$post);
    } else {
      $api->entry_add_comment_with_entry_uuid(%$post);
    }
  } elsif (Jaiku::Tuple::ThreadRequest::is_threadrequest(
          $xml->tuplemeta()->moduleuid()->value(),
          $xml->tuplemeta()->moduleid()->value())) {
    my $thread_uuid = $xml->data()->postuuid()->value();
    # strip legacy uuid prefix
    $thread_uuid =~ s/^100000000+//;
    my $handler = sub {
      my ($parsed, $error) = @_;
      if (!$parsed || $parsed->{status} ne 'ok') {
        if ($parsed) {
          $error .= " " . $parsed->{status};
        }
        $cb->(undef, undef, $error);
        return;
      }
      my @ret;
      my @entries = @{$parsed->{rv}->{comments}};
      push(@entries, $parsed->{rv}->{entry});
      my $rows = 0;
      foreach my $item (@entries) {
        my $timestamp = $item->{created_at};
        my $tuple = _tuple_from_feeditem($item);
        push(@ret, $tuple);
        $rows++;
      }
      #print STDERR Dumper(\@ret);
      $cb->($id, \@ret, undef);
    };
    $api->entry_get_comments_with_entry_uuid(callback => $handler,
                                             entry_uuid => $thread_uuid);
  } else {
    $cb->($id, undef, undef);
  }
}

sub _pullitem_from_avatar {
  my ($nick, $uuid, $timestamp, $data) = @_;
  my $tuple = Jaiku::Tuple::UserPic::make($nick, '', _to_hex($data));
  $tuple->tupleuuid()->set_value($uuid);
  return Jaiku::PullItem->new(
      uuid => $uuid,
      timestamp => $timestamp,
      payload => $tuple);
}

sub _async {
  my ($cb) = @_;
  return sub {
    my @args = @_;
    Danga::Socket->AddTimer(0, sub { $cb->(@args); });
  };
}

sub _fix_uuid {
  my ($uuid, $uuid_type) = @_;
  if (length($uuid) < 32) {
    # Test server has weird uuids.
    my $fill = 32 - length($uuid) - 1;
    $uuid = $uuid_type . "0" x $fill . $uuid;
  }
  if (length($uuid) > 32) {
    $uuid = substr($uuid, 0, 32);
  }
  return $uuid;
}


sub get_contacts {
  my ($self, $nick, $anchor, $cb) = @_;
  $anchor ||= '';
  my $api = $self->{api};
  my $handler = sub {
    my ($parsed, $error) = @_;
    if ((!$parsed) || ($parsed->{status} ne 'ok')) {
      if ($parsed) {
        $error .= " " . $parsed->{message};
      }
      $cb->([ undef, undef, $error ]);
      return;
    }
    my @ret;
    my $to_get = 0;
    my $servertime = $parsed->{servertime};
    my $tmpdir = "../../tmp/avatars";
    my $all_errors = '';
    my $avatar_handler = sub {
      my ($nick, $uuid, $timestamp, $data, $error) = @_;
      $to_get--;
      if (!$data) {
        $error ||= "no error given";
        $all_errors .= $error . "; ";
      } else {
        push(@ret, _pullitem_from_avatar($nick, $uuid, $timestamp, $data));
      }
      if ($to_get == 0) {
        $cb->([ \@ret, $servertime, $all_errors ]);
      }
    };
    foreach my $actor (@{$parsed->{rv}->{contacts}}) {
      $actor = $actor->{actor};
      my $nick = $actor->{nick};
      my $url = $actor->{extra}->{icon};
      next unless($url);
      my $timestamp = $actor->{avatar_updated_at};
      $to_get++;
      my $outer_avatar_handler = sub {
        my ($ret, $error) = @_;
        my ($data, $uuid);
        if ($ret) {
          ($data, $uuid) = @$ret;
        }
        $avatar_handler->($nick, $uuid, $timestamp, $data, $error);
      };
      DJabberd::Jaiku::Avatar::get_avatar(
          $nick, $url, $tmpdir, $api,
          _async($outer_avatar_handler));
    }
    if ($to_get == 0) {
      $cb->([ [], $servertime, '']);
    }
  };
  $api->actor_get_contacts_avatars_since(callback => _async($handler),
                                         nick => $nick,
                                         limit => 100,
                                         since_time => $anchor);
}

sub get_presence {
  my ($self, $nick, $anchor, $cb) = @_;
  $anchor ||= '';
  $anchor =~ s/\.\d+//;
  my $api = $self->{api};
  my $handler = sub {
    my ($parsed, $error) = @_;
    if (!$parsed || $parsed->{status} ne 'ok') {
      if ($parsed) {
        $error .= " " . $parsed->{status};
      }
      $cb->([ undef, undef, $error ]);
      return;
    }
    my @ret;
    $nick =~ s/\@.*//;
    foreach my $item (@{$parsed->{rv}->{contacts}}) {
      my $data;
      my $extra = $item->{presence}->{extra};
      my $tuple = Jaiku::BBData::Tuple->new("tuple");
      my $actor = $item->{presence}->{actor};
      $actor =~ s/\@.*//;
      # Need to turn different legacy sequential ids into unique ids.
      my $uuid_type = "3";
      if ($nick eq $actor) {
        $data = Jaiku::BBData::UserGiven->new("tuplevalue");
        $data->description()->set_value($extra->{presenceline}->{description});
        $data->since()->set_value($extra->{presenceline}->{since});
        $tuple->tuplemeta()->moduleuid()->set_value(Jaiku::Tuple::UserGiven::UID);
        $tuple->tuplemeta()->moduleid()->set_value(Jaiku::Tuple::UserGiven::ID);
        $uuid_type = 4;
      } else {
        my $value = DJabberd::Jaiku::Transforms::api_to_presence(
            $extra);
        $data = Jaiku::BBData::Presence->new("tuplevalue");
        eval {
          $data->from_parsed($value);
        };
        if ($@) {
          die "$@ while parsing " . Dumper($value);
	}
        $tuple->tuplemeta()->moduleuid()->set_value(Jaiku::Presence::UID);
        $tuple->tuplemeta()->moduleid()->set_value(Jaiku::Presence::ID);
        $tuple->tuplemeta()->subname()->set_value($item->{presence}->{actor});
      }
      my $uuid = $item->{presence}->{uuid};
      $uuid = _fix_uuid($uuid);
      my $timestamp = $item->{presence}->{updated_at};
      my $expires = format_datetime(formatted_to_datetime($timestamp) +
                                    2 * 365 * 24 * 60 * 60);
      $tuple->set_data($data);
      $tuple->tupleuuid()->set_value($uuid);
      $tuple->expires()->set_value($expires);
      $tuple->set_type_attributes();
      $data->set_type_attributes();
      my $pullitem = Jaiku::PullItem->new(
          uuid => $uuid,
          timestamp => $timestamp,
          payload => $tuple);
      push(@ret, $pullitem);
    }
    $cb->([ \@ret, $parsed->{servertime}, undef ]);
  };
  $api->presence_get_contacts(callback => $handler, nick => $nick,
                              since_time => $anchor);
}

sub _tuple_from_feeditem {
  my ($item) = @_;
  my $uuid = $item->{uuid};
  my $timestamp = $item->{created_at};
  # Need to turn different legacy sequential ids into unique ids.
  my $uuid_type = "1";  # post
  if (my $postuuid = $item->{extra}->{entry_uuid}) {
    # comment
    $uuid_type = "2";
    $item->{extra}->{entry_uuid} = _fix_uuid($postuuid, "1");
  }
  $uuid = _fix_uuid($uuid, $uuid_type);
  $item->{uuid} = $uuid;
  my $value = DJabberd::Jaiku::Transforms::api_to_feeditem($item);
  my $feeditem = Jaiku::BBData::FeedItem->new("tuplevalue");
  my $expires = format_datetime(formatted_to_datetime($timestamp) +
                                2 * 24 * 60 * 60);
  #print STDERR Dumper($value);
  eval {
    $feeditem->from_parsed($value);
  };
  if ($@) {
    die "$@ while parsing " . Dumper($value);
  }
  my $tuple = Jaiku::BBData::Tuple->new("tuple");
  $tuple->set_data($feeditem);
  $tuple->tuplemeta()->moduleuid()->set_value(Jaiku::Tuple::FeedItem::UID);
  $tuple->tuplemeta()->moduleid()->set_value(Jaiku::Tuple::FeedItem::ID);
  $tuple->tuplemeta()->subname()->set_value($uuid);
  $tuple->tupleuuid()->set_value($uuid);
  $tuple->expires()->set_value($expires);
  $tuple->set_type_attributes();
  $feeditem->set_type_attributes();
  return $tuple;
}

sub get_feeditems {
  my ($self, $nick, $anchor, $cb) = @_;
  $anchor ||= '';
  $anchor =~ s/\.\d+//; 
  my $limit = mysql_datetime(current_time() - 2 * 24 * 60 * 60);
  if ($anchor lt $limit) {
    $anchor = $limit;
  }
  my $api = $self->{api};
  my $handler = sub {
    my ($parsed, $error) = @_;
    if (!$parsed || $parsed->{status} ne 'ok') {
      if ($parsed) {
        $error .= " " . $parsed->{status};
      }
      $cb->([ undef, undef, $error ]);
      return;
    }
    my @ret;
    my $last_channel_post_timestamp;
    foreach my $item (@{$parsed->{rv}->{entries}}) {
      my $timestamp = $item->{created_at};
      if ($item->{stream} =~ /#/) {
        $last_channel_post_timestamp = $timestamp;
        next;
      }
      $last_channel_post_timestamp = undef;
      my $tuple = _tuple_from_feeditem($item);
      my $pullitem = Jaiku::PullItem->new(
          uuid => $tuple->tupleuuid()->value(),
          timestamp => $timestamp,
          payload => $tuple);
      push(@ret, $pullitem);
    }
    my $servertime = $parsed->{servertime};
    if ($last_channel_post_timestamp) {
      $servertime = $last_channel_post_timestamp;
    }
    $cb->([ \@ret, $servertime, undef ]);
  };
  $api->entry_get_actor_overview_since(callback => $handler,
                                       nick => $nick,
                                       since_time => $anchor);
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
