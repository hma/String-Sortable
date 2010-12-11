#!perl -T

use strict;
use warnings;

use Test::More;

BEGIN {
  my $MIN_PERL = 5.008;
  plan skip_all => "Perl $MIN_PERL required" if $] < $MIN_PERL;
}

use constant EMPTY_STRING => q{};

my @s = (
  # non-sorting control character
  '¬Nonsort¬ Sort Text'          , 'sort text' , 'Nonsort Sort Text',           # 1
  '¬Nonsort\'¬Sort Text'         , 'sort text' , 'Nonsort\'Sort Text',          # 2
  '¬ ¬Nonsort Sort Text'         , 'sort text' , ' Nonsort Sort Text',          # 3
  '¬Nonsort1.¬Nonsort2 Sort Text', 'sort text' , 'Nonsort1.Nonsort2 Sort Text', # 4
  '¬Nonsort1 ¬Nonsort2 Sort Text', 'sort text' , 'Nonsort1 Nonsort2 Sort Text', # 5

  # strings from SYNOPSIS
  '¬The Title of ¬the Thing'     , 'title of thing', 'The Title of the Thing',  # 6
);

plan tests => @s / 3 * 2;

require Encode;

use String::Sortable;

my $obj = String::Sortable->new;

my $t;
for (my $i = 0; $i < @s; $i += 3) {
  $t++;
  my $sortable = String::Sortable->new( Encode::decode('UTF-8', $s[$i]) );
  is $sortable->display, $s[$i + 2], "display ($t)";
  is $sortable->sortify, $s[$i + 1], "sortify ($t)";
}
