package Brick::Profile;
use strict;
use warnings;

use Carp qw(carp);

use Brick;

=head1 NAME

Brick::Profile

=head1 SYNOPSIS


=head1 DESCRIPTION

=head2 Class methods

=over 4

=item new()

=cut

sub new 
	{
	my( $class, $brick, $array_ref ) = @_;
	
	my $self = bless {}, $class;
	
	my $lint_errors = $class->lint( $array_ref );
		
	if( ! defined $lint_errors or $lint_errors )
		{
		carp "Profile did not validate!";
		return;
		}
	
	my( $bucket, $refs ) = $brick->create_bucket( $array_ref );
	
	$self->set_bucket( $bucket );
	$self->set_coderefs( $refs );
	$self->set_array( $array_ref );
	
	return $self;
	}

=item lint

Examine the profile and complain about irregularities in format. This
only checks the format; it does not try to determine if the profile
works or makes sense. It returns a hash whose key is the index of the
profile element and whose value is an anonymous hash to indicate what
had the error:

	format  -   the element is an arrayref
	name    -   the name is a scalar
	method  -   is a code ref or can be found in the package
					$brick->bucket_class returns
	args    -   the last element is a hash reference

If the profile is not an array reference, C<lint> immediately returns
undef or the empty list. In scalar context, C<lint> returns 0 for
format success and the number of errors (so true) for format failures.
If there is a format error (e.g. an element is not an array ref), it
immediately returns the number of errors up to that point.

	my $lint = $brick->lint( \@profile );

	print do {
		if( not defined $lint ) { "Profile must be an array ref\n" }
		elsif( $lint )          { "Did not validate, had $lint problems" }
		else                    { "Woo hoo! Everything's good!" }
		};

In list context, it returns a hash (a list of one element). The result
will look something like this hash, which has keys for the elements
that lint thinks are bad, and the values are anonymous hashes with
keys for the parts that failed:

	%lint = (
		1 => {
			method => "Could not find method foo in package",
			},
		4 => {
			args => "Arguments should be a hash ref, but it was a scalar",
			}
		);

If you are using C<AUTOLOAD> to generate some of the methods at
runtime (i.e. after C<lint> has a chance to check for it), use a
C<can> method to let C<lint> know that it will be available later.

TO DO:

Errors for duplicate names?

=cut

sub lint
	{
	my( $class, $array ) = @_;

	return unless(
		eval { $array->isa( ref [] ) } or
		UNIVERSAL::isa( $array, ref [] )
		);

	my $lint = {};

	foreach my $index ( 0 .. $#$array )
		{
		my $h = $lint->{$index} = {};

		unless( eval { $array->[$index]->isa( ref [] ) } or
			UNIVERSAL::isa(  $array->[$index], ref [] )
			)
			{
			$h->{format} = "Not an array reference!";
			last;
			}

		my( $name, $method, $args ) = @{ $array->[$index] };

		$h->{name} = "Profile name is not a simple scalar!" if ref $name;

		$h->{args} = "Couldn't find method [$method]" unless
			eval { $method->isa( ref sub {} ) } or
			UNIVERSAL::isa( $method, sub {} )    or
			eval { Brick->bucket_class->can( $method ) }; #XXX which class though?

		$h->{args} = "Args is not a hash reference" unless
			eval { $args->isa( ref {} ) } or
			UNIVERSAL::isa( $args, ref {} );

		# args needs what?

		delete $lint->{$index} if 0 == keys %{$lint->{$index}};
		}

	wantarray ? %$lint : ( scalar keys %$lint );
	}
		
sub get_bucket
	{
	$_[0]->{bucket}
	}

sub set_bucket
	{
	$_[0]->{bucket} = $_[1];
	}
	
sub get_coderefs
	{
	$_[0]->{coderefs};
	}
	
sub set_coderefs
	{
	$_[0]->{coderefs} = $_[1];
	}

sub get_array
	{
	$_[0]->{array};
	}
	
sub set_array
	{
	$_[0]->{array} = $_[1];
	}

=back

=head1 TO DO

TBA

=head1 SEE ALSO

L<Brick::Tutorial>, L<Brick::UserGuide>

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in SVN, as well as all of the previous releases.

	svn co https://brian-d-foy.svn.sourceforge.net/svnroot/brian-d-foy brian-d-foy

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2007, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;