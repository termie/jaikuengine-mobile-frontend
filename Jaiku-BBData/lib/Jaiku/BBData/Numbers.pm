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

use base qw(Jaiku::BBData::Simple);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub type {
    return [ CONTEXT_UID_BLACKBOARDFACTORY, 1, 1, 0 ];
}

sub default_value {
    return 0;
}

sub check_value {
    my $self=shift;
    my $val=shift;

    if ($val=~/^0x[0-9a-f]+$/i) {
        return oct $val;
    }

    my $int=int($val);
    return $int if ($int eq $val);

    die "$val is not an integer (for field " . $self->element . ")";
}

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::Uint;
use strict;
use base qw(Jaiku::BBData::Int);
use Jaiku::Uid;

sub type {
    return [ CONTEXT_UID_BLACKBOARDFACTORY, 6, 1, 0 ];
}

sub check_value {
    my $self=shift;
    my $val=shift;

    $val = Jaiku::BBData::Int::check_value($self, $val);

    return $val if ($val >= 0);

    die "$val is not positive (for field " . $self->element . ")";
}

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::Uid;
use Jaiku::Uid;
use base qw(Jaiku::BBData::Uint);

sub type {
    return [ CONTEXT_UID_BLACKBOARDFACTORY, 9, 1, 0 ];
}

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::Time;
use base qw(Jaiku::BBData::Simple);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub type {
    return [ CONTEXT_UID_BLACKBOARDFACTORY, 5, 1, 0 ];
}

sub default_value {
    return "00000101T000000";
}

sub check_value {
    my $self=shift;
    my $val=shift;

    if ($val=~/^00-1/) {
      # workaround for broken client timeshifting 0-time
      $val = "00000101T000000";
    }
    if ($val=~/^(\d\d\d\d)-?(\d\d)-?(\d\d)[T ](\d\d):?(\d\d):?(\d\d)(\.\d+)?$/) {
        return "$1$2$3T$4$5$6";
    }

    die "$val is not a date (for field " . $self->element . ")";
}

sub as_parsed {
  my $self = shift;
  my $val = $self->value();
  $val =~ s/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/$1-$2-$3 $4:$5:$6/;
  return $val;
}

Jaiku::BBData::Factory::add_class();

1;


package Jaiku::BBData::Bool;
use base qw(Jaiku::BBData::Simple);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub type {
    return [ CONTEXT_UID_BLACKBOARDFACTORY, 4, 1, 0 ];
}

sub default_value {
    return 0;
}

sub check_value {
    my $self=shift;
    my $val=shift;

    return 0 if ($val eq "0" || lc($val) eq "false");
    return 1 if ($val eq "1" || lc($val) eq "true");

    die "$val is not boolean (for field " . $self->element . ")";
}

Jaiku::BBData::Factory::add_class();

1;
