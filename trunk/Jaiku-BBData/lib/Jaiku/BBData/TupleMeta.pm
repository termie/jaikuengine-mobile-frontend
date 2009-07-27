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
package Jaiku::BBData::TupleMeta;

use base qw(Jaiku::BBData::Compound);
use Jaiku::BBData::Base;
use fields qw( moduleuid subname moduleid );
use Jaiku::BBData::Int;
use Jaiku::BBData::Uid;
use Jaiku::BBData::TupleSubName;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'moduleuid' => 'module_uid', 'moduleid' => 'module_id', 'subname' => 'subname',  };
    $xml_to_field = { 'module_uid' => 'moduleuid', 'module_id' => 'moduleid', 'subname' => 'subname',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'tuplename';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 9, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub moduleuid {
    my $self=shift;
    return $self->{moduleuid} if ($self->{moduleuid});
    my $ret=new Jaiku::BBData::Uid('module_uid');
    $self->{moduleuid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_moduleuid {
    my $self=shift;
    my $c=Jaiku::BBData::Uid->downbless(shift());
    $self->replace_child( $self->{moduleuid}, $c );
    $self->{moduleuid}=$c;
}

sub moduleid {
    my $self=shift;
    return $self->{moduleid} if ($self->{moduleid});
    my $ret=new Jaiku::BBData::Int('module_id');
    $self->{moduleid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_moduleid {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{moduleid}, $c );
    $self->{moduleid}=$c;
}

sub subname {
    my $self=shift;
    return $self->{subname} if ($self->{subname});
    my $ret=new Jaiku::BBData::TupleSubName('subname');
    $self->{subname}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_subname {
    my $self=shift;
    my $c=Jaiku::BBData::TupleSubName->downbless(shift());
    $self->replace_child( $self->{subname}, $c );
    $self->{subname}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
