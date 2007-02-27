#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

=head1 NAME

Brick use case to allow user defined names to make explain() output better

=head1 SYNOPSIS


=head1 DESCRIPTION

=cut

my $class = 'Brick';
use_ok( $class );

my $brick = Brick->new();
isa_ok( $brick, $class );

=head2 Create the constraint

=over 4

=item Input

=item Add to input hash

=item Get the pieces to test each condition

=item Compose the pieces

=item Turn the composition into a constraint

Most bricks that come with this module simply use their subroutine name
for the brick they add to the bucket.

To get around this, supply a C<name> parameter to the 

=back

=cut 

sub Brick::Bucket::odd_even_alternates
	{
	my( $bucket, $setup ) = @_;
	
	$setup->{exact_length} = 9;
	$setup->{filter_fields} = [ qw(number) ];
	
	my $filter = $bucket->_remove_non_digits( $setup );
	
	$setup->{regex} = qr/
		\A
		[13579]?          #maybe it starts with an odd
		([02468][13579])+ # even - odd pairs
		[02468]?          #maybe it ends with an even
		\z
		/x;
	
	my $sub = $bucket->_matches_regex( 
		{ %$setup, name => 'Odd-Even regex test'}
		);
	
	$setup->{name} = "Odd-Even regex test";

	my $composed = $bucket->__compose_satisfy_all( 
		$filter, $sub 
		);
		
	
	$bucket->__make_constraint( $composed, $setup );
	}
	
=head2 Create the profile


=cut 

my $Profile = [
	[ short       => odd_even_alternates => { field => 'short_number'  } ],
	[ long        => odd_even_alternates => { field => 'long_number'   } ],
	[ medium      => odd_even_alternates => { field => 'medium_number' } ],
	[ should_fail => odd_even_alternates => { field => 'bad_number'    } ],
	];
	
=head2 Test the profile with lint()

This isn't a necessary step, but it's nice to know that the profile
makes sense before you actually try to use it. Even if you don't do it
for production code, you might want this step in there so you can turn
it on for debugging.

=cut

my $lint = $brick->lint( $Profile );
unless( is( $lint, 0, "Profile has no errors" ) )
	{
	my %lint = $brick->lint( $Profile );
	
 	diag( Data::Dumper->Dumper( \%lint ) );
 	}

=head2 Dump the profile with explain()

This isn't a necessary step, but it's nice to know that the profile
makes sense before you actually try to use it. Even if you don't do it
for production code, you might want this step in there so you can turn
it on for debugging.

=cut

print STDERR "\nExplaining odd-even alternation profile:\n", 
	$brick->explain( $Profile ) if $ENV{DEBUG};

__END__
=head2 Get some input data

The input is a hash reference. The field names are the keys and their
values are the hash values.

=cut

my $Input = {
	long_number     => 1234567890123,
	short_number    => 234,
	medium_number   => 123456,
	bad_number      => 666,
	};
	
=head2 Validate the data with apply()

This isn't a necessary step, but it's nice to know that the profile
makes sense before you actually try to use it. Even if you don't do it
for production code, you might want this step in there so you can turn
it on for debugging.

=cut

my $result = $brick->apply( $Profile, $Input );
is( ref $result, ref [], "\$result comes back as an array reference" );

print Data::Dumper->Dumper( $result ) if $ENV{DEBUG};

=head2 Check the results

This isn't a necessary step, but it's nice to know that the profile
makes sense before you actually try to use it. Even if you don't do it
for production code, you might want this step in there so you can turn
it on for debugging.

=cut

#print STDERR Data::Dumper->Dump( [$result], [qw(result)] ) ; #if $ENV{DEBUG};
use Data::Dumper;

print STDERR "\n" if $ENV{DEBUG};

foreach my $index ( 0 .. $#$result )
	{
	my $entry = $result->[$index];

	print Data::Dumper->Dump( [$entry], [qw(entry)] );
	
	print STDERR "----- $entry->[0] ----------------------------\n" if $ENV{DEBUG};
	
	do { print STDERR "\tpassed\n\n" if $ENV{DEBUG}; next } if $entry->[2];
	
	my @data = ( $entry->[3] );
	my @errors = ();
	my $iterations = 0;
	while( my $error = shift @data )
		{
		last if $iterations++ > 20; # debugging guard against infinity
#		print STDERR "Iteration $iterations\n";
		if( $error->{handler} =~ m/^__/ )
			{
			push @data, @{ $error->{errors} };
			next;
			}
		
		push @errors, $error;
		}
		
	#print STDERR Data::Dumper->Dump( [\@errors], [qw(errors)] ) ; #if $ENV{DEBUG};

	#print STDERR "$entry->[0] checked by $entry->[1] which returned:\n\t$message\n";
	
	next unless ref $entry->[3] and @{ $entry->[3]{errors} } > 0;
	
	foreach my $error ( @errors )
		{
		print STDERR "$error->{handler}: $error->{message}\n" if $ENV{DEBUG};
		}
	
	print STDERR "\n" if $ENV{DEBUG};
	}

{
my $row = shift @$result;
is( $row->[2], 1, "zip_code passes" );
}

foreach my $row ( @$result )
	{
	is( $row->[2], 0, "$row->[0] fails (as expected)" );
	}