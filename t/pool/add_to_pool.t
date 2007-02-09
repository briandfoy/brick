use Test::More 'no_plan';
use Test::Data qw(Scalar);

use strict;

use Beancounter::Pool;
use Beancounter::Numbers;

my $class = 'Beancounter::Pool';

use_ok( $class );

my $pool = $class->new;
isa_ok( $pool, $class );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# good entry
{
my $code_ref = sub { 5 };

my $sub = $pool->add_to_pool(
	{
	code        => $code_ref,
	name        => 'Fiver',
	description => 'Returns 5',
	}
	);
isa_ok( $sub, ref sub {} );	
	
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# bad entry
while (0 ){
my $entry = $pool->add_to_pool(
	{
	code        => '',
	name        => 'Fiver',
	description => 'Returns 5',
	}
	);
undef_ok( $entry, "Passing something other than a code ref returns undef" );	
	
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
can_ok( $class, 'number_within_range' );
can_ok( $class, '__compose_satisfy_all' );

$pool->add_to_pool( { code =>
	$pool->number_within_range( { qw( field in_number minimum 5 maximum 10 inclusive 1 ) } )
	} );
	
use Data::Dumper;
#print STDERR Data::Dumper->Dump( [ $pool ], [qw(pool)] );

__END__
my $level = 0;
foreach my $tuple ( map { [ $pool->{$_}{code}, $pool->{$_}{name} ] } keys %{ $pool } )
	{		
	#print "Sub is $sub\n";
	
	my @uses = ( [ $level, $tuple->[0] ] );
	
	#print Data::Dumper->Dump( [ \@uses ], [qw(uses)] );

	while( my $pair = shift @uses )
		{
		my $entry = $pool->get_from_pool( $pair->[1] );
		
		print STDERR "\t" x $pair->[0], $entry->get_name, "\n";
		
		unshift @uses, map { [ $pair->[0] + 1, $_ ] } @{ $entry->get_comprises( $pair->[1] ) };
		#print Data::Dumper->Dump( [ \@uses ], [qw(uses)] );
		}

	print "\n";
	}