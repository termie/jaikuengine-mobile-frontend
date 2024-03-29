#!/usr/bin/perl -w

use strict;
use lib $ENV{PERL_CORE} ? '../lib/Module/Build/t/lib' : 't/lib';
use MBTest tests => 11;

use Cwd ();
my $cwd = Cwd::cwd;
my $tmp = File::Spec->catdir( $cwd, 't', '_tmp' );

use DistGen;
my $dist = DistGen->new( dir => $tmp );
$dist->regen;

chdir( $dist->dirname ) or die "Can't chdir to '@{[$dist->dirname]}': $!";


use Module::Build;

###################################
$dist->change_file( 'Build.PL', <<"---" );
use Module::Build;
my \$build = Module::Build->new(
  module_name => @{[$dist->name]},
  license     => 'perl'
);
\$build->create_build_script;
\$build->notes(foo => 'bar');
---

$dist->regen;

my $mb = Module::Build->new_from_context;

is $mb->notes('foo'), 'bar';

# Try setting & checking a new value
$mb->notes(argh => 'new');
is $mb->notes('argh'), 'new';

# Change existing value
$mb->notes(foo => 'foo');
is $mb->notes('foo'), 'foo';

# Change back so we can run this test again successfully
$mb->notes(foo => 'bar');
is $mb->notes('foo'), 'bar';

# Check undef vs. 0 vs ''
foreach my $val (undef, 0, '') {
  $mb->notes(null => $val);
  is $mb->notes('null'), $val;
}


###################################
# Make sure notes set before create_build_script() get preserved
$mb = Module::Build->new(module_name => $dist->name);
ok $mb;
$mb->notes(foo => 'bar');
is $mb->notes('foo'), 'bar';

$mb->create_build_script;

$mb = Module::Build->resume;
ok $mb;
is $mb->notes('foo'), 'bar';


# cleanup
chdir( $cwd ) or die "Can''t chdir to '$cwd': $!";
$dist->remove;

use File::Path;
rmtree( $tmp );
