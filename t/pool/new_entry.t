use Test::More 'no_plan';
use strict;

my $class = 'Beancounter';
use_ok( $class );

my $bean = $class->new;
isa_ok( $bean, $class );

my $pool = $bean->pool_class->new();
isa_ok( $pool, $bean->pool_class );


my $entry = $pool->entry_class->new;

isa_ok( $entry, $pool->entry_class );