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
use fields qw( nick serviceclass majorclass mac minorclass );
use Jaiku::BBData::Int;
use Jaiku::BBData::BluetoothAddress;
use Jaiku::BBData::BluetoothName;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'mac' => 'bt.mac', 'nick' => 'name', 'majorclass' => 'bt.majorclass', 'minorclass' => 'bt.minorclass', 'serviceclass' => 'bt.serviceclass',  };
    $xml_to_field = { 'bt.mac' => 'mac', 'name' => 'nick', 'bt.majorclass' => 'majorclass', 'bt.minorclass' => 'minorclass', 'bt.serviceclass' => 'serviceclass',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'device';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 3, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub mac {
    my $self=shift;
    return $self->{mac} if ($self->{mac});
    my $ret=new Jaiku::BBData::BluetoothAddress;
    $self->{mac}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_mac {
    my $self=shift;
    my $c=Jaiku::BBData::BluetoothAddress->downbless(shift());
    $self->replace_child( $self->{mac}, $c );
    $self->{mac}=$c;
}

sub nick {
    my $self=shift;
    return $self->{nick} if ($self->{nick});
    my $ret=new Jaiku::BBData::BluetoothName;
    $self->{nick}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_nick {
    my $self=shift;
    my $c=Jaiku::BBData::BluetoothName->downbless(shift());
    $self->replace_child( $self->{nick}, $c );
    $self->{nick}=$c;
}

sub majorclass {
    my $self=shift;
    return $self->{majorclass} if ($self->{majorclass});
    my $ret=new Jaiku::BBData::Int('bt.majorclass');
    $self->{majorclass}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_majorclass {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{majorclass}, $c );
    $self->{majorclass}=$c;
}

sub minorclass {
    my $self=shift;
    return $self->{minorclass} if ($self->{minorclass});
    my $ret=new Jaiku::BBData::Int('bt.minorclass');
    $self->{minorclass}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_minorclass {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{minorclass}, $c );
    $self->{minorclass}=$c;
}

sub serviceclass {
    my $self=shift;
    return $self->{serviceclass} if ($self->{serviceclass});
    my $ret=new Jaiku::BBData::Int('bt.serviceclass');
    $self->{serviceclass}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_serviceclass {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{serviceclass}, $c );
    $self->{serviceclass}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
