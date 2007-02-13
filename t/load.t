# $Id$
BEGIN {
	@classes = qw(Brick);
	
	push @classes, map { "Brick::$_" } qw(
		Bucket Composers Constraints Filters 
		General Numbers Regexes Selectors Strings
		);
	}

use Test::More tests => 2 + scalar @classes;

foreach my $class ( @classes )
	{
	print "bail out! $class did not compile\n" unless use_ok( $class );
	diag( "$class ---> " . $class->VERSION() . "\n" );
	}

# API shims
ok( defined &Brick::create_pool );
ok( ! eval { Brick->create_pool } );