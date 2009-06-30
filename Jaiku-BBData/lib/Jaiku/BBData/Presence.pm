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

use base qw(Jaiku::BBData::Compound);
use Jaiku::BBData::Base;
use fields qw( firstname cellid usergiven neighbourhoodinfo useractive cellname city incall connectivitymodel lastname citysince phonenumberhash profile calendar senttimestamp country devices baseinfo countrysince );
use Jaiku::BBData::Bool;
use Jaiku::BBData::UserGiven;
use Jaiku::BBData::Int;
use Jaiku::BBData::LongString;
use Jaiku::BBData::BtDeviceList;
use Jaiku::BBData::CellId;
use Jaiku::BBData::NeighbourhoodInfo;
use Jaiku::BBData::MD5Hash;
use Jaiku::BBData::Profile;
use Jaiku::BBData::Time;
use Jaiku::BBData::ShortString;
use Jaiku::BBData::BaseInfo;
use Jaiku::BBData::Calendar;
use Jaiku::BBData::UserActive;

my $field_to_xml;
my $xml_to_field;

BEGIN {
    $field_to_xml = { 'cellid' => 'location.value', 'baseinfo' => 'base', 'useractive' => 'useractivity', 'profile' => 'profile', 'devices' => 'devices', 'neighbourhoodinfo' => 'bt.presence', 'usergiven' => 'usergiven', 'senttimestamp' => 'sent', 'calendar' => 'calendar', 'city' => 'city', 'country' => 'country', 'cellname' => 'cellname', 'phonenumberhash' => 'phonenumberhash', 'firstname' => 'firstname', 'citysince' => 'citysince', 'countrysince' => 'countrysince', 'lastname' => 'lastname', 'connectivitymodel' => 'connectivitymodel', 'incall' => 'incall',  };
    $xml_to_field = { 'location.value' => 'cellid', 'base' => 'baseinfo', 'useractivity' => 'useractive', 'profile' => 'profile', 'devices' => 'devices', 'bt.presence' => 'neighbourhoodinfo', 'usergiven' => 'usergiven', 'sent' => 'senttimestamp', 'calendar' => 'calendar', 'city' => 'city', 'country' => 'country', 'cellname' => 'cellname', 'phonenumberhash' => 'phonenumberhash', 'firstname' => 'firstname', 'citysince' => 'citysince', 'countrysince' => 'countrysince', 'lastname' => 'lastname', 'connectivitymodel' => 'connectivitymodel', 'incall' => 'incall',  };
}

sub new {
    my $class=shift;
    my $name=shift || 'presencev2';
    my $self=new Jaiku::BBData::Compound($name);

    return $class->downbless($self);
}

sub type {
    return [ 0x20006E4E, 31, 1, 0 ];
}

