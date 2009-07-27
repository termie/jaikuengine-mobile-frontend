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
package Jaiku::Tuple::UserPic;

use Jaiku::BBData::Tuple;

sub make {
	my ($nick, $phonehash, $mbm, $verified)=@_;
	$verified ||= 0;

	my $u=new Jaiku::BBData::UserPic();
	$u->nick->set_value($nick);
	$u->phonenumberhash->set_value($phonehash);
	$u->mbm->set_value($mbm);
	$u->phonenumberisverified->set_value($verified);

	my $t=new Jaiku::BBData::Tuple;
	$t->tuplemeta->moduleuid->set_value("0x20006E4D");
	$t->tuplemeta->moduleid->set_value(50);
	$t->tuplemeta->subname->set_value($nick);
	$t->expires->set_value("20100101T010101");
	$t->set_data($u);
	$t->set_type_attributes;

	return $t;
}

1;
