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
use fields qw( otherphones pdas buddies laptops desktops );
use Jaiku::BBData::Uint;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'buddies' => 'buddies', 'otherphones' => 'other_phones', 'desktops' => 'own_laptops', 'laptops' => 'own_desktops', 'pdas' => 'own_pdas',  };
    $xml_to_field = { 'buddies' => 'buddies', 'other_phones' => 'otherphones', 'own_laptops' => 'desktops', 'own_desktops' => 'laptops', 'own_pdas' => 'pdas',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'bt.presence';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 32, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub buddies {
    my $self=shift;
    return $self->{buddies} if ($self->{buddies});
    my $ret=new Jaiku::BBData::Uint('buddies');
    $self->{buddies}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_buddies {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{buddies}, $c );
    $self->{buddies}=$c;
}

sub otherphones {
    my $self=shift;
    return $self->{otherphones} if ($self->{otherphones});
    my $ret=new Jaiku::BBData::Uint('other_phones');
    $self->{otherphones}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_otherphones {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{otherphones}, $c );
    $self->{otherphones}=$c;
}

sub desktops {
    my $self=shift;
    return $self->{desktops} if ($self->{desktops});
    my $ret=new Jaiku::BBData::Uint('own_laptops');
    $self->{desktops}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_desktops {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{desktops}, $c );
    $self->{desktops}=$c;
}

sub laptops {
    my $self=shift;
    return $self->{laptops} if ($self->{laptops});
    my $ret=new Jaiku::BBData::Uint('own_desktops');
    $self->{laptops}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_laptops {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{laptops}, $c );
    $self->{laptops}=$c;
}

sub pdas {
    my $self=shift;
    return $self->{pdas} if ($self->{pdas});
    my $ret=new Jaiku::BBData::Uint('own_pdas');
    $self->{pdas}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_pdas {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{pdas}, $c );
    $self->{pdas}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
