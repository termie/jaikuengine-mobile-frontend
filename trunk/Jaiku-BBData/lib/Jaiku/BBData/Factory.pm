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
package Jaiku::BBData::Factory;


my %types;

sub add_class {
    my $class=shift;

    unless (defined($class)) {
        my ($filename, $line);
        ($class, $filename, $line)=caller;
    }
    my $type=$class->type;

    my $uid=Jaiku::Uid::canon($type->[0]);
    $types{$uid}{$type->[1]}=$class;
}

sub create_instance {
    my $type=shift;
    my $name=shift;

    my $class=$types{$type->[0]}{$type->[1]};
    return $class->new($name);
}

sub cast_xml {
    my $element=shift;

    if ($element->isa('Jaiku::BBData')) {
        $element->set_type_attributes;
        return $element;
    }
    if ($element->isa('Jaiku::RawXML')) {
        return $element;
    }
    my ($ns, $name)=$element->element();
    my $type=[
        $element->{attrs}->{'{}module'},
        $element->{attrs}->{'{}id'} ];
    
    my $uid=$type->[0];
    $uid=oct $uid if ($uid=~/^0x/i);
    $uid=Jaiku::Uid::canon($uid);
    my $class=$types{$uid}{$type->[1]};

    die "cannot find class for $uid " . $type->[1] unless($class);
    return $class->downbless($element);
}

1;
