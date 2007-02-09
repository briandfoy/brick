use Test::More 'no_plan';
use strict;

my $class = 'Brick';
use_ok( $class );

my $brick = $class->new();
isa_ok( $brick, $class );


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
{
my @profile = ();
my %input   = ();

my $lint = $brick->lint( \@profile );

is( $lint, 0, "Profile is formatted correctly\n" );

my $result = $brick->apply( \@profile, \%input || {} );
#print STDERR $result || '';
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
{
my @profile = (
	[ in_number => number_within_range => { 
		minimum   => 0, 
		maximum   => 10, 
		field     => 'in_number', 
		inclusive => 1 
		} 
	],
	[ ex_number => number_within_range => { 
		minimum   => 0, 
		maximum   => 10, 
		field     => 'ex_number', 
		inclusive => 0 
		} 
	],

	);

my %input = (
	in_number => 5,
	ex_number => 0,
	);
	
my( $lint ) = $brick->lint( \@profile );

#print STDERR Data::Dumper->Dump( [$lint], [qw(lint)] );
#use Data::Dumper;

is( keys %$lint, 0, "Profile is formatted correctly\n" );

if( $ENV{DEBUG} )
	{
	print STDERR "\n", "-" x 50, "\n";
	my $result = $brick->apply( \@profile, \%input || {} );
	print STDERR "\n", "-" x 50, "\n";
	}
}
