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

#
# Data transforms between Jaiku mobile structures and Jaiku-on-appengine
# API structures.
#
# TODO(mikie): refactor this into more OO code once the functions and structure
# emerges. It can start out like this.

package DJabberd::Jaiku::Transforms;
use strict;
use Storable qw(dclone);

sub _rename($$);

sub _rename($$) {
  my ($tree, $renames) = @_;
  return unless ($tree);
  foreach my $rename (@$renames) {
    next unless(defined($tree->{$rename->[0]}));
    $tree->{$rename->[1]} = delete $tree->{$rename->[0]};
  }
}

sub _move($$$$);

sub _move($$$$) {
  my ($source, $names, $target_parent, $target) = @_;
  return unless($source);
  foreach my $name (@$names) {
    next unless($source->{$name});
    $target_parent->{$target}->{$name} = delete $source->{$name};
  }
}

sub _rename_subst(&$$);

sub _rename_subst(&$$) {
  my ($substblock, $tree, $recursive) = @_;
  return unless (ref($tree)); # got a leaf
  if (ref($tree) eq "HASH") {
    foreach (keys %$tree) {
      my $old = $_;
      &$substblock();
      $tree->{$_} = delete $tree->{$old};
      if ($recursive) {
        _rename_subst(\&$substblock, $tree->{$_}, 1);
      }
    }
  } else {
    if ($recursive) {
      foreach my $c (@$tree) {
        _rename_subst(\&$substblock, $c, 1);
      }
    }
  }
}

sub _delete_undefs($);

sub _delete_undefs($) {
  my ($tree) = @_;
  return unless(ref($tree) eq "HASH");
  foreach my $k (keys %$tree) {
    if (defined($tree->{$k})) {
      _delete_undefs($tree->{$k});
      if (ref($tree->{$k}) eq "HASH" &&
          !(keys %{$tree->{$k}})) {
        delete $tree->{$k};
      }
    } else {
      delete $tree->{$k};
    }
  }
}

sub presence_to_api($) {
  # Input structure:   http://code.google.com/p/jaiku/wiki/PresenceExample
  # Output structure:  http://code.google.com/p/jaiku/wiki/PresenceModel
  my ($presence) = @_;
  my $rv = dclone($presence);

  _rename_subst { s/profile\.// }  $rv->{profile}, 0;
  _rename_subst { s/base\.// }  $rv->{base}, 1;
  _rename($rv, [
    [ 'location.value', 'cell' ],
    [ 'useractivity', 'activity' ],
    [ 'bt.presence', 'bt' ],
    [ 'usergiven', 'presenceline']
  ]);
  _rename_subst { s/location\.// }  $rv->{cell}, 0;
  _move($rv, [ 'cell', 'base'], $rv, 'location');
  $rv->{location}->{city}->{name} = delete $rv->{city};
  $rv->{location}->{city}->{since} = delete $rv->{citysince};
  $rv->{location}->{country}->{name} = delete $rv->{country};
  $rv->{location}->{country}->{since} = delete $rv->{countrysince};
  $rv->{location}->{cell}->{name} = delete $rv->{cell_name};
  $rv->{activity}->{incall} = delete $rv->{incall};
  _rename_subst { s/bt\.// }  $rv->{devices}, 1;
  $rv->{bt}->{neighbours} = delete $rv->{devices};
  $rv->{s60_settings}->{connectivitymodel} = delete $rv->{connectivitymodel};

  _delete_undefs($rv);

  return $rv;
}

sub api_to_presence($) {
  # Input structure:   http://code.google.com/p/jaiku/wiki/PresenceModel
  # Output structure:  http://code.google.com/p/jaiku/wiki/PresenceExample
  my ($presence) = @_;
  my $rv = dclone($presence);

  _rename_subst { s/^/bt./ }  $rv->{bt}->{neighbours}, 1;
  _rename_subst { s/^/profile./ }  $rv->{profile}, 0;

  my $structured_location = ref($rv->{location}) eq "HASH";

  if ($structured_location) {
    _rename_subst { s/^/base./ }  $rv->{location}->{base}, 1;
    $rv->{city} = delete $rv->{location}->{city}->{name};
    $rv->{citysince} = delete $rv->{location}->{city}->{since};
    $rv->{country} = delete $rv->{location}->{country}->{name};
    $rv->{countrysince} = delete $rv->{location}->{country}->{since};
    $rv->{cell_name} = delete $rv->{location}->{cell}->{name};
  }

  $rv->{devices} = delete $rv->{bt}->{neighbours};
  $rv->{incall} = delete $rv->{activity}->{incall};
  $rv->{sent} = delete $rv->{senders_timestamp};


  if ($structured_location) {
    _rename_subst { s/^/location./ }  $rv->{location}->{cell}, 0;
  }

  _rename($rv, [
    [ 'cell', 'location.value' ],
    [ 'activity', 'useractivity' ],
    [ 'bt', 'bt.presence' ],
    [ 'presenceline', 'usergiven' ],
    [ 'given_name', 'firstname' ],
    [ 'family_name', 'lastname' ],
  ]);

  if ($structured_location) {
    $rv->{'location.value'} = delete $rv->{location}->{cell};
    $rv->{base} = delete $rv->{location}->{base};
  }

  if (!$structured_location) {
    $rv->{base}->{'base.current'}->{'base.name'} = delete $rv->{location};
  }
  if (!$rv->{sent}) {
    $rv->{sent} = $rv->{usergiven}->{since};
  }

  _delete_undefs($rv);

  return $rv;
}

sub _strip_domain {
  my ($nick) = @_;
  $nick =~ s/\@.*//;
  return $nick;
}

sub api_to_feeditem {
  my ($api) = @_;
  my $rv = { };
  $rv->{uuid} = $api->{uuid};
  $rv->{created} = $api->{created_at};
  $rv->{authornick} = _strip_domain($api->{actor});
  $rv->{location } = $api->{location};
  if (!$api->{extra}->{entry_uuid}) {
    $rv->{content} = $api->{extra}->{title};
    $rv->{kind} = "presence";
    my $photo_url = $api->{extra}->{thumbnail_url};
    if ($photo_url && ($photo_url =~ /flickr/)) {
      $rv->{thumbnailurl} = $photo_url;
      $rv->{kind} = 'photo';
    }
  } else {
    $rv->{content} = $api->{extra}->{content};
    $rv->{parentuuid} = $api->{extra}->{entry_uuid};
    $rv->{parentauthornick} = _strip_domain($api->{extra}->{entry_actor});
    $rv->{parenttitle} = $api->{extra}->{entry_title};
  }
  return $rv;
}

sub feeditem_to_api {
  my ($feeditem) = @_;
  my $rv = { };
  $rv->{uuid} = $feeditem->{uuid};
  $rv->{nick} = $feeditem->{authornick};
  $rv->{location } = $feeditem->{location};
  if (!$feeditem->{parentuuid}) {
    $rv->{message} = $feeditem->{content};
  } else {
    $rv->{content} = $feeditem->{content};
    $rv->{entry_uuid} = $feeditem->{parentuuid};
  }
  return $rv;
}

1;
