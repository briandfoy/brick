use Test::More 'no_plan';
use strict;

my $class = 'Beancounter::Pool';

use_ok( $class );

my $pool = $class->new;

isa_ok( $pool, $class );