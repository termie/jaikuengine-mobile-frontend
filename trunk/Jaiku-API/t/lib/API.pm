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

package API;
use strict;
use Jaiku::API;

use constant ROOT_TOKEN_KEY => 'ROOT_TOKEN_KEY';
use constant ROOT_TOKEN_SECRET => 'ROOT_TOKEN_SECRET';
use constant ROOT_CONSUMER_KEY => 'ROOT_CONSUMER_KEY';
use constant ROOT_CONSUMER_SECRET => 'ROOT_CONSUMER_SECRET';

sub make {
  my (%opts) = @_;
  my $params = {
    base_url => URI->new('http://localhost:8080'),
    domain => 'jaiku.com',
    consumer_key => ROOT_CONSUMER_KEY,
    consumer_secret => ROOT_CONSUMER_SECRET,
    token_key => ROOT_TOKEN_KEY,
    token_secret => ROOT_TOKEN_SECRET
  };
  foreach my $key (keys %opts) {
    $params->{$key} = $opts{$key};
  }
  return Jaiku::API->new(%$params);
}

1;
