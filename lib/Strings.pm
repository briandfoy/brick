# $Id$
package Brick::Strings;
use strict;

use base qw(Exporter);
use vars qw($VERSION);

$VERSION = sprintf "1.%04d", q$Revision$ =~ m/ (\d+) /xg;

package Brick::Bucket;
use strict;

=head1 NAME

Brick::General - constraints for domain-nonspecific stuff

=head1 SYNOPSIS

	use Brick;

=head1 DESCRIPTION

=over 4

=item $bucket->value_length_is_exactly( HASHREF )

	exact_length

=cut

sub _value_length_is_exactly
	{
	my( $bucket, $setup ) = @_;

	$setup->{minimum_length} = $setup->{exact_length};
	$setup->{maximum_length} = $setup->{exact_length};

	$bucket->_value_length_is_between( $setup );
	}

=item $bucket->value_length_is_greater_than( HASHREF )

	minimum_length

=cut

sub _value_length_is_equal_to_greater_than
	{
	my( $bucket, $setup ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name        => $setup->{name} || $caller[0]{'sub'},
		description => "Length of value in $setup->{field} is greater than or equal to $setup->{minimum_length} characters",
		code        => sub {
			die {
				message => "Length of value in $setup->{field} [$_[0]->{ $setup->{field} }] isn't greater than or equal to $setup->{minimum_length} characters",
				handler     => $caller[1]{'sub'},
				} unless $setup->{minimum_length} <= length( $_[0]->{ $setup->{field} } )
			},
		} );
	}

=item $bucket->value_length_is_less_than( HASHREF )

	maximum_length

=cut

sub _value_length_is_equal_to_less_than
	{
	my( $bucket, $setup ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name        => $setup->{name} || $caller[0]{'sub'},
		description => "Length of value in $setup->{field} is less than or equal to $setup->{maximum_length} characters",
		code        => sub {
			die {
				message => "Length of value in $setup->{field} [$_[0]->{ $setup->{field} }] isn't less than or equal to $setup->{maximum_length} characters",
				handler => $caller[1]{'sub'},
				} unless length( $_[0]->{ $setup->{field} } ) <= $setup->{maximum_length}
			},
		} );
	}

=item $bucket->value_length_is_between( HASHREF )

	minimum_length
	maximum_length

=cut

sub _value_length_is_between
	{
	my( $bucket, $setup ) = @_;

	my $min = $bucket->_value_length_is_equal_to_greater_than( $setup );
	my $max = $bucket->_value_length_is_equal_to_less_than( $setup );

	my $composed = $bucket->__compose_satisfy_all( $min, $max );
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
