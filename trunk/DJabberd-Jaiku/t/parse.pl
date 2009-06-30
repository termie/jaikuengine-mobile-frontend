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

use strict;
use 

my $xml =
"<presencev2>
 <base>
   <base.previous>
     <base.id>1275</base.id>
     <base.name>Brixton</base.name>
     <base.arrived>20080731T084041</base.arrived>
     <base.left>20080731T085400</base.left>
   </base.previous>
   <base.current>
     <base.id>120</base.id>
     <base.name>Google:Victoria</base.name>
     <base.arrived>20080731T085608</base.arrived>
     <base.left>00-11231T235950</base.left>
   </base.current>
 </base>
 <city>London</city>
 <country>UK</country>
 <location.value>
   <location.mcc>234</location.mcc>
   <location.mnc>10</location.mnc>
   <location.network></location.network>
   <location.lac>10139</location.lac>
   <location.cellid>39061</location.cellid>
   <location.id>120</location.id>
 </location.value>
 <cell_name>Google:Victoria</cell_name>
 <useractivity>
   <active>false</active>
   <since>20080731T155029</since>
 </useractivity>
 <profile>
   <profile.id>0</profile.id>
   <profile.name>General</profile.name>
   <profile.ringtype>0</profile.ringtype>
   <profile.ringvolume>7</profile.ringvolume>
   <profile.vibra>true</profile.vibra>
 </profile>
 <usergiven>
   <description>Aamun tuuma: mik&#195;&#164; tekee
   parturi/kampaamo-bisneksest&#195;&#164; niin erilaisen, ettei
   sinne synny isoja dominoivia ketjuja?</description>
   <since>20080731T082807</since>
 </usergiven>
 <bt.presence>
   <buddies>1</buddies>
   <other_phones>17</other_phones>
   <own_laptops>0</own_laptops>
   <own_desktops>0</own_desktops>
   <own_pdas>0</own_pdas>
 </bt.presence>
 <calendar>
   <previous>
     <start_time>00000101T000000</start_time>
     <description></description>
     <end_time>00000101T000000</end_time>
     <eventid>0</eventid>
   </previous>
   <current>
     <start_time>00000101T000000</start_time>
     <description></description>
     <end_time>00000101T000000</end_time>
     <eventid>0</eventid>
   </current>
   <next>
     <start_time>00000101T000000</start_time>
     <description></description>
     <end_time>00000101T000000</end_time>
     <eventid>0</eventid>
   </next>
 </calendar>
 <citysince>00000101T000000</citysince>
 <countrysince>00000101T000000</countrysince>
 <devices>
   <device>
     <bt.mac>0017e5189fda</bt.mac>
     <bt.name></bt.name>
     <bt.majorclass>0</bt.majorclass>
     <bt.minorclass>0</bt.minorclass>
     <bt.serviceclass>0</bt.serviceclass>
   </device>
   <device>
     <bt.mac>001dfd717ec4</bt.mac>
     <bt.name></bt.name>
     <bt.majorclass>2</bt.majorclass>
     <bt.minorclass>3</bt.minorclass>
     <bt.serviceclass>720</bt.serviceclass>
   </device>
 </devices>
 <generated>true</generated>
 <connectivitymodel>1</connectivitymodel>
 <incall>false</incall>
 <phonenumberhash>
 aa419169fe9d691ff05f4a8c8aec38d3</phonenumberhash>
 <phonenumberisverified>1</phonenumberisverified>
 <firstname>Teemu</firstname>
 <lastname>Kurppa</lastname>
</presencev2>";
