#!/usr/bin/perl

use Test::More 'no_plan';
use lib qw(t/lib);

my $class = 'Beancounter';

use_ok( $class );

my $brick = $class->new;
isa_ok( $brick, $class );

my $pool_class = $brick->pool_class;
ok( $pool_class, "Pool class is defined: $pool_class" );

my $pool = $brick->create_pool;
isa_ok( $pool, $pool_class );

ok( defined &{ "${class}::_load_external_packages" }, 
	"_load_external_packages is there" );

ok( defined &{ "${class}::add_validator_packages" }, 
	"add_validator_packages is there" );
	

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
ok( ! defined &{ "${pool_class}::_is_the_number_3" },
	"_is_the_number_3 is not in $pool_class"
	);
ok( ! defined &{ "${pool_class}::_is_the_letter_e" },
	"_is_the_letter_e is not in $pool_class"
	);
	
use_ok( 'Mock::FooValidator' );

ok( ! defined &{ "${pool_class}::_is_the_number_3" },
	"_is_the_number_3 is not in $pool_class"
	);
ok( ! defined &{ "${pool_class}::_is_the_letter_e" },
	"_is_the_letter_e is not in $pool_class"
	);

$brick->add_validator_packages( 'Mock::FooValidator' );	

ok( defined &{ "${pool_class}::_is_the_number_3" },
	"_is_the_number_3 is in $pool_class after add_validator_packages"
	);
isa_ok( $pool->_is_the_number_3, ref sub {} );	

ok( defined &{ "${pool_class}::_is_the_letter_e" },
	"_is_the_letter_e is in $pool_class after add_validator_packages"
	);
isa_ok( $pool->_is_the_letter_e, ref sub {} );	

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
ok( ! defined &{ "${pool_class}::_is_odd_number" },
	"_is_the_number_3 is not in $pool_class"
	);
ok( ! defined &{ "${pool_class}::_is_even_number" },
	"_is_the_letter_e is not in $pool_class"
	);

use_ok( 'Mock::BarValidator' );

ok( ! defined &{ "${pool_class}::_is_odd_number" },
	"_is_the_number_3 is not in $pool_class"
	);
ok( ! defined &{ "${pool_class}::_is_even_number" },
	"_is_the_letter_e is not in $pool_class"
	);
	
$brick->add_validator_packages( 'Mock::BarValidator' );	

ok( defined &{ "${pool_class}::_is_odd_number" },
	"_is_the_number_3 is not in $pool_class after add_validator_packages"
	);
isa_ok( $pool->_is_odd_number, ref sub {} );	

ok( defined &{ "${pool_class}::_is_even_number" },
	"_is_the_letter_e is not in $pool_class after add_validator_packages"
	);
isa_ok( $pool->_is_even_number, ref sub {} );	