sub field_to_xml {
    return $field_to_xml;
}
sub xml_to_field {
    return $xml_to_field;
}
sub cellid {
    my $self=shift;
    return $self->{cellid} if ($self->{cellid});
    my $ret=new Jaiku::BBData::CellId;
    $self->{cellid}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_cellid {
    my $self=shift;
    my $c=Jaiku::BBData::CellId->downbless(shift());
    $self->replace_child( $self->{cellid}, $c );
    $self->{cellid}=$c;
}

sub baseinfo {
    my $self=shift;
    return $self->{baseinfo} if ($self->{baseinfo});
    my $ret=new Jaiku::BBData::BaseInfo;
    $self->{baseinfo}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_baseinfo {
    my $self=shift;
    my $c=Jaiku::BBData::BaseInfo->downbless(shift());
    $self->replace_child( $self->{baseinfo}, $c );
    $self->{baseinfo}=$c;
}

sub useractive {
    my $self=shift;
    return $self->{useractive} if ($self->{useractive});
    my $ret=new Jaiku::BBData::UserActive;
    $self->{useractive}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_useractive {
    my $self=shift;
    my $c=Jaiku::BBData::UserActive->downbless(shift());
    $self->replace_child( $self->{useractive}, $c );
    $self->{useractive}=$c;
}

sub profile {
    my $self=shift;
    return $self->{profile} if ($self->{profile});
    my $ret=new Jaiku::BBData::Profile;
    $self->{profile}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_profile {
    my $self=shift;
    my $c=Jaiku::BBData::Profile->downbless(shift());
    $self->replace_child( $self->{profile}, $c );
    $self->{profile}=$c;
}

sub devices {
    my $self=shift;
    return $self->{devices} if ($self->{devices});
    my $ret=new Jaiku::BBData::BtDeviceList;
    $self->{devices}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_devices {
    my $self=shift;
    my $c=Jaiku::BBData::BtDeviceList->downbless(shift());
    $self->replace_child( $self->{devices}, $c );
    $self->{devices}=$c;
}

sub neighbourhoodinfo {
    my $self=shift;
    return $self->{neighbourhoodinfo} if ($self->{neighbourhoodinfo});
    my $ret=new Jaiku::BBData::NeighbourhoodInfo;
    $self->{neighbourhoodinfo}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_neighbourhoodinfo {
    my $self=shift;
    my $c=Jaiku::BBData::NeighbourhoodInfo->downbless(shift());
    $self->replace_child( $self->{neighbourhoodinfo}, $c );
    $self->{neighbourhoodinfo}=$c;
}

sub usergiven {
    my $self=shift;
    return $self->{usergiven} if ($self->{usergiven});
    my $ret=new Jaiku::BBData::UserGiven('usergiven');
    $self->{usergiven}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_usergiven {
    my $self=shift;
    my $c=Jaiku::BBData::UserGiven->downbless(shift());
    $self->replace_child( $self->{usergiven}, $c );
    $self->{usergiven}=$c;
}

sub senttimestamp {
    my $self=shift;
    return $self->{senttimestamp} if ($self->{senttimestamp});
    my $ret=new Jaiku::BBData::Time('sent');
    $self->{senttimestamp}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_senttimestamp {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{senttimestamp}, $c );
    $self->{senttimestamp}=$c;
}

sub calendar {
    my $self=shift;
    return $self->{calendar} if ($self->{calendar});
    my $ret=new Jaiku::BBData::Calendar;
    $self->{calendar}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_calendar {
    my $self=shift;
    my $c=Jaiku::BBData::Calendar->downbless(shift());
    $self->replace_child( $self->{calendar}, $c );
    $self->{calendar}=$c;
}

sub city {
    my $self=shift;
    return $self->{city} if ($self->{city});
    my $ret=new Jaiku::BBData::LongString('city');
    $self->{city}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_city {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{city}, $c );
    $self->{city}=$c;
}

sub country {
    my $self=shift;
    return $self->{country} if ($self->{country});
    my $ret=new Jaiku::BBData::ShortString('country');
    $self->{country}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_country {
    my $self=shift;
    my $c=Jaiku::BBData::ShortString->downbless(shift());
    $self->replace_child( $self->{country}, $c );
    $self->{country}=$c;
}

sub cellname {
    my $self=shift;
    return $self->{cellname} if ($self->{cellname});
    my $ret=new Jaiku::BBData::LongString('cellname');
    $self->{cellname}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_cellname {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{cellname}, $c );
    $self->{cellname}=$c;
}

sub phonenumberhash {
    my $self=shift;
    return $self->{phonenumberhash} if ($self->{phonenumberhash});
    my $ret=new Jaiku::BBData::MD5Hash('phonenumberhash');
    $self->{phonenumberhash}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_phonenumberhash {
    my $self=shift;
    my $c=Jaiku::BBData::MD5Hash->downbless(shift());
    $self->replace_child( $self->{phonenumberhash}, $c );
    $self->{phonenumberhash}=$c;
}

sub firstname {
    my $self=shift;
    return $self->{firstname} if ($self->{firstname});
    my $ret=new Jaiku::BBData::LongString('firstname');
    $self->{firstname}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_firstname {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{firstname}, $c );
    $self->{firstname}=$c;
}

sub citysince {
    my $self=shift;
    return $self->{citysince} if ($self->{citysince});
    my $ret=new Jaiku::BBData::Time('citysince');
    $self->{citysince}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_citysince {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{citysince}, $c );
    $self->{citysince}=$c;
}

sub countrysince {
    my $self=shift;
    return $self->{countrysince} if ($self->{countrysince});
    my $ret=new Jaiku::BBData::Time('countrysince');
    $self->{countrysince}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_countrysince {
    my $self=shift;
    my $c=Jaiku::BBData::Time->downbless(shift());
    $self->replace_child( $self->{countrysince}, $c );
    $self->{countrysince}=$c;
}

sub lastname {
    my $self=shift;
    return $self->{lastname} if ($self->{lastname});
    my $ret=new Jaiku::BBData::LongString('lastname');
    $self->{lastname}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_lastname {
    my $self=shift;
    my $c=Jaiku::BBData::LongString->downbless(shift());
    $self->replace_child( $self->{lastname}, $c );
    $self->{lastname}=$c;
}

sub connectivitymodel {
    my $self=shift;
    return $self->{connectivitymodel} if ($self->{connectivitymodel});
    my $ret=new Jaiku::BBData::Int('connectivitymodel');
    $self->{connectivitymodel}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_connectivitymodel {
    my $self=shift;
    my $c=Jaiku::BBData::Int->downbless(shift());
    $self->replace_child( $self->{connectivitymodel}, $c );
    $self->{connectivitymodel}=$c;
}

sub incall {
    my $self=shift;
    return $self->{incall} if ($self->{incall});
    my $ret=new Jaiku::BBData::Bool('incall');
    $self->{incall}=$ret;
    $self->push_child($ret);
    return $ret;
}

sub set_incall {
    my $self=shift;
    my $c=Jaiku::BBData::Bool->downbless(shift());
    $self->replace_child( $self->{incall}, $c );
    $self->{incall}=$c;
}


Jaiku::BBData::Factory::add_class();

1;
