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
package Jaiku::BBData::BaseInfo;

use base qw(Jaiku::BBData::Compound);
use Jaiku::BBData::Base;
use fields qw( current previousvisit previousstay );
use Jaiku::BBData::BaseVisit;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'previousstay' => 'base.previous', 'previousvisit' => 'base.lastseen', 'current' => 'base.current',  };
    $xml_to_field = { 'base.previous' => 'previousstay', 'base.lastseen' => 'previousvisit', 'base.current' => 'current',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'base';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 24, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub previousstay {
    my $self=shift;
    return $self->{previousstay} if ($self->{previousstay});
    my $ret=new Jaiku::BBData::BaseVisit('base.previous');
    $self->{previousstay}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_previousstay {
    my $self=shift;
    my $c=Jaiku::BBData::BaseVisit->downbless(shift());
    $self->replace_child( $self->{previousstay}, $c );
    $self->{previousstay}=$c;
}

sub previousvisit {
    my $self=shift;
    return $self->{previousvisit} if ($self->{previousvisit});
    my $ret=new Jaiku::BBData::BaseVisit('base.lastseen');
    $self->{previousvisit}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_previousvisit {
    my $self=shift;
    my $c=Jaiku::BBData::BaseVisit->downbless(shift());
    $self->replace_child( $self->{previousvisit}, $c );
    $self->{previousvisit}=$c;
}

sub current {
    my $self=shift;
    return $self->{current} if ($self->{current});
    my $ret=new Jaiku::BBData::BaseVisit('base.current');
    $self->{current}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_current {
    my $self=shift;
    my $c=Jaiku::BBData::BaseVisit->downbless(shift());
    $self->replace_child( $self->{current}, $c );
    $self->{current}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
