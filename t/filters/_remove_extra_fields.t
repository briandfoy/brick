#!/usr/bin/perl

use Test::More 'no_plan';

use_ok( 'Beancounter::Filters' );
use_ok( 'Beancounter::Pool' );

use lib qw( t/lib );
use_ok( 'Mock::Pool' );

my $pool = Mock::Pool->new;
isa_ok( $pool, 'Mock::Pool' );
isa_ok( $pool, Mock::Pool->pool_class );

my $sub = $pool->_remove_extra_fields( { filter_fields => [ qw(cat dog bird) ] } );
	
isa_ok( $sub, ref sub {}, "_remove_extra_fields returns a code ref" );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Removes no keys
{
my $input = { 
	cat  => "Buster",
	dog  => "Missy",
	bird => "Poppy",
	};

my @keys = keys %$input;

foreach my $k ( @keys )
	{
	ok( exists $input->{$k}, "Key '$k' exists in input" );
	}
	
my $result = eval { $sub->( $input ) }; 

foreach my $k ( @keys )
	{
	ok( exists $input->{$k}, "Key '$k' still exists in input" );
	}
	
}



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Removes one key
{
my $input = { 
	cat  => "Buster",
	dog  => "Missy",
	bird => "Poppy",
	};

my @keys = keys %$input;
my @extra = qw( camel );

@{ $input }{ @extra } = (1) x @extra;

foreach my $k ( @keys, @extra )
	{
	ok( exists $input->{$k}, "Key '$k' exists in input" );
	}
	
my $result = eval { 
	$sub->( $input ) 
	}; 

#print Data::Dumper->Dump( [$input], [qw(input)] );

foreach my $k ( @keys )
	{
	ok( exists $input->{$k}, "Key '$k' still exists in input" );
	}

foreach my $k ( @extra )
	{
	ok( ! exists $input->{$k}, "Key '$k' removed from input" );
	}
}