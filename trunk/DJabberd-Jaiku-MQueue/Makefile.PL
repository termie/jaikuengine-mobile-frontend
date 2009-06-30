#!/usr/bin/perl
# Copyright 2008 Google Inc. All rights reserved.
# Author: mikie@google.com (Mika Raento)
#
#   Perl Makefile for Jaiku-AppEngine
#
#   Invoke with 'perl Makefile.PL'
#
#   See ExtUtils::MakeMaker (3) for more information on how to influence
#   the contents of the Makefile that is written
#

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME                    => 'Jaiku::AppEngine',
  VERSION_FROM            => 'lib/Jaiku/AppEngine.pm', # finds $VERSION
  AUTHOR                  => 'Mika Raento <mikie@google.com>',
  ABSTRACT                =>
      'Jaiku MQueue implementation for the Jaiku-on-AppEngine APIs',
  PREREQ_PM               => {
      Test::Simple        => 0.41,
      Test::Exception     => 0.22,
      Heap                => 0.71,
  },
);

