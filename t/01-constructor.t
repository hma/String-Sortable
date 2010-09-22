#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use String::Sortable;

my $obj = eval { String::Sortable->new };

isa_ok $obj, 'String::Sortable'
  or BAIL_OUT q{Can't create a String::Sortable object};
