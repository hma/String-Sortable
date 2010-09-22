#!perl -T
#
#  xt/author/coverage.t 0.01 hma Sep 16, 2010
#
#  Check test coverage
#  RELEASE_TESTING only
#

use strict;
use warnings;

#  adopted Best Practice for Author Tests, as proposed by Adam Kennedy
#  http://use.perl.org/~Alias/journal/38822

BEGIN {
  my $MIN_PERL = 5.008_002;
  if (my $msg =
      ! $ENV{RELEASE_TESTING} ? 'Author tests not required for installation'
    : $] < $MIN_PERL          ? "Perl $MIN_PERL required"
    : undef
  ) {
    require Test::More;
    Test::More::plan( skip_all => $msg );
  }
}

my %MODULES = (
  'Devel::Cover' => '0.70',
  'Test::Strict' => '0.14',
);

while (my ($module, $version) = each %MODULES) {
  $module .= ' ' . $version if $version;
  eval "use $module ()";
  die "Could not load required release testing module $module:\n$@" if $@;
}



{ # begin of patch to Test::Strict

no warnings 'once';

#  code copied from Test::Strict version 0.14
#  Copyright 2005, 2010 Pierre Denis, All Rights Reserved.

#  with patch applied from
#  RT #60953: all_cover_ok() doesn't respect taint switches

package Test::Strict;

my $IS_WINDOWS = $^O =~ /win|dos/i;
my $Test  = Test::Builder->new;

sub main::all_cover_ok {
  my $threshold = shift || $Test::Strict::COVERAGE_THRESHOLD;
  my @dirs = @_ ? @_
                : (File::Spec->splitpath( $0 ))[1] || '.';
  my @all_files = grep { ! /$0$/o && $0 !~ /$_$/ }
                  grep { _is_perl_script($_)     }
                       _all_files(@dirs);
  _make_plan();

  my $cover_bin    = _cover_path() or do{ $Test->skip(); $Test->diag("Cover binary not found"); return};
  my $perl_bin     = _untaint($Test::Strict::PERL);
  local $ENV{PATH} = _untaint($ENV{PATH}) if $ENV{PATH};
  if ($IS_WINDOWS and ! -d $Test::Strict::DEVEL_COVER_DB) {
    mkdir $Test::Strict::DEVEL_COVER_DB or warn "$Test::Strict::DEVEL_COVER_DB: $!";
  }
  my $res = `$cover_bin -delete 2>&1`;
  if ($?) {
    $Test->skip();
    $Test->diag("Cover at $cover_bin got error $?: $res");
    return;
  }
  foreach my $file ( @all_files ) {
    $file = _untaint($file);

    # Add the -t -T switches if they are set in the #! line
    my $switch = _taint_switch($file) || '';
    $switch = "-$switch " if $switch;

    `$perl_bin $switch-MDevel::Cover=$Test::Strict::DEVEL_COVER_OPTIONS $file`;
    $Test->ok(! $?, "Coverage captured from $file" );
  }
  $Test->ok(my $cover = `$cover_bin 2>&1`, "Got cover");

  my ($total) = ($cover =~ /^\s*Total.+?([\d\.]+)\s*$/m);
  $Test->ok( $total >= $threshold, "coverage = ${total}% > ${threshold}%");
  return $total;
}

} # end of patch to Test::Strict



{
  # shut up warnings from Devel::Cover
  # see http://www.nntp.perl.org/group/perl.qa/2006/03/msg5638.html

  local $ENV{HARNESS_PERL_SWITCHES} = '-MDevel::Cover';

  my $options = '+ignore,"^t/"';
  my $renamed;

  unless ( $ENV{PERL5LIB} && $ENV{PERL5LIB} =~ / \b blib \b lib \b/x ) {
    # we are presumably not called by the building toolchain
    # so make sure we test the contents of 'lib', not 'blib'

    # rename 'blib' if exists
    # because Devel::Cover will look for it
    $renamed = -d 'blib' && ! -e 'blib.old' && rename 'blib', 'blib.old';

    # inject 'lib' into options
    $options .= ' -Ilib';
  }

  local $Test::Strict::DEVEL_COVER_OPTIONS = $options;

  eval { all_cover_ok(100, 't') };

  rename 'blib.old', 'blib' if $renamed;

  die $@ if $@;
}
