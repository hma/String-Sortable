#!perl -T

use strict;
use warnings;

use constant EMPTY_STRING => q{};

use Test::More;

use String::Sortable;

my @methods = qw'display sortify compare equals';

my @tests = (

  # undefined input string
  [ [ undef                           ], EMPTY_STRING, EMPTY_STRING                  ],

  # no control characters contained
  [ [ 'Some Text'                     ], 'some text' , 'Some Text'                   ],

  # default non-sorting control character
  [ [ '¬Nonsort Sort Text'            ], 'sort text' , 'Nonsort Sort Text'           ],
  [ [ '¬Nonsort¬ Sort Text'           ], 'sort text' , 'Nonsort Sort Text'           ],
  [ [ '¬Nonsort\'¬Sort Text'          ], 'sort text' , 'Nonsort\'Sort Text'          ],
  [ [ '¬ ¬Nonsort Sort Text'          ], 'sort text' , ' Nonsort Sort Text'          ],
  [ [ '¬Nonsort1.¬Nonsort2 Sort Text' ], 'sort text' , 'Nonsort1.Nonsort2 Sort Text' ],
  [ [ '¬Nonsort1 ¬Nonsort2 Sort Text' ], 'sort text' , 'Nonsort1 Nonsort2 Sort Text' ],

  # strings from SYNOPSIS
  [ [ '¬The Title of ¬the Thing'      ], 'title of thing', 'The Title of the Thing'  ],

  # switch to default sorting control character
  'sort',

  [ [ '¬Non Sort'                     ], '¬non sort' , '¬Non Sort'                   ],

  # default sorting control character
  [ [ 'Nonsort @Sort Text'            ], 'sort text' , 'Nonsort Sort Text'           ],
  [ [ '@Sort Text'                    ], 'sort text' , 'Sort Text'                   ],
  [ [ '@@Sort Text'                   ], '@sort text', '@Sort Text'                  ],
  [ [ '@Sort @Text'                   ], 'sort @text', 'Sort @Text'                  ],


  # custom control characters
  [ [ '!Non Sort', nonsort => '!'     ], 'sort'      , 'Non Sort'                    ],
  [ [ 'Non ^Sort', sort    => '^'     ], 'sort'      , 'Non Sort'                    ],

);

plan tests => @methods + 2 * grep { ref eq 'ARRAY' } @tests;

my $obj = String::Sortable->new;

can_ok $obj, $_ for @methods;

my $n;

for (@tests) {
  if (ref eq 'ARRAY') {
    $n++;
    my $sortable = String::Sortable->new( @{ $_->[0] } );
    is $sortable->display, $_->[2], "display ($n)";
    is $sortable->sortify, $_->[1], "sortify ($n)";
  }
  else {
    String::Sortable->setup($_)
  }
}
