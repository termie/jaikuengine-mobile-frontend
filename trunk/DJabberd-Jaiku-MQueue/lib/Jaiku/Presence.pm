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

use DJabberd::Presence;
use XML::Simple;
use DJabberd::Util;
use Time::Local;
use strict;
use Exporter 'import';

use vars qw(@EXPORT_OK);
@EXPORT_OK=qw(from_line format_datetime formatted_to_datetime current_time current_timestamp mysql_datetime);

use fields qw(stanza status status_ts stanza_status_ts xs diff 
	phonehash firstname lastname generated xml_extras phonenumberisverified checked_ts);

sub UID {
	return 0x200084B6;
}
sub ID {
	return 4;
}
sub TypeUID {
	return 0x200084C2;
}
sub TypeID {
	return 31;
}
sub TypeVersion {
	return 7;
}

sub from_line {
	my ($jid, $line, $timestamp, $extras, $xml_extras)=@_;
	my $attributes="";
	$xml_extras ||= [];
	if ($extras->{generated}) {
		$attributes=" generated='1'";
	}
	delete $extras->{generated};
	my $status="$timestamp<presencev2><usergiven$attributes><since>$timestamp</since><description>".
		DJabberd::Util::exml($line) . "</description></usergiven>";

	foreach my $extra_key (keys %$extras) {
		my $val=$extras->{$extra_key};
		$val=~s/^\s+//;
		$val=~s/\s+$//;
		$val=substr($val, 0, 254);
		$status .= "<" . $extra_key . ">" . DJabberd::Util::exml($val) . "</"
			. $extra_key . ">";
	}
	foreach my $extra_xml (@$xml_extras) {
		$status .= $extra_xml;
	}
	$status .= "</presencev2>";
	my $stanza=DJabberd::Presence->available( 
		from=>$jid);
	$stanza->push_child( new DJabberd::XMLElement("", "status", {}, [ $status ]) );
	return $stanza;
}

sub new {
	my $self=fields::new(shift);
	$self->{xs}=new XML::Simple;
	return $self;
}

sub set_phonenumberhash {
	my $self=shift;
	$self->{phonehash}=shift;
	$self->do_replace;
}

sub set_phonenumberisverified {
	my $self=shift;
	$self->{phonenumberisverified}=shift;
	$self->do_replace;
}

sub set_firstname {
	my $self=shift;
	my $name=shift;
	if ($name) {
		$name=~s/^\s+//;
		$name=~s/\s+$//;
		$self->{firstname}=DJabberd::Util::exml($name);
		$self->do_replace;
	}
}
sub set_lastname {
	my $self=shift;
	my $name=shift;
	if ($name) {
		$name=~s/^\s+//;
		$name=~s/\s+$//;
		$self->{lastname}=DJabberd::Util::exml($name);
		$self->do_replace;
	}
}


sub set_generated {
	my $self=shift;
	$self->{generated}=shift;
}

sub set_status {
	my $self=shift;
	$self->{status}=shift;
	$self->{status_ts}=shift;
	$self->{checked_ts}=0;
	$self->do_replace;
	$self->{generated}=0;
	return ( $self->{phonehash} || (! $self->{stanza_status_ts}) ||
		($self->{status_ts} cmp $self->{stanza_status_ts}) > 0);
}

sub set_status_from_usergiven {
	my $self=shift;
	my $xml=shift;
	my $parsed=$self->parse( $xml );
	my $description=$parsed->{description};
	$description="" if (ref $description); # check for empty
	$self->set_status( $description, $parsed->{since} );
}

sub merge_xml {
	my $self=shift;
	my $xml_extras=shift;
	$self->{xml_extras}="";
	return unless($xml_extras);
	foreach my $extra (@$xml_extras) {
		$self->{xml_extras} .= $extra;
	}
}

sub get_status_el {
	my $self=shift;
	my $stanza=shift || $self->{stanza};
	if (! defined($stanza) ) {
		#print STDERR "NO STANZA\n";
		return undef;
	}
	foreach my $c ( $stanza->children_elements ) {
		my @el=$c->element;
		if ($el[1] eq "status") {
			return $c;
		}
	}
	#print STDERR "NO STATUS ELEMENT\n";
}

sub update_timestamp {
	#print STDERR "UPDATE_TIMESTAMP\n";
	my $self=shift;
	my $status_el=$self->get_status_el();
	return unless ($status_el);
	my $status=$status_el->text;
	#print STDERR "UPDATE_TIMESTAMP: $status\n";
	substr($status, 0, 15)=current_timestamp();
	#print STDERR "UPDATE_TIMESTAMP: $status\n";
	$status_el->{children}=[];
	$status_el->push_child($status);
}

sub parse {
    my $self=shift;
    my $args=shift;
    return $self->{xs}->XMLin($args);
}

