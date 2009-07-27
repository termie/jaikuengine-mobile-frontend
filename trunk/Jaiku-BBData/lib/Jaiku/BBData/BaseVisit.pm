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
package Jaiku::BBData::BaseVisit;

use base qw(Jaiku::BBData::Compound);
use Jaiku::BBData::Base;
use fields qw( baseid entered basename left );
use Jaiku::BBData::Uint;
use Jaiku::BBData::LongString;
use Jaiku::BBData::Time;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'baseid' => 'base.id', 'basename' => 'base.name', 'entered' => 'base.arrived', 'left' => 'base.left',  };
    $xml_to_field = { 'base.id' => 'baseid', 'base.name' => 'basename', 'base.arrived' => 'entered', 'base.left' => 'left',  };
}

sub new {
    my $class=shift;
    my $name=shift;
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 30, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub baseid {
    my $self=shift;
    return $self->{baseid} if ($self->{baseid});
    my $ret=new Jaiku::BBData::Uint('base.id');
    $self->{baseid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_baseid {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{baseid}, $c );
    $self->{baseid}=$c;
}

sub basename {
    my $self=shift;
    return $self->{basename} if ($self->{basename});
    my $ret=new Jaiku::BBData::LongString('base.name');
    $self->{basename}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_basename {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{basename}, $c );
    $self->{basename}=$c;
}

sub entered {
    my $self=shift;
    return $self->{entered} if ($self->{entered});
    my $ret=new Jaiku::BBData::Time('base.arrived');
    $self->{entered}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_entered {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{entered}, $c );
    $self->{entered}=$c;
}

sub left {
    my $self=shift;
    return $self->{left} if ($self->{left});
    my $ret=new Jaiku::BBData::Time('base.left');
    $self->{left}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_left {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{left}, $c );
    $self->{left}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
