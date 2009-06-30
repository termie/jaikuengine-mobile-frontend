#!/usr/bin/perl
#
# Copyright 2008 Google Inc. All rights reserved.
# Author: mikie@google.com (Mika Raento)
#
# Perl Makefile for Jaiku-API.
#
# Invoke with 'perl Makefile.PL'
#
# See ExtUtils::MakeMaker (3) for more information on how to influence
# the contents of the Makefile that is written

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME           => 'DJabberd::Jaiku',
  VERSION_FROM   => 'lib/DJabberd/Jaiku/API.pm',  # finds $VERSION
  AUTHOR         => 'Mika Raento (mikie@google.fi)',
  ABSTRACT       => 'DJabberd plugins for new Jaiku backend',
  PREREQ_PM      => {
    'Test::More'    => 0,  # For tests
  },
);
