#!/usr/bin/perl

use Test::More 'no_plan';

use_ok( 'Beancounter::General' );
use_ok( 'Beancounter::Pool' );

use lib qw( t/lib );
use_ok( 'Mock::Pool' );

my $pool = Mock::Pool->new;
isa_ok( $pool, 'Mock::Pool' );
isa_ok( $pool, Mock::Pool->pool_class );

my $sub = $pool->_exist_fields( 
	{
	fields          => [ qw(one two red blue) ],
	}
	);
	
isa_ok( $sub, ref sub {}, "_exist_fields returns a code ref" );


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# All the fields are there
{

my $input = { map { $_, 1 } qw(one two red blue) };

my $result = eval {  $sub->( $input )  }; 
	
ok( defined $result, "Result succeeds for only required fields" );
diag( "Eval error: $@" ) unless defined $result;
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Extra fields are there
{

my $input = { map { $_, 1 } qw(one two red blue cat bird) };

my $result = eval { 
	$sub->( $input ) 
	}; 
	
ok( defined $result, "Result succeeds for extra fields" );
diag( "Eval error: $@" ) unless defined $result;
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Missing one field
{

my $input = { map { $_, 1 } qw(one two red) };

my $result = eval { 
	$sub->( $input ) 
	}; 

my $at = $@;
print STDERR Data::Dumper->Dump( [$at], [qw(at)] ) if $ENV{DEBUG};

    ok( ! defined $result, "Result fails (as expected)" );
isa_ok( $at, ref {}, "death returns a hash ref in \$@" );
    ok( exists $at->{handler}, "hash ref has a 'handler' key" );
    ok( exists $at->{message}, "hash ref has a 'message' key" );
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

