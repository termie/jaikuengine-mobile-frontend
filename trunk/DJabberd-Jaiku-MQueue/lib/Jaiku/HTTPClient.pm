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
package Jaiku::HTTPClient;

use strict;
use fields qw(client);
use Gearman::Client::Async;
use Storable qw(freeze thaw);
use DJabberd::Log;
our $logger = DJabberd::Log->get_logger();
our $client;

sub get_client {
	return $client ||= new Jaiku::HTTPClient;
}

sub log_error {
	print STDERR "MQUEUE_CLIENT ERR: ", shift, "\n";
	$logger->warn(@_);
}
sub log_info {
	#print STDERR "MQUEUE_CLIENT INFO: ", shift, "\n";
	$logger->info(@_);
}

my $started_workers;
my @workers;

sub new {
    my $class=shift;
	my $self=fields::new($class);
	$self->{client}=new Gearman::Client::Async(job_servers => [ '127.0.0.1']);

    if (! $started_workers) {
        $self->start_workers();
    }
	return $self;
}

sub http_request {
    my $self=shift;
    my $request=shift;
    my $args=freeze $request;
    my $cb=shift;

    my $cb_object=bless [ $cb ], "Jaiku::HTTPClient::Cb";

	my $task= Gearman::Task->new("http_request", \$args,
		{ retry_count=>2, on_fail=>sub { log_error "http request failed" },
		on_complete=> sub { 
            return unless ($cb_object->[0]);
			my $ret=$_[0];
            $ret=thaw $$ret;
            $cb_object->[0]->($ret);
			}, 
		timeout=>90 } );
	$self->{client}->add_task($task);
}

sub flickr_request {
    my $self=shift;
    my $request=shift;
    my $args=freeze $request;
    my $cb=shift;

    my $cb_object=bless [ $cb ], "Jaiku::HTTPClient::Cb";

	my $task= Gearman::Task->new("flickr_request", \$args,
		{ retry_count=>2, on_fail=>sub { log_error "flickr request failed" },
		on_complete=> sub { 
            return unless ($cb_object->[0]);
			my $ret=$_[0];
            $ret=thaw $$ret;
            $cb_object->[0]->($ret);
			}, 
		timeout=>90 } );
	$self->{client}->add_task($task);
}

END {
    my $status;
    foreach my $pid (@workers) {
        CORE::kill(9, $pid);
        waitpid $pid, $status;
    }
}

use Jaiku::HTTPWorker;
sub start_workers {
    $SIG{'CHLD'}="IGNORE";
    for (my $i=0; $i<10; $i++) {
        my $pid=fork();
        if (! $pid ) {
            # child
            my $w=new Jaiku::HTTPWorker;
            $w->start;
            exit 0;
        } else {
            push @workers, $pid;
        }
    }
    $started_workers=1;
}

1;

package Jaiku::HTTPClient::Request;

sub cancel {
    $_[0]->[0]=undef;
}
