#!perl -T

use strict;
use warnings;

use constant NONSORT_CC    => chr(172);
use constant SORT_CC       => '@';
use constant DEFAULT_SETUP => { nonsort => NONSORT_CC };

use Test::More;

use String::Sortable;

my @tests = (
  [  'sort'                             , { sort    => SORT_CC                  }, 'sort'                 ],
  [  'nonsort'                          ,              DEFAULT_SETUP             , 'nonsort'              ],
  [ { sort    => '&'                  } , { sort    => '&'                      }, 'set sort'             ],
  [ { nonsort => '^'                  } , { nonsort => '^'                      }, 'set nonsort'          ],
  [ { foo     => 'bar'                } , { nonsort => '^'       , foo => 'bar' }, 'set foo'              ],
  [ { nonsort => '!'                  } , { nonsort => '!'       , foo => 'bar' }, 'change nonsort'       ],
  [ { nonsort => undef                } , { sort    => SORT_CC   , foo => 'bar' }, 'undef nonsort'        ],
  [ { sort    => '&'                  } , { sort    => '&'       , foo => 'bar' }, 'change sort'          ],
  [ { sort    => undef                } , { nonsort => NONSORT_CC, foo => 'bar' }, 'undef sort'           ],
  [ { foo     => undef                } , { nonsort => NONSORT_CC, foo => undef }, 'undef foo'            ],
  [ { nonsort => undef, sort => undef } , { nonsort => NONSORT_CC, foo => undef }, 'undef nonsort & sort' ],
  [  'sort'                             , { sort    => SORT_CC   , foo => undef }, 'sort keeps foo'       ],
  [  'nonsort'                          , { nonsort => NONSORT_CC, foo => undef }, 'nonsort keeps foo'    ],
);

plan tests => 2 + @tests + 3;

can_ok 'String::Sortable', 'setup';

is_deeply my $setup = String::Sortable->setup, DEFAULT_SETUP, 'default setup';

for (@tests) {
  $setup = String::Sortable->setup( $_->[0] );
  is_deeply $setup, $_->[1], $_->[2];
}

is_deeply +String::Sortable->setup(undef), $setup, 'undef is ignored';

eval { String::Sortable->setup('foo') };
like $@, qr'\bunknown parameter'i, 'unknown parameter exception';

String::Sortable->setup( my $hashref = { foo => 'bar' } );
is_deeply $hashref, { foo => 'bar' }, 'parameter hashref untouched';
