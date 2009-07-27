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
package Jaiku::Uid;

use base 'Exporter';

@EXPORT=qw(
    CONTEXT_UID_BLACKBOARDFACTORY
    CONTEXT_UID_SENSORDATAFACTORY
    CONTEXT_UID_CONTEXTSENSORS
    CONTEXT_UID_CONTEXTCONTACTS

    OLD2_CONTEXT_UID_BLACKBOARDFACTORY
    OLD2_CONTEXT_UID_SENSORDATAFACTORY
);


use constant {
    CONTEXT_UID_BLACKBOARDFACTORY => 0x200084BF,
    CONTEXT_UID_SENSORDATAFACTORY => 0x200084C2,
    CONTEXT_UID_CONTEXTSENSORS => 0x200084C1,
    CONTEXT_UID_CONTEXTCONTACTS => 0x200084BB,

    OLD2_CONTEXT_UID_BLACKBOARDFACTORY => 0x20006E4C,
    OLD2_CONTEXT_UID_SENSORDATAFACTORY => 0x20006E4E,
};

sub canon {
    my $uid=shift;

    return CONTEXT_UID_BLACKBOARDFACTORY if ($uid==OLD2_CONTEXT_UID_BLACKBOARDFACTORY);
    return CONTEXT_UID_SENSORDATAFACTORY if ($uid==OLD2_CONTEXT_UID_SENSORDATAFACTORY);

    return $uid;
}

1;
