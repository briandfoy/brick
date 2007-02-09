# $Id$
package Beancounter::Pool;
use strict;

use Beancounter::Pool;

use subs qw();
use vars qw($VERSION);

use Storable qw(dclone);

$VERSION = '0.10_01';

=head1 NAME

Beancounter - This is the description

=head1 SYNOPSIS

	use Beancounter;

=head1 DESCRIPTION

=cut

=over 4

=item $pool->number_within_range( HASHREF )

Hash fields:

	minimum   - the lower bound
	maximum   - the higher bound
	inclusive - true includes bounds, false excludes bounds

=cut

sub number_within_range
	{
	my( $pool, $hash ) = @_;

	my @missing = sort grep { ! defined $hash->{$_} } qw( minimum maximum );

  	if( @missing )
    	{
    	carp( sprintf "number_within_range missing %s%s attibute%s",
    		$missing[0],
    		$missing[1] ? " and $missing[1]" : '',
    		$missing[1] ? 's' : ''
    		);
    	return sub {};
		}

	my $format_sub = $pool->_is_decimal_integer( $hash );

	my $range_sub =	$hash->{inclusive} ?
			$pool->_inclusive_within_numeric_range( $hash )
				:
			$pool->_exclusive_within_numeric_range( $hash );

	my $composed_sub = $pool->__compose_satisfy_all( $format_sub, $range_sub );

	$pool->__make_constraint( $composed_sub, $hash );
	}

sub _is_only_decimal_digits
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	my $sub = $pool->_matches_regex( {
		description  => "The $hash->{field} value only has decimal digits",
		field        => $hash->{field},
		name         => $caller[0]{'sub'},
		regex        => qr/
			\A
			\d+  # digits only
			\z
			/x,
		} );

	my $composed = $pool->__compose_satisfy_all( $sub );

	$pool->add_to_pool( {
		name => $caller[0]{'sub'},
		code => $composed,
		} );
	}

sub _is_decimal_integer
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	my $sub = $pool->_matches_regex( {
		description  => "The $hash->{field} is an integer in base 10",
		field        => $hash->{field},
		name         => $caller[0]{'sub'},
		regex        => qr/
			\A
			(?:[+-])?  # optional leading sign
			\d+
			\z
			/x,
		} );

	my $composed = $pool->__compose_satisfy_all( $sub );

	$pool->add_to_pool( {
		name => $caller[0]{'sub'},
		code => $composed,
		} );
	}

sub _inclusive_within_numeric_range
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool( {
		description => "Find number within the range [$hash->{minimum}, $hash->{maximum}] inclusively",
		args        => [ dclone $hash ],
		fields      => [ $hash->{field} ],
		code        => $pool->__compose_satisfy_all(
			$pool->_numeric_equal_or_greater_than( $hash ),
			$pool->_numeric_equal_or_less_than( $hash ),
			),
		} );
	}

sub _exclusive_within_numeric_range
	{
	my( $pool, $hash ) = @_;

	$pool->add_to_pool( {
		description => "Find number within the range [$hash->{minimum}, $hash->{maximum}] exclusively",
		args        => [ dclone $hash ],
		fields      => [ $hash->{field} ],
		code        => $pool->__compose_satisfy_all(
			$pool->_numeric_strictly_greater_than( $hash ),
			$pool->_numeric_strictly_less_than( $hash ),
			),
		} );

	}

sub _numeric_equal_or_greater_than
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool({
		description => "The number is equal to or greater than $hash->{minimum}",
		args        => [ dclone $hash ],
		fields      => [ $hash->{field} ],
		code        => sub {
			die {
				message => "The number in $hash->{field} was $_[0]->{ $hash->{field} }, but should have been greater than or equal to $hash->{minimum}",
				field   => $hash->{field} ,
				handler => $caller[0]{'sub'},
				} unless $_[0]->{ $hash->{field} } >=  $hash->{minimum}
			},
		} );
	}

sub _numeric_strictly_greater_than
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool({
		description => "The number is greater than $hash->{minimum}",
		args        => [ dclone $hash ],
		fields      => [ $hash->{field} ],
		code        => sub {
			die {
				message => "The number in $hash->{field} was $_[0]->{ $hash->{field} }, but should have been strictly greater than $hash->{minimum}",
				field   => $hash->{field} ,
				handler => $caller[0]{'sub'},
				} unless $_[0]->{ $hash->{field} } >  $hash->{minimum};
			},
		} );
	}

sub _numeric_equal_or_less_than
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool({
		description => "The number is equal to or less than $hash->{maximum}",
		args        => [ dclone $hash ],
		fields      => [ $hash->{field} ],
		code        => sub {
			die {
				message => "The number in $hash->{field} was $_[0]->{ $hash->{field} }, but should have been less than or equal to $hash->{maximum}",
				field   => $hash->{field},
				handler => $caller[0]{'sub'},
				} unless $_[0]->{ $hash->{field} } <=  $hash->{maximum};
			},
		} );
	}

sub _numeric_strictly_less_than
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool({
		description => "The number is less than $hash->{maximum}",
		args        => [ dclone $hash ],
		fields      => [ $hash->{field} ],
		code        => sub {
			die {
				message => "The number in $hash->{field} was $_[0]->{ $hash->{field} }, but should have been strictly less than $hash->{maximum}",
				field   => $hash->{field},
				handler => $caller[0]{'sub'},
				} unless $_[0]->{ $hash->{field} } <  $hash->{maximum};
			},
		} );
	}

=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2007, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
