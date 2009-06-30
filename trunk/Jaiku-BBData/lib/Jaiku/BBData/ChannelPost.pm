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

use base qw(Jaiku::BBData::Compound);
use Jaiku::BBData::Base;
use fields qw( nick created displayname uuid content channel );
use Jaiku::BBData::ShortString;
use Jaiku::BBData::LongString;
use Jaiku::BBData::UUID;
use Jaiku::BBData::String;
use Jaiku::BBData::Time;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'uuid' => 'uuid', 'channel' => 'channel', 'nick' => 'nick', 'displayname' => 'displayname', 'content' => 'content', 'created' => 'created',  };
    $xml_to_field = { 'uuid' => 'uuid', 'channel' => 'channel', 'nick' => 'nick', 'displayname' => 'displayname', 'content' => 'content', 'created' => 'created',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'channelpost';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 58, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub uuid {
    my $self=shift;
    return $self->{uuid} if ($self->{uuid});
    my $ret=new Jaiku::BBData::UUID('uuid');
    $self->{uuid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_uuid {
    my $self=shift;
    my $c=Jaiku::BBData::UUID->downbless(shift());
    $self->replace_child( $self->{uuid}, $c );
    $self->{uuid}=$c;
}

sub channel {
    my $self=shift;
    return $self->{channel} if ($self->{channel});
    my $ret=new Jaiku::BBData::ShortString('channel');
    $self->{channel}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_channel {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{channel}, $c );
    $self->{channel}=$c;
}

sub nick {
    my $self=shift;
    return $self->{nick} if ($self->{nick});
    my $ret=new Jaiku::BBData::ShortString('nick');
    $self->{nick}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_nick {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{nick}, $c );
    $self->{nick}=$c;
}

sub displayname {
    my $self=shift;
    return $self->{displayname} if ($self->{displayname});
    my $ret=new Jaiku::BBData::LongString('displayname');
    $self->{displayname}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_displayname {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{displayname}, $c );
    $self->{displayname}=$c;
}

sub content {
    my $self=shift;
    return $self->{content} if ($self->{content});
    my $ret=new Jaiku::BBData::String('content');
    $self->{content}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_content {
    my $self=shift;
    my $c=Jaiku::BBData::String->downbless(shift());
    $self->replace_child( $self->{content}, $c );
    $self->{content}=$c;
}

sub created {
    my $self=shift;
    return $self->{created} if ($self->{created});
    my $ret=new Jaiku::BBData::Time('created');
    $self->{created}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_created {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{created}, $c );
    $self->{created}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
