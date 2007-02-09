#!/usr/bin/perl

use vars qw(@modules);

BEGIN {
	@modules = qw(
		Brick	
		Brick::Composers
		Mock::Bucket
		Mock::FooValidator
		Mock::BarValidator
	);
	}
	
use Test::More tests => 1;
use strict;

my @modules = qw(
	Brick::Composers
	);

foreach my $module ( @modules )
	{
	print "BAIL OUT!" unless use_ok( $module );
	}
