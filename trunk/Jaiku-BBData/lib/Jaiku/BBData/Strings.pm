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
package Jaiku::BBData::StringBase;
use base qw(Jaiku::BBData::Simple);

use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub check_value {
    my $self=shift;
    my $val=shift;

    my $maxlen=$self->maxlength;
    return $val if ($maxlen==0);

    return $val if (length($val)<=$maxlen);

    die "$val is too long (maximum $maxlen, for field " . $self->element . ")";
}

1;

package Jaiku::BBData::ShortString;
use base qw(Jaiku::BBData::StringBase);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 50; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 2, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::LongString;
use base qw(Jaiku::BBData::StringBase);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 255; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 10, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::TupleSubName;
use base qw(Jaiku::BBData::StringBase);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 128; }

sub type { return [ CONTEXT_UID_SENSORDATAFACTORY, 8, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;

package Jaiku::BBData::String;
use base qw(Jaiku::BBData::StringBase);
use Jaiku::Uid;
use Jaiku::BBData::Factory;

sub maxlength { return 0; }

sub type { return [ CONTEXT_UID_BLACKBOARDFACTORY, 11, 1, 0 ]; }

Jaiku::BBData::Factory::add_class();

1;