sub do_replace {
	my $self=shift;
	my $status="";

	my $status_el=$self->get_status_el();
	return unless ($status_el);
	$status=$status_el->text;
	my $xml=substr($status, 15);
	#die "didn't find xml in $status" unless ($xml=~/^</);
	return unless ($xml=~/^</);
	#$xml=~/since>([0-9T]+)<since/;
	unless ($self->{checked_ts}) {
        #print STDERR "XML $xml \n";
		my $parsed=$self->parse( $xml );
		$self->{stanza_status_ts}=$parsed->{usergiven}->{since};
		#$self->{stanza_status_ts}=$1;
	}
	my $presence_is_newer=( $self->{stanza_status_ts} && ($self->{status_ts} cmp $self->{stanza_status_ts}) < 0);
	#print STDERR "BEFORE: " . $status . "\n";
	unless ($presence_is_newer) {
		my $ts=$self->{status_ts};
		my $presenceline=DJabberd::Util::exml($self->{status});
		my $attributes="";
		$attributes=" generated='1'" if ($self->{generated});
		$status=~s!<usergiven.*</usergiven>!<usergiven$attributes><description>$presenceline</description><since>$ts</since></usergiven>!;
	} else {
		$self->{checked_ts}=1;
	}

	if ( defined($self->{phonehash}) ) {
		my $hash="<phonenumberhash>" . $self->{phonehash} . "</phonenumberhash>";
		$status=~s!</presencev2>!$hash</presencev2>!;
		my $verified=$self->{phonenumberisverified} || 0;
		my $isverified="<phonenumberisverified>" . $self->{phonenumberisverified} . "</phonenumberisverified>";
		$status=~s!</presencev2>!$isverified</presencev2>!;
	}
	if ( defined($self->{firstname}) ) {
		my $name="<firstname>" . $self->{firstname} . "</firstname>";
		$status=~s!</presencev2>!$name</presencev2>!;
	}
	if ( defined($self->{lastname}) ) {
		my $name="<lastname>" . $self->{lastname} . "</lastname>";
		$status=~s!</presencev2>!$name</presencev2>!;
	}
	my $extras=$self->{xml_extras};
	if ($extras) {
		$status=~s!</presencev2>!$extras</presencev2>!;
	}
	$self->{xml_extras}="";
	#print STDERR "AFTER: " . $status . "\n";
	$status_el->{children}=[ $status ];
}

sub need_to_shift {
    my $self=shift;
    return ($self->{diff} && abs($self->{diff}) > 15);
}

sub shift_time_by {
	my $status=shift;
	my $diff=shift;
	my $new_status=$status;

	my $cal_begin=-1;
	my $cal_end=-1;
	$cal_begin=index($status, "<calendar");
	if ($cal_begin==-1) {
		$cal_begin=index($status, "&lt;calendar");
		$cal_end=index($status, "&lt;/calendar");
	} else {
		$cal_end=index($status, "</calendar");
	}
	while ($status =~ /(\d{8}T\d{6})/g) {
		my @s=@-;
		my @e=@+;
		foreach my $expr (1..$#s) {
			if ($cal_begin>-1 && $cal_end>-1) {
				# don't shift calendar times
				next if ($s[$expr] > $cal_begin && $s[$expr] < $cal_end);
			}
			my $dt=substr($status, $s[$expr], $e[$expr]-$s[$expr]);
			next if ($dt eq "00000101T000000");
			#print STDERR "DT $dt\n";
			my $correct=format_datetime( formatted_to_datetime($dt) + $diff );
			substr($new_status, $s[$expr], $e[$expr]-$s[$expr]) = $correct;
		}
	}
	return $new_status;
}

sub _shift_time {
  return;
	my $self=shift;
	my $stanza=shift;
	my $dir=shift;
	my $diff=$self->{diff} || 0;
	if (ref $stanza) {
		return if ( abs($diff) < 15 );
		#print STDERR "SHIFTING $stanza\n";
		my $status_el=$self->get_status_el($stanza);
		return unless ($status_el);
		my $status=$status_el->text;
		my $new_status=shift_time_by($status, $diff*$dir);
		$status_el->{children}=[];
		$status_el->push_child($new_status);
	} else {
		return $stanza if ( abs($diff) < 15 );
		return shift_time_by($stanza, $diff*$dir);
	}
}

sub shift_time {
  return;
	my $self=shift;
	my $status_el=$self->get_status_el;
	return unless ($status_el);
	my $status=$status_el->text;
	my $ts=substr($status, 0, 15);
	my $stanza_time=formatted_to_datetime($ts);
	return unless($stanza_time);
	my $current_time=current_time();
	$self->{diff}=$current_time-$stanza_time;
	$self->_shift_time($self->{stanza}, 1);
}

sub shift_outgoing_time {
	my $self=shift;
	my $stanza=shift;
	$self->_shift_time($stanza, -1);
}

sub shift_outgoing_ts {
	my $self=shift;
	my $timestamp=shift;

	if ($self->need_to_shift) {
		my $time=formatted_to_datetime($timestamp);
		my $diff=$self->{diff};
		$time -= $diff;
		$timestamp=format_datetime($time);
	}
	return $timestamp;
}

sub set_stanza {
	my $self=shift;
	my $s=shift;
	$self->{stanza}=$s->clone;
	#print STDERR "SET_STANZA: " . $self->{stanza}->as_xml . "\n";

	$self->shift_time;
	return unless (defined($self->{phonehash}) || (
		defined($self->{status}) && defined($self->{status_ts})
	));

	$self->do_replace;
}

sub stanza {
	my $self=shift;
	return $self->{stanza};
}

sub format_datetime($) {
        (my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday) = gmtime($_[0]);

        return sprintf("%04d%02d%02dT%02d%02d%02d", $year+1900, $mon+1, $mday,
                $hour, $min, $sec);
}
sub mysql_datetime($) {
        (my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday) = gmtime($_[0]);

        return sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday,
                $hour, $min, $sec);
}


sub formatted_to_datetime($) {
  my $datetime=shift;
  return $datetime if (!defined($datetime));
  $datetime =~ s/[:-]//g;
  $datetime =~ s/ /T/;
  $datetime =~ s/\.[0-9]+//;
  return 0 unless( $datetime =~ /(....)(..)(..)T(..)(..)(..)/ );
  (my $year, my $mon, my $d, my $h, my $min, my $s)=($1, $2, $3, $4, $5, $6);
  my $time=timegm($s, $min, $h, $d, $mon-1, $year);
  return $time;
}

sub current_time {
	my $dt=time();
	#$dt += 3*60*60;
	return $dt;
}

sub current_timestamp {
	return format_datetime(current_time());
}

1;
