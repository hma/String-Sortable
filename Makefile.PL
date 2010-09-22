use 5.006;

use strict;
use warnings;

use ExtUtils::MakeMaker 6.17;

my $eumm = eval ExtUtils::MakeMaker->VERSION;

my $NAME = 'String::Sortable';

(my $dist = $NAME) =~ s|::|-|g;
(my $path = $NAME) =~ s|::|/|g;

my $META = {
  resources => {
   #homepage   => "http://search.cpan.org/dist/$dist/",
    bugtracker => "http://github.com/hma/$dist/issues",
    repository => "http://github.com/hma/$dist",
    license    => 'http://dev.perl.org/licenses/',
  },
};

WriteMakefile(
  NAME          => $NAME,
  AUTHOR        => 'Henning Manske <hma@cpan.org>',
  VERSION_FROM  => "lib/$path.pm",
  ABSTRACT_FROM => "lib/$path.pm",

  ( $eumm >= 6.3001 ? ( LICENSE            => 'perl' ) : () ),
  ( $eumm >= 6.46   ? ( META_MERGE         => $META  ) : () ),
  ( $eumm >= 6.4701 ? ( MIN_PERL_VERSION   => 5.006  ) : () ),
  ( $eumm >= 6.5103 ? ( CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => '6.17' } ) : () ),
  ( $eumm >= 6.5503 ?  'BUILD_REQUIRES' : PREREQ_PM => { 'Test::More' => '0.62' } ),

  dist  => { COMPRESS => 'gzip -9f' },
  clean => { FILES    => "$dist-* cover_db Debian_CPANTS.txt nytprof*" },
  test  => { TESTS    => 't/*.t xt/*.t' },
);