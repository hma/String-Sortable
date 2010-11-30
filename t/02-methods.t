#!perl -T

use strict;
use warnings;

use constant EMPTY_STRING => q{};

use Test::More;

use String::Sortable;

my @methods = qw'display sortify compare equals';

my @s = (
  # no control characters contained
  [ 'Some Text'                     ], 'some text' , 'Some Text',                   # 1

  # non-sorting control character
  [ '¬Nonsort Sort Text'            ], 'sort text' , 'Nonsort Sort Text',           # 2
  [ '¬Nonsort¬ Sort Text'           ], 'sort text' , 'Nonsort Sort Text',           # 3
  [ '¬Nonsort\'¬Sort Text'          ], 'sort text' , 'Nonsort\'Sort Text',          # 4
  [ '¬ ¬Nonsort Sort Text'          ], 'sort text' , ' Nonsort Sort Text',          # 5
  [ '¬Nonsort1.¬Nonsort2 Sort Text' ], 'sort text' , 'Nonsort1.Nonsort2 Sort Text', # 6
  [ '¬Nonsort1 ¬Nonsort2 Sort Text' ], 'sort text' , 'Nonsort1 Nonsort2 Sort Text', # 7

  # sorting control character
# [ 'Nonsort @Sort Text'            ], 'sort text' , 'Nonsort Sort Text',           # 8
# [ '@Sort Text'                    ], 'sort text' , 'Sort Text',                   # 9
# [ '@@Sort Text'                   ], '@sort text', '@Sort Text',                  # 10
# [ '@Sort @Text'                   ], 'sort @text', 'Sort @Text',                  # 11

  # precedence of control characters
  [ '¬Nonsort @Sort Text'           ], '@sort text', 'Nonsort @Sort Text',          # 12

  # undefined input string
  [ undef                           ], EMPTY_STRING, EMPTY_STRING,                  # 13

  # strings from SYNOPSIS
# [ 'The @Title'                    ], 'title'         , 'The Title',               # 14
  [ '¬The Title of ¬the Thing'      ], 'title of thing', 'The Title of the Thing',  # 15

  [ 'Cyberpl@y', nonsort => '^'     ], 'cyberpl@y'     , 'Cyberpl@y',               # 16
  [ '^Non Sort', nonsort => '^'     ], 'sort',         , 'Non Sort',                # 17
  [ 'Non ^Sort', sort    => '^'     ], 'sort',         , 'Non Sort',                # 18
);

plan tests => @methods + @s / 3 * 2;

my $obj = String::Sortable->new;

can_ok $obj, $_ for @methods;

my $t;
for (my $i = 0; $i < @s; $i += 3) {
  $t++;
  my $sortable = String::Sortable->new( @{ $s[$i] } );
  is $sortable->display, $s[$i + 2], "display ($t)";
  is $sortable->sortify, $s[$i + 1], "sortify ($t)";
}
