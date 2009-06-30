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
use fields qw( internalversion sdk buildby minorversion when majorversion branch );
use Jaiku::BBData::Int;
use Jaiku::BBData::LongString;
use Jaiku::BBData::Time;
use Jaiku::BBData::ShortString;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'when' => 'when', 'buildby' => 'buildby', 'sdk' => 'sdk', 'branch' => 'branch', 'majorversion' => 'majorversion', 'minorversion' => 'minorversion', 'internalversion' => 'internalversion',  };
    $xml_to_field = { 'when' => 'when', 'buildby' => 'buildby', 'sdk' => 'sdk', 'branch' => 'branch', 'majorversion' => 'majorversion', 'minorversion' => 'minorversion', 'internalversion' => 'internalversion',  };
}

sub new {
    my $class=shift;
    my $name=shift;
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 53, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub when {
    my $self=shift;
    return $self->{when} if ($self->{when});
    my $ret=new Jaiku::BBData::Time('when');
    $self->{when}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_when {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{when}, $c );
    $self->{when}=$c;
}

sub buildby {
    my $self=shift;
    return $self->{buildby} if ($self->{buildby});
    my $ret=new Jaiku::BBData::ShortString('buildby');
    $self->{buildby}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_buildby {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{buildby}, $c );
    $self->{buildby}=$c;
}

sub sdk {
    my $self=shift;
    return $self->{sdk} if ($self->{sdk});
    my $ret=new Jaiku::BBData::LongString('sdk');
    $self->{sdk}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_sdk {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{sdk}, $c );
    $self->{sdk}=$c;
}

sub branch {
    my $self=shift;
    return $self->{branch} if ($self->{branch});
    my $ret=new Jaiku::BBData::LongString('branch');
    $self->{branch}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_branch {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{branch}, $c );
    $self->{branch}=$c;
}

sub majorversion {
    my $self=shift;
    return $self->{majorversion} if ($self->{majorversion});
    my $ret=new Jaiku::BBData::Int('majorversion');
    $self->{majorversion}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_majorversion {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{majorversion}, $c );
    $self->{majorversion}=$c;
}

sub minorversion {
    my $self=shift;
    return $self->{minorversion} if ($self->{minorversion});
    my $ret=new Jaiku::BBData::Int('minorversion');
    $self->{minorversion}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_minorversion {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{minorversion}, $c );
    $self->{minorversion}=$c;
}

sub internalversion {
    my $self=shift;
    return $self->{internalversion} if ($self->{internalversion});
    my $ret=new Jaiku::BBData::Int('internalversion');
    $self->{internalversion}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_internalversion {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{internalversion}, $c );
    $self->{internalversion}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
