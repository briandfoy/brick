#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

=head1 NAME

Brick use case to only report top-level errors

=head1 SYNOPSIS


=head1 DESCRIPTION

For this example, I want to create a complex contraint that I'll apply
separately to several values. These values will fail the constraint in
various ways, but I just want the top level errors.

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

sub Brick::Bucket::three_digit_odd_number
	{
	my( $bucket, $setup ) = @_;
	
	$setup->{exact_length} = 3;
	$setup->{filter_fields} = [ qw(just_right) ];
	
	$setup->{name} = "Remove non-digits";
	my $filter = $bucket->_remove_non_digits( $setup );
	
	$setup->{regex} = qr/
		[13579]          
		\z
		/x;
	
	my $regex = $bucket->_matches_regex( 
		{ %$setup, name => 'Odd-Even regex test'}
		);
	

	$setup->{name} = "Length is three characters";
	my $length = $bucket->_value_length_is_exactly( 
		$setup
		);

	$setup->{name} = "Three digit odd number";
	my $composed = $bucket->__compose_satisfy_all( 
		$filter, $regex, $length 
		);
		
	$bucket->__make_constraint( $composed, $setup );
	}
	
sub Brick::Bucket::twofer
	{
	my( $bucket, $setup ) = @_;
	
	$setup->{filter_fields} = $setup->{fields};
	
	$setup->{name} = "Remove non-digits";
	my $filter = $bucket->_remove_non_digits( $setup );
	
	$setup->{regex} = qr/
		[13579]          
		\z
		/x;
	
	my $regex = $bucket->_matches_regex( 
		{ %$setup, 
			name => 'Odd-Even regex test',
			field => 'even_number',
			}
		);
	

	$setup->{name} = "Length is three characters";
	my $length = $bucket->_value_length_is_exactly( 
		{ %$setup, field => 'short_number' }
		);

	$setup->{name} = "Three digit odd number";
	my $composed = $bucket->__compose_satisfy_all( 
		$filter, $regex, $length 
		);
		
	$bucket->__make_constraint( $composed, $setup );
	}
	
=head2 Create the profile


=cut 

my $Profile = [
	[ just_right  => three_digit_odd_number => { field => 'just_right'   } ],
	[ too_long    => three_digit_odd_number => { field => 'long_number'  } ],
	[ too_short   => three_digit_odd_number => { field => 'short_number' } ],
	[ even_number => three_digit_odd_number => { field => 'even_number'  } ],
	[ two_fields  => twofer                 => { fields => [ qw(even_number short_number) ] } ],
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

print STDERR "=" x 73, "\n";
print STDERR "\nExplaining profile:\n", $brick->explain( $Profile ) if $ENV{DEBUG};


=head2 Make some input data


=cut

my %Input = (
	just_right     => 123,
	long_number    => 12345,
	short_number   => 13,
	even_number    => 24,
	);

=head2 Apply the profile


=cut
	
my $result =  $brick->apply( $Profile, \%Input );

#print STDERR Data::Dumper->Dump( [$result], [qw($result)] ) if $ENV{DEBUG};

=head2 Organize the errors

Grab the top level errors

=cut

print STDERR "=" x 73, "\n";
print STDERR "\nExplaining result:\n",  $brick->explain_result( $result );


{
my $flatten = $brick->flatten_result( $result );
print STDERR "=" x 73, "\n";
print STDERR Data::Dumper->Dump( [$flatten], [qw($flatten)] ) if $ENV{DEBUG};
}

{
my $flatten = $brick->order_by_field( $result );
print STDERR "=" x 73, "\n";
print STDERR Data::Dumper->Dump( [$flatten], [qw($flatten)] ) if $ENV{DEBUG};
}

BEGIN {

sub Brick::flatten_result
	{
	my( $brick, $result ) = @_;

	my $str   = '';

	my @flatten;
	
	foreach my $element ( @$result ) # one element per profile element
		{
		next if $element->[2];
		my $constraint = $element->[1];
		
		my @uses = ( $element->[3]);

		while( my $hash = shift @uses )
			{
			# is it a single error or a composition?
			unless( ref $hash  )
				{
				next;
				}
			elsif( exists $hash->{errors} )
				{
				unshift @uses, @{ $hash->{errors} };
				}
			else
				{
				push @flatten, { %$hash, constraint => $constraint };
				}

			}

		}

	\@flatten;
	}


sub Brick::order_by_field
	{
	my( $brick, $result ) = @_;

	my $str   = '';

	my %flatten;
	my %Seen;
	
	foreach my $element ( @$result ) # one element per profile element
		{
		next if $element->[2];
		my $constraint = $element->[1];
		
		my @uses = ( $element->[3] );

		while( my $hash = shift @uses )
			{
			# is it a single error or a composition?
			unless( ref $hash  )
				{
				next;
				}
			elsif( exists $hash->{errors} )
				{
				unshift @uses, @{ $hash->{errors} };
				}
			else
				{
				my $field = $hash->{failed_field};
				next if $Seen{$field}{$hash->{handler}}++;
				$flatten{ $field } = [] unless exists $flatten{ $field };
				push @{ $flatten{ $field } }, 
					{ %$hash, constraint => $constraint };
				$Seen{$field}{$hash->{handler}}++;
				}

			}

		}

	\%flatten;
	}

}

