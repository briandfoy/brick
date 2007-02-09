# $Id$
package Brick::Bucket;
use strict;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.10_01';

=head1 NAME

Brick::Filters - do something to the input data

=head1 SYNOPSIS

	use Brick;

=head1 DESCRIPTION

=over 4

=item $bucket->_uppercase( HASHREF )

This modifies the input data permanently. It removes the non-digits
from the specified value in filter_fields. The value is no longer tainted
after this runs. It works on all of the fields.

	filter_fields

This filter always succeeds, so it will not generate an validation
error.

=cut

sub _uppercase
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name        => $caller[0]{'sub'},
		description => "filter: uppercase the input",
		code        => sub {
			foreach my $f ( @{ $hash->{filter_fields} } )
				{
				next unless exists $_[0]->{ $f };
				$_[0]->{ $f } = uc $_[0]->{ $f };
				}
			return 1;
			},
		} );
	}

=item $bucket->_lowercase( HASHREF )

This modifies the input data permanently. It removes the non-digits
from the specified value in filter_fields. The value is no longer tainted
after this runs. It works on all of the fields.

	filter_fields

This filter always succeeds, so it will not generate an validation
error.

=cut

sub _lowercase
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name        => $caller[0]{'sub'},
		description => "filter: uppercase the input",
		code        => sub {
			foreach my $f ( @{ $hash->{filter_fields} } )
				{
				next unless exists $_[0]->{ $f };
				$_[0]->{ $f } = lc $_[0]->{ $f };
				}
			return 1;
			},
		} );
	}

=item $bucket->_remove_non_digits( HASHREF )

This modifies the input data permanently. It removes the non-digits
from the specified value in filter_fields. The value is no longer tainted
after this runs. It works on all of the fields.

	filter_fields

This filter always succeeds, so it will not generate an validation
error.

=cut

sub _remove_non_digits
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name        => $caller[0]{'sub'},
		description => "filter: remove non-digits",
		code        => sub {
			foreach my $f ( @{ $hash->{filter_fields} } )
				{
				next unless exists $_[0]->{ $f };
				$_[0]->{ $f } =~ tr/0-9//cd;
				$_[0]->{ $f } =
					$_[0]->{ $f } =~ m/([0-9]*)/
						?
						$1
						:
						'';
				}
			return 1;
			},
		} );
	}

=item $bucket->_remove_whitespace( HASHREF )

This modifies the input data permanently. It removes the whitespace
from the specified value in filter_fields. The value is still tainted
after this runs.

	filter_fields

This filter always succeeds, so it will not generate an error.

=cut

sub _remove_whitespace
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name        => $caller[0]{'sub'},
		description => "filter: remove whitespace",
		code        => sub {
			foreach my $f ( @{ $hash->{filter_fields} } )
				{
				next unless exists $_[0]->{ $f };
				$_[0]->{ $f } =~ tr/\n\r\t\f //d;
				}
			},
		} );
	}

=item $bucket->_remove_extra_fields( HASHREF )

This modifies the input data permanently. It removes any fields in
the input that are not also in the 'filter_fields' value in HASHREF.

	filter_fields

This filter always succeeds, so it will not generate an error.

=cut

sub _remove_extra_fields
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	my %allowed = map { $_, 1 } @{ $hash->{filter_fields} };

	$bucket->add_to_bucket( {
		name        => $caller[0]{'sub'},
		description => "filter: remove extra fields",
		code        => sub {
			foreach my $f ( keys % {$_[0] } )
				{
				delete $_[0]->{$f} unless exists $allowed{$f};
				}
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
