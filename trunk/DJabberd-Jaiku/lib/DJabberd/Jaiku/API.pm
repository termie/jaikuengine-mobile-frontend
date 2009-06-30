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

#
# DJabberd plugin that lets other Jaiku plugins get to a API object that has
# been created with the necessary parameters.

package DJabberd::Jaiku::API;
use strict;
use base 'DJabberd::Plugin';
use Jaiku::API;
use Jaiku::Http::Async;

# DJabberd calls set_config_X for each option defined in the configuration file
# for the plugin. We just want to stash them away to pass to Jaiku::API::new()
# later, so we generate the necessary methods.
BEGIN {
  my @config_options = qw(base_url consumer_key consumer_secret token_key
                          token_secret);
  foreach my $opt (@config_options) {
    no strict 'refs';
    *{"set_config_$opt"} = sub {
      my ($self, $value) = @_;
      $self->{config}->{$opt} = $value;
    };
  }
}

# There's no chain to hook this into as we just want to let the different
# DJabberd::Jaiku::X plugins access this object when they need to make API
# calls.
my %api_by_vhost;  # $server_name -> DJabberd::Jaiku::API
sub register {
  my ($self, $vhost) = @_;
  $api_by_vhost{$vhost->server_name()} = $self;
}

# Given a VHost, returns a Jaiku::API object creating it if not yet created.
# Returns undef if the plugin is not loaded for the given VHost.
sub get {
  my ($class, $vhost) = @_;
  return $class->get_by_servername($vhost->server_name());
}

# Given a server name, returns a Jaiku::API object creating it if not yet created.
# Returns undef if the plugin is not loaded for the given VHost.
sub get_by_servername {
  my ($class, $servername) = @_;
  my $self = $api_by_vhost{$servername} or return undef;
  return $self->{api} if ($self->{api});

  my $opts = $self->{config};
  my $async_http = sub {
    my ($request, $callback) = @_;
    Jaiku::Http::Async->new($request, $callback);
  };
  $opts->{async_http} = $async_http;
  $opts->{base_url} = URI->new($opts->{base_url});
  $self->{api} = Jaiku::API->new(%$opts);
  return $self->{api};
}

1;
