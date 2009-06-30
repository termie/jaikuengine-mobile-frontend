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
  NAME           => 'Jaiku::API',
  VERSION_FROM   => 'lib/Jaiku/API.pm',  # finds $VERSION
  AUTHOR         => 'Mika Raento (mikie@google.fi)',
  ABSTRACT       => 'Package for calling the new Jaiku API',
  PREREQ_PM      => {
    'Digest::SHA1'  => 0,
    'HTTP::Request' => 0,
    'JSON'          => 0,
    'LWP'           => 0,  # For tests
    'Net::Oauth'    => 0,
    'Test::More'    => 0,  # For tests
  },
);
