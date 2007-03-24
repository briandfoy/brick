#!/usr/bin/perl

use_ok( 'Brick' );

use_ok( 'Brick::File' );


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

my @good_extensions = qw(jpg png gif);

my $sub = Brick::File::file_extension(
	{
	extensions => [ @good_extensions ],
	field      => 'upload_filename',
	name       => 'Image file checker',
	}
	);
	
isa_ok( $sub, ref sub {}, "I get back a sub" );


foreach my $extension ( @good_extensions )
	{
	my $result = $sub->(
		{
		upload_filename => "foo.$extension",
		}
		);
		
	ok( $result, "Sub returns true for good extension" );
	}