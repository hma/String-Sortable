#!perl -T

use strict;
use warnings;

use constant NONSORT_CC    => chr(172);
use constant SORT_CC       => '@';
use constant DEFAULT_SETUP => { nonsort => NONSORT_CC };

use Test::Deep 'cmp_deeply';

use Test::More tests => 11;



package Test1;
use String::Sortable my_nonsort => { nonsort => '^' }, my_sort => { sort => '&' };

package Test2;
use String::Sortable 'default_nonsort';

package Test3;
use String::Sortable default_sort => 'sort';

package Test4;
use String::Sortable undef;

package main;

is_deeply +String::Sortable->setup, DEFAULT_SETUP, 'default setup untouched';

eval q[
  package Test5;
  use String::Sortable -setup => { nonsort => '!' };
];

is_deeply +String::Sortable->setup, { nonsort => '!' }, 'change default setup';

can_ok 'Test1', 'my_nonsort';
can_ok 'Test1', 'my_sort';
can_ok 'Test2', 'default_nonsort';
can_ok 'Test3', 'default_sort';

ok ! Test5->can('-setup'), 'do not export -setup';

my @s = ( 'A Title', 'The Book' );

cmp_deeply
  [ Test1::my_nonsort @s ],
  [ map { String::Sortable->new($_, nonsort => '^') } @s ],
  'my_nonsort';

cmp_deeply
  [ Test1::my_sort @s ],
  [ map { String::Sortable->new($_, sort => '&') } @s ],
  'my_sort';

cmp_deeply
  [ Test2::default_nonsort @s ],
  [ map { String::Sortable->new($_, %{ +DEFAULT_SETUP }) } @s ],
  'default_nonsort';

cmp_deeply
  [ Test3::default_sort @s ],
  [ map { String::Sortable->new($_, sort => SORT_CC) } @s ],
  'default_sort';
