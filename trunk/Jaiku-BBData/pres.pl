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
use Carp;
use DJabberd::XMLParser;
use Jaiku::BBData::SAXHandler;
use Jaiku::BBData::Factory;
use Jaiku::BBData::All;

$SIG{__DIE__} = sub { &Carp::croak };
$Carp::Verbose = 1;

my $xml = "";
open(IN, "<pres.xml") || die "cannot open pres.xml";
while(<IN>) {
  $xml .= $_;
}
close(IN);

my $elem;
my $handler = Jaiku::BBData::SAXHandler->new(sub { print "done\n"; $elem = $_[0]->[0]; });
my $parser = DJabberd::XMLParser->new(Handler => $handler);
$parser->parse_chunk($xml);
$parser->finish_push();
use Data::Dumper;

$elem = Jaiku::BBData::Presence->downbless($elem);
print Dumper($elem->as_parsed());

my $elem2 = Jaiku::BBData::Presence->new("presencev2");
$elem2->from_parsed($elem->as_parsed());
print Dumper($elem2->as_parsed());
