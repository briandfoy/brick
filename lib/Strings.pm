# $Id$
package Beancounter::Pool;
use strict;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.10_01';

=head1 NAME

Beancounter::General - constraints for domain-nonspecific stuff

=head1 SYNOPSIS

	use Beancounter;

=head1 DESCRIPTION

=over 4

=item $pool->value_length_is_exactly( HASHREF )

	exact_length

=cut

sub _value_length_is_exactly
	{
	my( $pool, $hash ) = @_;

	$hash->{minimum_length} = $hash->{exact_length};
	$hash->{maximum_length} = $hash->{exact_length};

	$pool->_value_length_is_between( $hash );
	}

=item $pool->value_length_is_greater_than( HASHREF )

	minimum_length

=cut

sub _value_length_is_equal_to_greater_than
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool( {
		name        => $caller[0]{'sub'},
		description => "Length of value in $hash->{field} is greater than or equal to $hash->{minimum_length} characters",
		code        => sub {
			die {
				message => "Length of value in $hash->{field} [$_[0]->{ $hash->{field} }] isn't greater than or equal to $hash->{minimum_length} characters",
				handler     => $caller[1]{'sub'},
				} unless $hash->{minimum_length} <= length( $_[0]->{ $hash->{field} } )
			},
		} );
	}

=item $pool->value_length_is_less_than( HASHREF )

	maximum_length

=cut

sub _value_length_is_equal_to_less_than
	{
	my( $pool, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$pool->add_to_pool( {
		name        => $caller[0]{'sub'},
		description => "Length of value in $hash->{field} is less than or equal to $hash->{maximum_length} characters",
		code        => sub {
			die {
				message => "Length of value in $hash->{field} [$_[0]->{ $hash->{field} }] isn't less than or equal to $hash->{maximum_length} characters",
				handler => $caller[1]{'sub'},
				} unless length( $_[0]->{ $hash->{field} } ) <= $hash->{maximum_length}
			},
		} );
	}

=item $pool->value_length_is_between( HASHREF )

	minimum_length
	maximum_length

=cut

sub _value_length_is_between
	{
	my( $pool, $hash ) = @_;

	my $min = $pool->_value_length_is_equal_to_greater_than( $hash );
	my $max = $pool->_value_length_is_equal_to_less_than( $hash );

	my $composed = $pool->__compose_satisfy_all( $min, $max );
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
