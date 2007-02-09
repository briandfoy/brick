use Test::More 'no_plan';

my $class = 'Beancounter';
use_ok( $class );

my $bean = $class->new();
isa_ok( $bean, $class );

$ENV{DEBUG} ||= 0;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
{
my @profile = (
);

my $lint = $bean->lint( \@profile );

is( $lint, 0, "Profile is formatted correctly\n" );

my $str = $bean->explain( \@profile );
print STDERR $str if $ENV{DEBUG};
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

my( $lint ) = $bean->lint( \@profile );

#print STDERR Data::Dumper->Dump( [$lint], [qw(lint)] );
#use Data::Dumper;

is( keys %$lint, 0, "Profile is formatted correctly\n" );

my $str = $bean->explain( \@profile );

#print STDERR "\n", "-" x 50, "\n", $str, "-" x 50,  "\n"  if $ENV{DEBUG};
}
