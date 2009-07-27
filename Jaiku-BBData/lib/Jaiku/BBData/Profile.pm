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
package Jaiku::BBData::Profile;

use base qw(Jaiku::BBData::Compound);
use Jaiku::BBData::Base;
use fields qw( ringingvolume ringingtype profilename vibra profileid );
use Jaiku::BBData::ShortString;
use Jaiku::BBData::Bool;
use Jaiku::BBData::Int;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'profileid' => 'profile.id', 'profilename' => 'profile.name', 'ringingtype' => 'profile.ringtype', 'ringingvolume' => 'profile.ringvolume', 'vibra' => 'profile.vibra',  };
    $xml_to_field = { 'profile.id' => 'profileid', 'profile.name' => 'profilename', 'profile.ringtype' => 'ringingtype', 'profile.ringvolume' => 'ringingvolume', 'profile.vibra' => 'vibra',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'profile';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 13, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub profileid {
    my $self=shift;
    return $self->{profileid} if ($self->{profileid});
    my $ret=new Jaiku::BBData::Int('profile.id');
    $self->{profileid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_profileid {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{profileid}, $c );
    $self->{profileid}=$c;
}

sub profilename {
    my $self=shift;
    return $self->{profilename} if ($self->{profilename});
    my $ret=new Jaiku::BBData::ShortString('profile.name');
    $self->{profilename}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_profilename {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{profilename}, $c );
    $self->{profilename}=$c;
}

sub ringingtype {
    my $self=shift;
    return $self->{ringingtype} if ($self->{ringingtype});
    my $ret=new Jaiku::BBData::Int('profile.ringtype');
    $self->{ringingtype}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_ringingtype {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{ringingtype}, $c );
    $self->{ringingtype}=$c;
}

sub ringingvolume {
    my $self=shift;
    return $self->{ringingvolume} if ($self->{ringingvolume});
    my $ret=new Jaiku::BBData::Int('profile.ringvolume');
    $self->{ringingvolume}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_ringingvolume {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{ringingvolume}, $c );
    $self->{ringingvolume}=$c;
}

sub vibra {
    my $self=shift;
    return $self->{vibra} if ($self->{vibra});
    my $ret=new Jaiku::BBData::Bool('profile.vibra');
    $self->{vibra}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_vibra {
    my $self=shift;
    my $c=Jaiku::BBData::Bool->downbless(shift());
    $self->replace_child( $self->{vibra}, $c );
    $self->{vibra}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
