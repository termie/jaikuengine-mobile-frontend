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
use fields qw( postuuid streamdataid threadowner );
use Jaiku::BBData::Int;
use Jaiku::BBData::ShortString;
use Jaiku::BBData::UUID;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'threadowner' => 'threadowner', 'postuuid' => 'postuuid', 'streamdataid' => 'streamdataid',  };
    $xml_to_field = { 'threadowner' => 'threadowner', 'postuuid' => 'postuuid', 'streamdataid' => 'streamdataid',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'threadrequest';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 59, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub threadowner {
    my $self=shift;
    return $self->{threadowner} if ($self->{threadowner});
    my $ret=new Jaiku::BBData::ShortString('threadowner');
    $self->{threadowner}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_threadowner {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{threadowner}, $c );
    $self->{threadowner}=$c;
}

sub postuuid {
    my $self=shift;
    return $self->{postuuid} if ($self->{postuuid});
    my $ret=new Jaiku::BBData::UUID('postuuid');
    $self->{postuuid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_postuuid {
    my $self=shift;
    my $c=Jaiku::BBData::UUID->downbless(shift());
    $self->replace_child( $self->{postuuid}, $c );
    $self->{postuuid}=$c;
}

sub streamdataid {
    my $self=shift;
    return $self->{streamdataid} if ($self->{streamdataid});
    my $ret=new Jaiku::BBData::Int('streamdataid');
    $self->{streamdataid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_streamdataid {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{streamdataid}, $c );
    $self->{streamdataid}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
