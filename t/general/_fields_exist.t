#!/usr/bin/perl

use Test::More 'no_plan';

use_ok( 'Brick::General' );
use_ok( 'Brick::Bucket' );

use lib qw( t/lib );
use_ok( 'Mock::Bucket' );

my $bucket = Mock::Bucket->new;
isa_ok( $bucket, 'Mock::Bucket' );
isa_ok( $bucket, Mock::Bucket->bucket_class );

my $sub = $bucket->_fields_exist( 
	{
	fields          => [ qw(one two red blue) ],
	}
	);
	
isa_ok( $sub, ref sub {}, "_fields_exist returns a code ref" );


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

