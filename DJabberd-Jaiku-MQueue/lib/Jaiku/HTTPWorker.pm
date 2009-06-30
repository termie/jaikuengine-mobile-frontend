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

use fields qw(worker http flickr);
use Gearman::Worker;
use Storable qw(freeze thaw);
use Flickr::API;
use LWP::UserAgent;
use Flickr::API;

sub new {
    my $class=shift;
    my $self=fields::new($class);
    my $api_key = 'e8d9f91dd86765ad808d2335ba150065';
    my $not_so_secret = 'a771033a2b986f81';
	$self->{worker}=new Gearman::Worker;
	$self->{worker}->job_servers('127.0.0.1');
    $self->{http}=LWP::UserAgent->new;
    $self->{flickr}=Flickr::API->new({'key' => $api_key, 'secret' => $not_so_secret} );
	$self->register_functions();
    return $self;
}

sub start {
	#print STDERR "starting worker\n";
	my $self=shift;
	$self->{worker}->work while 1;
}

sub register_functions {
	my $self=shift;
	my $w=$self->{worker};
	$w->register_function( "http_request" => sub { $self->http_request(@_); } );
	$w->register_function( "flickr_request" => sub { $self->flickr_request(@_); } );
	print "registered\n";
}

sub http_request {
    my $self=shift;
	my $job=shift;
	my $request=thaw $job->arg;
    my $handler=$self->{http};
    my $response=$handler->request($request);
    return freeze $response;
}

sub flickr_request {
    my $self=shift;
	my $job=shift;
	my $request=thaw $job->arg;
    my $handler=$self->{flickr};
    my $response=$handler->execute_request($request);
    return freeze $response;
}

1;
