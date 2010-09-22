#!perl
#
#  xt/author/spelling.t 0.01 hma Sep 16, 2010
#  String-Sortable customized stopwords 0.01 hma Sep 22, 2010
#
#  Check for spelling errors in POD files
#  RELEASE_TESTING only
#

use strict;
use warnings;

#  adopted Best Practice for Author Tests, as proposed by Adam Kennedy
#  http://use.perl.org/~Alias/journal/38822

BEGIN {
  if (my $msg =
      ! $ENV{RELEASE_TESTING}       ? 'Author tests not required for installation'
    : $] >= 5.008 &&  ${^TAINT} > 0 ? 'This test does not run in taint mode'
    : undef
  ) {
    require Test::More;
    Test::More::plan( skip_all => $msg );
  }
}

my %MODULES = (
  'Test::Spelling' => '0.11',
);

while (my ($module, $version) = each %MODULES) {
  $module .= ' ' . $version if $version;
  eval "use $module";
  die "Could not load required release testing module $module:\n$@" if $@;
}

add_stopwords( map { split /\s+/ } grep { chomp; s/#.*//; /\S/ } <DATA> );

set_spell_cmd('aspell list -l en');
all_pod_files_spelling_ok();

__DATA__

# personal names

Henning Manske

# misc

TODO
