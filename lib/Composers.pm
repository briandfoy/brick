# $Id$
package Brick::Composers;
use base qw(Exporter);
use vars qw($VERSION);

$VERSION = sprintf "1.%04d", q$Revision$ =~ m/ (\d+) /xg;

use Brick::Bucket;

package Brick::Bucket;
use strict;

use Carp qw(carp);

=head1 NAME

Brick::Composers - This is the description

=head1 SYNOPSIS

	use Brick::Constraints::Bucket;

=head1 DESCRIPTION

This module defines composing functions in the
Brick::Constraints package. Each function takes a list of code
refs and returns a single code ref that wraps all of them. The single
code ref returns true or false (but defined), as with other
constraints.

If a composer cannot create the single code ref (for instance, due to
bad input) it returns C<undef> of the empty list, indicating a failure
in programming rather than a failure of the data to validate.

=cut

=over 4

=item __compose_satisfy_all( LIST OF CODEREFS )

This is AND with NO short-circuiting.

	( A && B && C )
	
This function creates a new constraint that returns true if all of its
constraints return true. All constraints are checked so there is no
short-circuiting. This allows you to get back all of the errors at
once.

=cut

sub __compose_satisfy_all
	{
	my $bucket = shift;
	$bucket->__compose_satisfy_N( scalar @_, @_ );
	}

=item __compose_satisfy_any( LIST OF CODEREFS )

This is OR but with NO short-circuiting.

	( A || B || C )
	
This function creates a new constraint that returns true if all of its
constraints return true. All constraints are checked so there is no
short-circuiting.

=cut

sub __compose_satisfy_any
	{
	my $bucket = shift;
	$bucket->__compose_satisfy_N_to_M( 1, scalar @_, @_ );
	}

=item __compose_satisfy_none( LIST OF CODEREFS )


	( NOT A && NOT B && NOT C )
	
	NOT ( A || B || C )

This function creates a new constraint that returns true if all of its
constraints return false. All constraints are checked so there is no
short-circuiting.
	
=cut

sub __compose_satisfy_none
	{
	my $bucket = shift;
	$bucket->__compose_satisfy_N_to_M( 0, 0, @_ );
	}

=item __compose_satisfy_N( SCALAR, LIST OF CODEREFS )

This function creates a new constraint that returns true if exactly N
of its constraints return true. All constraints are checked so there
is no short-circuiting.

=cut

sub __compose_satisfy_N
	{
	my( $bucket, $n, @subs ) = @_;

	$bucket->__compose_satisfy_N_to_M( $n, $n, @subs );
	}

=item __compose_satisfy_N_to_M( LIST OF CODEREFS )

This function creates a new constraint that returns true if between N
and M (inclusive) of its constraints return true. All constraints are
checked so there is no short-circuiting.

=cut

sub __compose_satisfy_N_to_M
	{
	my( $bucket, $n, $m, @subs ) = @_;

	if( grep { ref $_ ne ref sub {} } @subs )
		{
		croak "Got something else when expecting code ref!";
		return sub {};
		}

	my @caller = main::__caller_chain_as_list();

	my @composers = grep { /^__compose/ } map { $_->{sub} } @caller;

	my $max = @subs;

	my $sub = $bucket->add_to_bucket( {
		name => $composers[-1], # forget the chain of composers
		code => sub {
			my $count = 0;
			my @dies = ();
			foreach my $sub ( @subs )
				{
				eval { $sub->( @_ ) };
				my $at = $@;
				$count++ unless $at;
				#print STDERR "\n!!!!Sub died!!!!\n" if ref $at;
				#print STDERR "\n", Data::Dumper->Dump( [$at], [qw(at)]) if ref $at;
				die if( ! ref $at and $at );
				push @dies, $at if ref $at;
				};

			my $range = $n == $m ? "exactly $n" : "between $n and $m";

			die {
				message => "Satisfied $count of $max sub-conditions, needed to satisfy $range",
				handler => $caller[0]{'sub'},
				errors  => \@dies,
				} unless $n <= $count and $count <= $m;
			},
		});

	$bucket->comprise( $sub, @subs );

	return $sub;
	}

