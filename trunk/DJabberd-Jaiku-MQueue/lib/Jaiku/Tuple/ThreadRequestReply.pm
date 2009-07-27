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
package Jaiku::Tuple::ThreadRequestReply;

sub is_threadrequest {
	my ($uid, $id)=@_;
	return 0 unless ($uid == 0x20006E4D || $uid == 0x200084C1);
	return ($id==60);
}

sub UID {
	return 0x20006E4D;
}

sub ID {
	return 60;
}

sub make {
    my $subname=shift;
    my $rows=shift;

	my $t=new Jaiku::BBData::Tuple;
	$t->tuplemeta->moduleuid->set_value("0x20006E4D");
	$t->tuplemeta->moduleid->set_value(60);
    $t->tuplemeta->subname->set_value($subname);
	$t->set_type_attributes;

    my $data=new Jaiku::BBData::Int("tuplevalue");
    $data->set_value($rows);
    $t->set_data($data);

	return $t;
}
1;
