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

use base qw(Jaiku::BBData);
use Jaiku::BBData::Factory;

sub _from_xml {
  my $self=shift;

  my @c=@{$self->{children}};
  $self->{children}=[];

  foreach my $c (@c) {
    next unless (defined($c));
    if (!(ref $c)) {
      # ignore intra-element whitespace
      next if ($c =~ /\s*/);
    }
    die "non-element child $c in list " . $self->element()
      unless(ref $c);

    if (ref $c) {
      my ($ns, $name)=$c->element;
      if ( $ns eq "" || $ns eq "http://www.cs.helsinki.fi/group/context") {
        if (my $itemtype = $self->itemtype()) {
          $c = $itemtype->downbless($c);
        } else {
          $c = Jaiku::BBData::Factory::cast_xml($c);
        }
      }
    }

    $self->push_child($c) if ($c);
  }
}

sub as_parsed {
  my $self=shift;
  my $parsed=[];
  foreach my $c (@{$self->{children}}) {
    if ($c->isa('Jaiku::BBData')) {
      push(@$parsed, $c->as_parsed());
    }
  }
  return $parsed;
}

sub from_parsed {
  my ($self, $arrayref) = @_;
  my $itemtype = $self->itemtype();
  foreach my $i (@$arrayref) {
    my $c = $itemtype->new();
    $c->from_parsed($i);
    $self->push_child($c);
  }
}

1;
