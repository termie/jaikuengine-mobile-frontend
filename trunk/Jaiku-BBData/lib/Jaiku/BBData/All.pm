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

use Jaiku::BBData::Base;
use Jaiku::BBData::BaseInfo;
use Jaiku::BBData::BaseVisit;
use Jaiku::BBData::BluetoothAddress;
use Jaiku::BBData::BluetoothName;
use Jaiku::BBData::Bool;
use Jaiku::BBData::BtDeviceInfo;
use Jaiku::BBData::BtDeviceList;
use Jaiku::BBData::BuildInfo;
use Jaiku::BBData::Calendar;
use Jaiku::BBData::CalendarEvent;
use Jaiku::BBData::CellId;
use Jaiku::BBData::CellNaming;
use Jaiku::BBData::ChannelPost;
use Jaiku::BBData::Compound;
use Jaiku::BBData::FeedItem;
use Jaiku::BBData::Int;
use Jaiku::BBData::List;
use Jaiku::BBData::LongString;
use Jaiku::BBData::MD5;
use Jaiku::BBData::MD5Hash;
use Jaiku::BBData::NeighbourhoodInfo;
use Jaiku::BBData::Numbers;
use Jaiku::BBData::Presence;
use Jaiku::BBData::Profile;
use Jaiku::BBData::SAXHandler;
use Jaiku::BBData::SensorEvent;
use Jaiku::BBData::SentInvite;
use Jaiku::BBData::ServerMessage;
use Jaiku::BBData::ShortNetworkName;
use Jaiku::BBData::ShortString;
use Jaiku::BBData::Simple;
use Jaiku::BBData::StreamComment;
use Jaiku::BBData::StreamData;
use Jaiku::BBData::String;
use Jaiku::BBData::String8;
use Jaiku::BBData::Strings;
use Jaiku::BBData::Strings8;
use Jaiku::BBData::ThreadRequest;
use Jaiku::BBData::Time;
use Jaiku::BBData::Tuple;
use Jaiku::BBData::TupleMeta;
use Jaiku::BBData::TupleSubName;
use Jaiku::BBData::Uid;
use Jaiku::BBData::Uint;
use Jaiku::BBData::UserActive;
use Jaiku::BBData::UserGiven;
use Jaiku::BBData::UserPic;
use Jaiku::BBData::UUID;

1;
