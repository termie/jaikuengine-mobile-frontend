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
package Jaiku::XMLSplit;

use strict;

sub new {
	my ($class, $xml)=@_;
	my $self=bless {}, $class;

	$self->{elements}=[];
	$self->split_xml($xml) if ($xml);
	return $self;
}

sub elements {
	return @{$_[0]->{elements}};
}

sub split_xml {
	my $self=shift;
	my $xml=shift;
	$self->{elements}=[];

	my $len=length($xml);
	my $depth=0;
	my $elem;
	my $in_open; my $in_close;
	my $in_attr;
	for (my $i=0; $i<$len; $i++) {
		my $c=substr($xml, $i, 1);
		#print "D $depth C $c\n";
		unless ( $depth==0 ||
			($depth==1 && $in_open) ||
			($depth==1 && $in_close) ) {
			$elem .= $c;
		}
		if ($in_attr) {
			$in_attr="" if ($in_attr eq $c);
			next;
		}
		if ($in_open && ($c eq '"' || $c eq "'")) {
			$in_attr=$c;
			next;
		}
		if ($c eq "<") {
			$i++;
			$c=substr($xml, $i, 1);
			#print "D $depth C $c\n";
			if ($c eq "/") {
				$in_close=1;
				$in_open=0;
			} else {
				$in_close=0;
				$in_open=1;
				$depth++;
			}
			unless ( $depth==0 ||
				($depth==1 && $in_open) ||
				($depth==1 && $in_close) ) {
				$elem .= $c;
			}
			next;
		}
		if ($in_open && $c eq "/") {
			$i++;
			$c=substr($xml, $i, 1);
			#print "D $depth C $c\n";
			if ($depth>1) { $elem .= $c; };
			if ($c eq ">") {
				$in_close=1;
			}
		}
		if ($c eq ">") {
			if ($in_close) {
				$depth--;
				if ($depth==1) {
					$elem=~m!^\s*<([^/\s>]+)!;
					push @{$self->{elements}}, [ $1, $elem ];
					$elem="";
				}
				$in_close=$in_open=0;
			} elsif ($in_open) {
				$in_close=$in_open=0;
			}
		}
	}
}

1;