=item __compose_not( CODEREF )
 
This composers negates the sense of the code ref. If the code ref returns
true, this composer makes it false, and vice versa.

=cut

sub __compose_not
	{
	my( $bucket, $not_sub ) = @_;

	my $sub = $bucket->add_to_bucket( {
		code => sub { if( $not_sub->( @_ ) ) { die {} } else { return 1 } },
		} );

	return $sub;
	}



=item __compose_pass_or_skip

Go through the list of closures, trying each one until one suceeds. If a closure
doesn't suceed, don't fail, just move on. Return true for the first one that
passes, short-circuited the rest. If none of the closures pass, die with an
error noting that nothing passed.

This can still die for programming (not logic) errors.

=cut

sub __compose_pass_or_skip
	{
	my( $bucket, @subs ) = @_;

	if( grep { ref $_ ne ref sub {} } @subs )
		{
		croak "Got something else when expecting code ref!";
		return sub {};
		}

	my @caller = main::__caller_chain_as_list();

	my $max = @subs;

	my $sub = $bucket->add_to_bucket( {
		code => sub {
			my $count = 0;
			my @dies = ();

			foreach my $sub ( @subs )
				{
				my $result = eval { $sub->( @_ ) };
				my $at = $@;
				#print STDERR "\tskip: Returned result: $result\n";
				#print STDERR "\tskip: Returned undef!\n" unless defined $result;
				#print STDERR "\tskip: Returned ref!\n" if ref $at;
				return "$sub" if $result;   # we know we passed
				return if ( ! defined $result and ! defined $at );  # we're a selector: failed with no error
				#print STDERR "skip: Still going!\n";

				die if( ref $at and $at );  # die for everything else
				};

			die {
				message => "Nothing worked! Unexpected failure of all branches",
				handler => $caller[0]{'sub'},
				errors  => \@dies,
				};
			},
		});

	$bucket->comprise( $sub, @subs );

	return $sub;
	}

=item __compose_pass_or_stop

Keep going as long as the closures return true.

The closure that returns undef is a selector.

If a closure doesn't die and doesn't don't fail, just move on. Return true for
the first one that passes, short-circuited the rest. If none of the
closures pass, die with an error noting that nothing passed.

This can still die for programming (not logic) errors.


	$result		$@			what		action
	------------------------------------------------------------
		1		undef		passed		go on to next brick

		undef	undef		selector	stop, return undef, no die
							failed

		undef	string		program		stop, die with string
							error

		undef	ref			validator	stop, die with ref
							failed

=cut

sub __compose_pass_or_stop
	{
	my( $bucket, @subs ) = @_;

	if( grep { ref $_ ne ref sub {} } @subs )
		{
		croak "Got something else when expecting code ref!";
		return sub {};
		}

	my @caller = main::__caller_chain_as_list();

	my $max = @subs;

	my $sub = $bucket->add_to_bucket( {
		code => sub {
			my $count = 0;
			my @dies = ();

			my $last_result;
			foreach my $sub ( @subs )
				{
				no warnings 'uninitialized';
				my $result = eval { $sub->( @_ ) };
				my $at = $@;
				#print STDERR "\tstop: Returned result: $result\n";
				#print STDERR "\tstop: Returned undef!\n" unless defined $result;
				#print STDERR "\tstop: Returned ref!\n" if ref $at;
				$last_result = $result;

				next if $result;

				die $at if ref $at;

				return unless( defined $result and ref $at );

				die if( ref $at and $at ); # die for program errors
				#print STDERR "\tStill going\n";
				};

			return $last_result;
			},
		});

	$bucket->comprise( $sub, @subs );

	return $sub;
	}

=back

=head1 TO DO

TBA

=head1 SEE ALSO

TBA

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
