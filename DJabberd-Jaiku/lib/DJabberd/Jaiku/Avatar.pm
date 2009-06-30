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
# Reading, caching and converting avatars for the S60 client.

package DJabberd::Jaiku::Avatar;
use Danga::Socket;
use Digest::SHA1;
use File::Temp;
use strict;

my $convert_children;

sub get_avatar {
  my ($nick, $url, $cache_path, $api, $cb) = @_;
  my $uuid = '';
  if ($url =~ /avatar_([a-f0-9]+)_f/) {
    $uuid = $1;
  } else {
    $uuid = substr(Digest::SHA1::sha1_hex($nick . $url), 0, 32);
  }
  my $filename = _cache_filename($nick, $uuid, $cache_path);
  if (-f $filename) {
    Danga::Socket->AddTimer(0, sub {
      $cb->([_readfile($filename), $uuid], undef);
    });
    return;
  }
  print STDERR "GETTING AVATAR $url\n";
  $api->get_avatar(nick => $nick, url => $url, callback => sub {
    my ($data, $error) = @_;
    if (!$data) {
      $cb->([undef, $uuid], "could not get avatar from api: $error");
      return;
    }
    _convert_and_cache($nick, $uuid, $cache_path, $data, $cb);
  });
}

sub _cache_filename {
  my ($nick, $uuid, $cache_path) = @_;
  $nick =~ s/\@.*//;
  $cache_path =~ s/\/$//;
  my $dir = $cache_path . "/" . substr($nick, 0, 2) . "/" . $nick . "/";
  system("mkdir -p $dir");
  return $dir . $uuid .  ".mbm"
}

sub _readfile {
  my ($filename) = @_;
  open(INPUT, "<$filename");
  binmode(INPUT);
  my $data;
  my $buffer;
  while (read(INPUT, $buffer, 128 * 1024)) {
    $data .= $buffer;
  }
  close(INPUT);
  return $data;
}

sub _cache_tempfile {
  my ($nick, $uuid, $cache_path) = @_;
  return _cache_filename($nick, "temp/", $cache_path);
}

sub _cache_tempdir {
  my ($nick, $uuid, $cache_path) = @_;
  return $cache_path;
}

sub _convert_and_cache {
  my ($nick, $uuid, $cache_path, $data, $cb) = @_;
  my $filename = _cache_filename($nick, $uuid, $cache_path);
  my $tempdir = _cache_tempdir($nick, $uuid, $cache_path);
  _convert($data, $tempdir, $filename, $uuid, $cb);
}

sub _convert {
  # Loosely based on setup_iostat in mogstored, see
  # http://code.sixapart.com/svn/mogilefs/tags/MogileFS-Utils-1.50/server/mogstored
  my ($data, $tempdir, $filename, $uuid, $cb) = @_;
  if (!$data) {
    $cb->(undef, "no data to convert");
    return;
  }

  pipe(my $stdout_r, my $stdout_w);
  pipe(my $stderr_r, my $stderr_w);
  my $pid = fork();
  if (!defined($pid)) {
    $cb->(undef, "could not fork: $!");
    return;
  }
  if ($pid) {
    # Parent
    close $stdout_w;
    close $stderr_w;

    IO::Handle::blocking($stdout_r, 0);
    binmode($stdout_r);
    IO::Handle::blocking($stderr_r, 0);
    my $to_wait = 2;
    my $out = '';
    my $err = '';
    my $handler = sub {
      $to_wait--;
      if ($to_wait == 0) {
        waitpid($pid, 0);
        print STDERR "$err\n";
        $cb->([$out, $uuid], $err . " (return value $?)");
      }
    };
    my $on_read_out = sub {
      my $ret = sysread($stderr_r, my $buf, 1024);
      $out .= $buf;
      if (!$ret) {
        my $fds = Danga::Socket->OtherFds();
        delete $fds->{fileno($stdout_r)};
        close $stdout_r;
        $handler->();
      }
    };
    my $on_read_err = sub {
      my $ret = sysread($stderr_r, my $buf, 1024);
      $err .= $buf;
      if (!$ret) {
        my $fds = Danga::Socket->OtherFds();
        delete $fds->{fileno($stderr_r)};
        close $stderr_r;
        $handler->();
      }
    };

    Danga::Socket->AddOtherFds(fileno($stdout_r), $on_read_out);
    Danga::Socket->AddOtherFds(fileno($stderr_r), $on_read_err);

    return;
  }
  close $stdout_r;
  close $stderr_r;

  close STDIN;
  close STDOUT;
  close STDERR;

  # We probably can't see errors on these calls.
  open STDIN, '<', '/dev/null'    or die "Couldn't open STDIN for reading from /dev/null";
  open STDOUT, '>&', $stdout_w    or die "Couldn't dup pipe for use as STDOUT";
  open STDERR, '>&', $stderr_w    or die "Couldn't dup pipe for use as STDERR";

  _run_converter($filename, $tempdir, $data);
  exit 0;
}

sub _run_converter {
  my ($filename, $tempdir, $data) = @_;
  my $pnmfile = File::Temp->new(DIR => $tempdir);
  open(TOPNM, "|jpegtopnm > " . $pnmfile->filename());
  print TOPNM $data;
  close(TOPNM);

  my $doublefile = File::Temp->new(DIR => $tempdir);
  my $portraitfile = File::Temp->new(DIR => $tempdir);
  my $singlefile = File::Temp->new(DIR => $tempdir);
  my $halffile = File::Temp->new(DIR => $tempdir);
  my $out_tmp = File::Temp->new(DIR => $tempdir);

  foreach my $do (
      [ "-resize 60x60 -gravity center -strip -crop 60x60+0+1 +repage", $doublefile ],
      [ "-resize 40x40 -gravity center -strip -crop 40x40+0+1 +repage", $portraitfile ],
      [ "-resize 30x30 -gravity center -strip -crop 30x30+0+1 +repage", $singlefile ],
      [ "-resize 14x14 -gravity center -strip +repage", $halffile ]) {
    my $cropargs = $do->[0];
    my $outfile = $do->[1];
    my $infile = $pnmfile->filename();
    system("convert $infile $cropargs bmp:$outfile");
  }
  print STDERR "OUT_TMP '" . $out_tmp->filename() . "'\n";
  system("bmconv " . $out_tmp->filename() .
         " /c24" . $singlefile->filename() .
         " /c24" . $doublefile->filename() .
         " /c24" . $portraitfile->filename() .
         " /c24" . $halffile->filename() .
         " 1>&2");
  system("mv " . $out_tmp->filename() . " $filename");
  $out_tmp->unlink_on_destroy(0);
  print _readfile($filename);
}

package DJabberd::Jaiku::Reader;

1;
