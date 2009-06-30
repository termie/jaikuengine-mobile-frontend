#!/usr/bin/perl
#
# Copyright 2008 Google Inc. All rights reserved.
# Author: mikie@google.com (Mika Raento)
#
# Perl Makefile for Jaiku-Http
#
# Invoke with 'perl Makefile.PL'
#
# See ExtUtils::MakeMaker (3) for more information on how to influence
# the contents of the Makefile that is written

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME           => 'Jaiku::Http',
  VERSION_FROM   => 'lib/Jaiku/Http/Async.pm',  # finds $VERSION
  AUTHOR         => 'Mika Raento (mikie@google.fi)',
  ABSTRACT       => 'Async http class',
  PREREQ_PM      => {
    'Crypt::SSLeay' => 0,
    'Danga::Socket' => 0,
    fields          => 0,
    'HTTP::Daemon'  => 0,
    'IO::Handle'    => 0,
    'List::Util'    => 0,
    'LWP'           => 0,
    'Net::DNS'      => 0,
    'Net::DNS::Server' => 0,
    'Net::SSLeay'   => 0,
    'Test::More'    => 0,
    'URI'           => 0,
  },
);
