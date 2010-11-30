#!perl -T

use strict;
use warnings;

use constant EMPTY_STRING => q{};

use Test::More tests => 13;

use String::Sortable;

#
#  overload of '""'
#

my $title     = String::Sortable->new('The @Title');
my $empty     = String::Sortable->new(EMPTY_STRING);
my $no_string = String::Sortable->new;
my $integer   = String::Sortable->new('1.23');

is "$title", $title->display, 'string conversion';

ok ! $empty    , 'boolean conversion (empty string)';
ok ! $no_string, 'boolean conversion (no string)';

cmp_ok $integer    , '==', 1.23, 'numeric conversion == (enabled by fallback)';
cmp_ok $integer + 1, '==', 2.23, 'numeric conversion +  (enabled by fallback)';

#
#  overload of 'cmp', 'eq', 'ne'
#

my $title1 = String::Sortable->new( '¬The Title of ¬the Thing' );
my $title2 = String::Sortable->new( 'The @Title of the Thing', sort => '@' );

cmp_ok $title1 cmp 'title of thing', '==', 0  , 'object cmp string compares by sort form';
cmp_ok $title1, 'eq', 'The Title of the Thing', 'object eq string compares by display form';
cmp_ok $title1, 'ne', 'title of thing'        , 'object ne string compares by display form';

cmp_ok $title1 cmp $title2, '==',  1, 'object 1 cmp object 2 compares by sort form';
cmp_ok $title2 cmp $title1, '==', -1, 'object 2 cmp object 1';

cmp_ok 'title of thing' cmp $title1, '==', 0  , 'string cmp object (reversed test)';

cmp_ok $title1, 'eq', $title2        , 'object eq object compares by display form';



### coverage is 100% here ###

#
#  author names example (idea for SYNOPSIS)
#

my @authors = map { String::Sortable->new($_, sort => '@') } (
 'Larry @Wall',
 'Tom @Christiansen',
 'Jon @Orwant',
);

my @author_names_sorted = (
  'Tom Christiansen',
  'Jon Orwant',
  'Larry Wall',
);

is_deeply [ map { $_->display } sort @authors ], \@author_names_sorted, 'object sort';
