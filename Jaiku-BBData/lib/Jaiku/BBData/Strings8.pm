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

use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub check_value {
    my $self=shift;
    my $val=shift;

    my $maxlen=$self->maxlength;

    return $val if ($maxlen==0);

    return $val if (length($val)<=$maxlen*2);

    die "$val is too long (maximum $maxlen, for field " . $self->element . ")";
}

1;

package Jaiku::BBData::ShortString8;
use base qw(Jaiku::BBData::StringBase8);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 50; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 13, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::String8;
use base qw(Jaiku::BBData::StringBase8);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 0; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 16, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::UUID;
use base qw(Jaiku::BBData::StringBase8);
use Jaiku::Uid;
use Jaiku::BBData::Factory;
use Data::UUID;

my $ug;

sub maxlength { return 16; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 22, 1, 0 ]; }

sub with_dashes {
    my $self=shift;
    my $str=$self->value;
    my @lens=( 8, 4, 4, 4, 12 );
    my $ret; my $pos=0; my $sep="";
    map { $ret .= $sep . substr($str, $pos, $_); $pos+=$_; $sep="-"; } @lens;
    return $ret;
}

sub check_value {
    my $self=shift;
    my $val=shift;
    $val=~s/-//g;
    return Jaiku::BBData::StringBase8::check_value($self, $val);
}

sub generate {
    my $self=shift;
    $ug ||= new Data::UUID;
    $self->set_value(lc($ug->create_str()));
}

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::MD5Hash;
use base qw(Jaiku::BBData::StringBase8);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 16; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 21, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;
