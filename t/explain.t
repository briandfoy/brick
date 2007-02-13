use Test::More 'no_plan';

my $class = 'Brick';
use_ok( $class );

my $brick = $class->new();
isa_ok( $brick, $class );

$ENV{DEBUG} ||= 0;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
{
my @profile = (
);

my $lint = $brick->lint( \@profile );

is( $lint, 0, "Profile is formatted correctly\n" );

my $str = $brick->explain( \@profile );
print STDERR $str if $ENV{DEBUG};
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# SHOULD WORK
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

my( $lint ) = $brick->lint( \@profile );

#print STDERR Data::Dumper->Dump( [$lint], [qw(lint)] );
#use Data::Dumper;

is( keys %$lint, 0, "Profile is formatted correctly\n" );

my $str = $brick->explain( \@profile );

#print STDERR "\n", "-" x 50, "\n", $str, "-" x 50,  "\n"  if $ENV{DEBUG};
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# SHOULD FAIL
{
my @profile = (
	[ in_number => number_within_range => { 
		minimum   => 0, 
		maximum   => 10, 
		field     => 'in_number', 
		inclusive => 1 
		} 
	],
	{},
	[ ex_number => number_within_range => { 
		minimum   => 0, 
		maximum   => 10, 
		field     => 'ex_number', 
		inclusive => 0 
		} 
	],

	);

my $lint = eval { $brick->lint( \@profile ) };

is( $lint, 1, "Profile is formatted correctly\n" );

my $str = eval { $brick->explain( \@profile ) };

is( $str, undef, "Profile is formatted correctly\n" );

#print STDERR "\n", "-" x 50, "\n", $str, "-" x 50,  "\n"  if $ENV{DEBUG};
}
