#!perl
#
#  xt/author/eol.t 0.01 hma Sep 16, 2010
#  with patch applied for none UTF-8 files hma Sep 22, 2010
#
#  Check the correct line endings in your project
#  RELEASE_TESTING only
#

use strict;
use warnings;

#  use included copy of Test::EOL copyright (c) 2010 by Tomas Doran
#  with patch applied from
#  RT #59877: Test::EOL should not assume UTF-8 encoding on tested files

use FindBin;
use lib $FindBin::Bin;

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
  'Test::EOL' => '0.9',
);

while (my ($module, $version) = each %MODULES) {
  $module .= ' ' . $version if $version;
  eval "use $module";
  die "Could not load required release testing module $module:\n$@" if $@;
}

all_perl_files_ok( { trailing_whitespace => 1 }, '.' );
