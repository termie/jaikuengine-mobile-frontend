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
use fields qw( locationareacode cellid mappedid shortname mcc mnc );
use Jaiku::BBData::Uint;
use Jaiku::BBData::ShortNetworkName;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'mcc' => 'location.mcc', 'mnc' => 'location.mnc', 'shortname' => 'location.network', 'locationareacode' => 'location.lac', 'cellid' => 'location.cellid', 'mappedid' => 'location.id',  };
    $xml_to_field = { 'location.mcc' => 'mcc', 'location.mnc' => 'mnc', 'location.network' => 'shortname', 'location.lac' => 'locationareacode', 'location.cellid' => 'cellid', 'location.id' => 'mappedid',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'location.value';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 1, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub mcc {
    my $self=shift;
    return $self->{mcc} if ($self->{mcc});
    my $ret=new Jaiku::BBData::Uint('location.mcc');
    $self->{mcc}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_mcc {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{mcc}, $c );
    $self->{mcc}=$c;
}

sub mnc {
    my $self=shift;
    return $self->{mnc} if ($self->{mnc});
    my $ret=new Jaiku::BBData::Uint('location.mnc');
    $self->{mnc}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_mnc {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{mnc}, $c );
    $self->{mnc}=$c;
}

sub shortname {
    my $self=shift;
    return $self->{shortname} if ($self->{shortname});
    my $ret=new Jaiku::BBData::ShortNetworkName('location.network');
    $self->{shortname}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_shortname {
    my $self=shift;
    my $c=Jaiku::BBData::ShortNetworkName->downbless(shift());
    $self->replace_child( $self->{shortname}, $c );
    $self->{shortname}=$c;
}

sub locationareacode {
    my $self=shift;
    return $self->{locationareacode} if ($self->{locationareacode});
    my $ret=new Jaiku::BBData::Uint('location.lac');
    $self->{locationareacode}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_locationareacode {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{locationareacode}, $c );
    $self->{locationareacode}=$c;
}

sub cellid {
    my $self=shift;
    return $self->{cellid} if ($self->{cellid});
    my $ret=new Jaiku::BBData::Uint('location.cellid');
    $self->{cellid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_cellid {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{cellid}, $c );
    $self->{cellid}=$c;
}

sub mappedid {
    my $self=shift;
    return $self->{mappedid} if ($self->{mappedid});
    my $ret=new Jaiku::BBData::Uint('location.id');
    $self->{mappedid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_mappedid {
    my $self=shift;
    my $c=Jaiku::BBData::Uint->downbless(shift());
    $self->replace_child( $self->{mappedid}, $c );
    $self->{mappedid}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
