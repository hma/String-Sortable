#!perl -T
#
#  xt/author/pod-no404s.t 0.01 hma Sep 16, 2010
#
#  Checks POD for http 404 links
#  RELEASE_TESTING only
#

use strict;
use warnings;

#  adopted Best Practice for Author Tests, as proposed by Adam Kennedy
#  http://use.perl.org/~Alias/journal/38822

BEGIN {
  my $MIN_PERL = 5.008;
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
  'Test::Pod::No404s' => '0.01',
);

while (my ($module, $version) = each %MODULES) {
  $module .= ' ' . $version if $version;
  eval "use $module";
  die "Could not load required release testing module $module:\n$@" if $@;
}

all_pod_files_ok();
