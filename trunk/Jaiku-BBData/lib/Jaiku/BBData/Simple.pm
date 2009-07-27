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
package Jaiku::BBData::Simple;

use base qw(Jaiku::BBData);
use Carp qw(croak);

sub new {
  my $class=shift;
  my $name=shift;

  my $self=new Jaiku::BBData($name);

  return $class->downbless($self);
}

sub value {
  my $self=shift;
  my $val=$self->first_child;
  return $val if (defined($val));
  return $self->default_value;
}

sub check_value {
  return $_[1];
}

sub as_parsed {
  return $_[0]->value;
}

sub set_value {
  my $self=shift;
  my $val=shift;

  $val=~s/^\s*// if (defined($val));
  $val=~s/\s*$// if (defined($val));

  if ( (! defined($val) ) || $val eq "") {
    $self->{children}=[ ];
    return;
  }
  my $value=$self->check_value( $val );
  $self->{children}=[ $value ];
}

sub default_value {
  return '';
}

sub _from_xml {
  my $self=shift;

  my $c=$self->{children};
  return if ($#$c==-1);
  if ($#$c==0) {
    $self->set_value($c->[0]);
    return;
  }
  my $data="";
  foreach my $t ( @{$self->{children}} ) {
    $data .= $t;
  }
  $self->set_value($data);
}

sub from_parsed {
  my ($self, $value) = @_;
  $self->set_value($value);
}

1;
