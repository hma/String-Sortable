#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
  use_ok 'String::Sortable'
    or BAIL_OUT q{Can't load module};
}
