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
package Jaiku::Stream;

use strict;
use Jaiku::BBData::FeedItem;
use Jaiku::BBData::StreamData;
use Jaiku::BBData::StreamComment;
use Data::Dumper;

#use Jaiku;
#use Jaiku::Manual;
use Data::UUID;

my $jaiku;
my $ug = new Data::UUID;

#sub x_uuid {
#	my $in=shift;
#	my $kind=shift;
#	$in=~s/[-]//;
#	if (length($in)==32) { return $in; }
#
#	$jaiku ||= new Jaiku::Manual;
#	my $mqueue=Jaiku::logical_to_db("mqueue");
#	my $uuid;
#	$jaiku->run_query( sub {
#		($uuid)=$jaiku->{dbh}->selectrow_array("SELECT uuid FROM $mqueue.read_$kind WHERE stream_$kind =?",
#			undef, $in);
#	});
#	unless ($uuid) {
#		$uuid=$ug->create_str();
#	}
#	$uuid=~s/[-]//g;
#	$uuid=lc($uuid);
#
#	return $uuid;
#}
#
#sub data_uuid {
#	return x_uuid($_[0], "data");
#}
#sub comment_uuid {
#	return x_uuid($_[0], "comment");
#}
#
sub streamdata_to_feeditem {
	my $row=shift;
	my $feeditem=new Jaiku::BBData::FeedItem("tuplevalue");
	$feeditem->uuid->set_value(data_uuid($row->{uuid}));
	$feeditem->iconid->set_value($row->{iconid});
	$feeditem->authornick->set_value($row->{authornick});
	$feeditem->authordisplayname->set_value($row->{authordisplayname});
	$feeditem->kind->set_value($row->{'kind'});
	$feeditem->correlation->set_value($row->{'correlation'});
	if ($row->{kind} eq "presence") {
		$feeditem->location->set_value($row->{'content'}) if ($row->{'content'});
	} else {
		$feeditem->thumbnailurl->set_value($row->{'content'}) if ($row->{'content'});
	}
	$feeditem->content->set_value($row->{'title'});
	$feeditem->linkedurl->set_value($row->{'url'}) if ($row->{'url'});
	$feeditem->created->set_value($row->{created});
    $feeditem->channel->set_value($row->{channelname}) if ($row->{channelname});
	$feeditem->set_type_attributes;
	return $feeditem;
}

sub streamcomment_to_feeditem {
	my $row=shift;
	my $feeditem=new Jaiku::BBData::FeedItem("tuplevalue");
	$feeditem->uuid->set_value(comment_uuid($row->{uuid}));
	$feeditem->parentuuid->set_value(data_uuid($row->{postuuid}));
	$feeditem->authornick->set_value($row->{authornick});
	$feeditem->authordisplayname->set_value($row->{authordisplayname});
	$feeditem->content->set_value($row->{'content'});
	$feeditem->created->set_value($row->{created});
    $feeditem->parentauthornick->set_value($row->{postauthornick}) if ($row->{postauthornick});
    $feeditem->parenttitle->set_value($row->{posttitle}) if ($row->{posttitle});
    $feeditem->channel->set_value($row->{channelname}) if ($row->{channelname});
    $feeditem->streamdataid->set_value($row->{streamdataid}) if ($row->{streamdataid});
	$feeditem->set_type_attributes;
	return $feeditem;
}

sub feeditem_to_stream_x {
	my $nick=shift;
	my $feeditem=shift;
	foreach my $k (%$feeditem) {
		$feeditem->{$k}='' if (ref $feeditem->{$k});
	}
	my $parent;
	my $node=$nick;
	$node=~s/\@jaiku.com//;
	my $stream_item;

	if ($feeditem->{parentuuid} && (! ref $feeditem->{parentuuid}) ) {
		#print "comment";
		$stream_item=new Jaiku::BBData::StreamComment;	
		$stream_item->postuuid->set_value($feeditem->{parentuuid});
		$stream_item->content->set_value($feeditem->{content});
	} else {
		#print "post";
		$stream_item=new Jaiku::BBData::StreamData;	
		$stream_item->title->set_value($feeditem->{content});
		$stream_item->content->set_value($feeditem->{location});
		$stream_item->content->set_value($feeditem->{thumbnailurl}) if ($feeditem->{thumbnailurl});
		$stream_item->kind->set_value($feeditem->{kind});
		$stream_item->iconid->set_value($feeditem->{iconid});
        $stream_item->url->set_value($feeditem->{linkedurl});
	}
    $stream_item->channelname->set_value($feeditem->{channel}) if ($feeditem->{channel});
	$stream_item->authornick->set_value($feeditem->{authornick});
	$stream_item->uuid->set_value($feeditem->{uuid});
	$stream_item->created->set_value($feeditem->{created});

	#print STDERR "FEEDITEM " . Dumper($stream_item);
	return $stream_item;
}
1;
