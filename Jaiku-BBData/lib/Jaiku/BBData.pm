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

use base qw(DJabberd::XMLElement);
use Carp qw(croak);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

our $RELEASE_MODE = 1;

sub release_mode {
  return $RELEASE_MODE;
}

sub downbless {
  my $class = shift;

  if (ref $_[0]) {
    my ($self) = @_;
    # 'fields' hackery.  this will break in Perl 5.10
    {
      no strict 'refs';
      return $self if ($self->[0] == \%{$class . "::FIELDS" });
      $self->[0] = \%{$class . "::FIELDS" };
    }
    bless $self, $class;
    $self->_from_xml;
    return $self;
  } else {
    croak("Bogus use of downbless.");
  }
}

sub new {
  my $class=shift;
  my $name=shift;
  croak("BBData has to have a name") unless($name);

  my $self=new DJabberd::XMLElement("http://www.cs.helsinki.fi/group/context",
    $name, {}, []);

  return $self;
}

sub set_type_attributes {
  my $self=shift;
  my @type=@{$self->type};
  $self->set_attr('{}module', $type[0]);
  $self->set_attr('{}id', $type[1]);
  $self->set_attr('{}major_version', $type[2]);
  $self->set_attr('{}minor_version', $type[3]);
}

sub replace_child {
  my $self = $_[0];
  my $to_replace=$_[1];
  my $with=$_[2];
  my $found=0;
  if ($to_replace) {
    map { if ($_ == $to_replace) { $_ = $with; $found=1; } } @{$self->{children}};
  }
  $self->push_child($with) unless ($found);
}

1;
