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
use fields qw( stamp priority data name );
use Jaiku::BBData::ShortString;
use Jaiku::BBData::Int;
use Jaiku::BBData::Time;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'stamp' => 'datetime', 'priority' => 'priority', 'name' => 'eventname', 'data' => 'eventdata',  };
    $xml_to_field = { 'datetime' => 'stamp', 'priority' => 'priority', 'eventname' => 'name', 'eventdata' => 'data',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'event';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 10, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub stamp {
    my $self=shift;
    return $self->{stamp} if ($self->{stamp});
    my $ret=new Jaiku::BBData::Time('datetime');
    $self->{stamp}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_stamp {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{stamp}, $c );
    $self->{stamp}=$c;
}

sub priority {
    my $self=shift;
    return $self->{priority} if ($self->{priority});
    my $ret=new Jaiku::BBData::Int('priority');
    $self->{priority}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_priority {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{priority}, $c );
    $self->{priority}=$c;
}

sub name {
    my $self=shift;
    return $self->{name} if ($self->{name});
    my $ret=new Jaiku::BBData::ShortString('eventname');
    $self->{name}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_name {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{name}, $c );
    $self->{name}=$c;
}

sub data {
    my $self=shift;
    return $self->{data} if ($self->{data});
}

sub set_data {
    my $self=shift;
    my $c=Jaiku::BBData::Factory::cast_xml(shift());
    $self->replace_child( $self->{data}, $c );
    $self->{data}=$c;
    $c->set_type_attributes;
    $c->{element}='eventdata';
}


Jaiku::BBData::Factory::add_class();

1;
