# $Id$
package Brick::Bucket;
use strict;

use subs qw();
use vars qw($VERSION);

use Carp qw(carp croak);
use DateTime;

$VERSION = '0.10_01';

=head1 NAME

Brick - This is the description

=head1 SYNOPSIS

	use Brick;

=head1 DESCRIPTION


=over 4

=item _is_YYYYMMDD_date_format

=cut

sub _is_YYYYMMDD_date_format
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name => $caller[0]{'sub'},
		code => $bucket->_matches_regex( {
			description  => "The $hash->{field} is in the YYYYMMDD date format",
			field        => $hash->{field},
			name         => $caller[0]{'sub'},
			regex        => qr/
				\A
				\d\d\d\d   # year
				\d\d       # month
				\d\d       # day
				\z
				/x,
			} )
		} );
	}

sub _is_valid_date
	{
	my( $bucket, $hash ) = @_;

	my @caller = main::__caller_chain_as_list();

	$bucket->add_to_bucket( {
		name => $caller[0]{'sub'},
		code => sub {
			my $eval_error = 'Could not parse YYYYMMMDD date';
			if( my( $year, $month, $day ) =
				$_[0]->{$hash->{field}} =~ m/(\d\d\d\d)(\d\d)(\d\d)/g )
				{
				$eval_error = '';
				my $dt = eval {
					DateTime->new(
						year  => $year,
						month => $month,
						day   => $day,
						) };

				return 1 unless $@;
				$eval_error = $@;
				}

			my $date_error = do {
				if( $eval_error =~ /^The 'month' parameter/ )
					{ 'The month is not right' }
				elsif( $eval_error =~ /^Invalid day of month/ )
					{ 'The day of the month is not right' }
				else
					{ 'Could not parse YYYYMMMDD date' }
				};

			die {
				message => "The value in $hash->{field} [$_[0]->{$hash->{field}}] was not a valid date: $date_error",
				field   => $hash->{field},
				handler => $caller[0]{'sub'},
				} if $eval_error;

				1;
				},
		} );

	}

=item _is_YYYYMMDD_date_format

=cut

sub _is_in_the_future
	{
	my( $bucket, $hash ) = @_;
	croak "Not implemented";
	}

sub _is_tomorrow
	{
	my( $bucket, $hash ) = @_;
	croak "Not implemented";
	}

sub _is_today
	{
	my( $bucket, $hash ) = @_;
	croak "Not implemented";
	}

sub _is_yesterday
	{
	my( $bucket, $hash ) = @_;
	croak "Not implemented";
	}

sub _is_in_the_past
	{
	my( $bucket, $hash ) = @_;
	croak "Not implemented";
	}


sub _date_is_after
	{
	my( $bucket, $hash ) = @_;

	$bucket->add_to_bucket( {
		description => "Date is after the start date",
		code        => sub {
			my $start   = $hash->{start_date} || $_[0]->{$hash->{start_date_field}};
			my $in_date = $hash->{input_date} || $_[0]->{$hash->{input_date_field}};

			#print STDERR "date after: $start --> $in_date\n";
			die {
				message => "Date [$in_date] is not after start date [$start]",
				} if $in_date <= $start;
			1;
			},
		} );
	}

sub _date_is_before
	{
	my( $bucket, $hash ) = @_;

	$bucket->add_to_bucket( {
		description => "Date is before the end date",
		code        => sub {
			my $end     = $hash->{end_date}   || $_[0]->{$hash->{end_date_field}};
			my $in_date = $hash->{input_date} || $_[0]->{$hash->{input_date_field}};

			#print STDERR "date before: $in_date --> $end\n";
			die {
				message => "Date [$in_date] is not before end date [$end]",
				} if $end <= $in_date;
			},
		} );
	}

sub date_within_range  # inclusive, negative numbers indicate past
	{
	my( $bucket, $hash ) = @_;

	my $before_sub = $bucket->_date_is_before( $hash );
	my $after_sub  = $bucket->_date_is_after( $hash );

	my $composed   = $bucket->__compose_satisfy_all( $after_sub, $before_sub );

	$bucket->__make_constraint( $composed, $hash );
	}

=item days_between_dates_within_range


=cut

sub days_between_dates_within_range  # inclusive, negative numbers indicate past
	{
	my( $bucket, $hash ) = @_;

	$bucket->__make_constraint(
		$bucket->add_to_bucket( {
			name        => "Date within range",
			description => "",
			code        => sub {
				my $start   = $hash->{start_date} || $_[0]->{$hash->{start_date_field}};
				my $end     = $hash->{end_date}   || $_[0]->{$hash->{end_date_field}};
				my $in_date = $hash->{input_date} || $_[0]->{$hash->{input_date_field}};

				$start <= $in_date and $in_date <= $end;
				}
			} )
		);
	}

sub days_between_outside_range
	{
	my( $bucket, $hash ) = @_;

	$bucket->__make_constraint(
		$bucket->add_to_bucket( {
			name        => "Date outside of range",
			description => "",
			code        => sub {
				my $start   = $hash->{start_date} || $_[0]->{$hash->{start_date_field}};
				my $end     = $hash->{end_date}   || $_[0]->{$hash->{end_date_field}};
				my $in_date = $hash->{input_date} || $_[0]->{$hash->{input_date_field}};

				my $interval = _get_days_between( $start, $end );

				$interval < $start and $end < $interval;
				}
			} )
		);
	}

sub at_least_N_days_between
	{
	my( $bucket, $hash ) = @_;

	$bucket->__make_constraint(
		$bucket->add_to_bucket( {
			name        => "Date within $hash->{number_of_days} days of base date",
			description => "",
			code        => sub {
				my $start   = $hash->{start_date} || $_[0]->{$hash->{start_date_field}};
				my $end     = $hash->{end_date}   || $_[0]->{$hash->{end_date_field}};

				my $interval = _get_days_between( $start, $end );

				$hash->{number_of_days} >= $interval;
				}
			} )
		);
	}

sub at_most_N_days_between
	{
	my( $bucket, $hash ) = @_;

	$bucket->__make_constraint(
		$bucket->add_to_bucket( {
			name        => "Date within $hash->{number_of_days} days of base date",
			description => "",
			code        => sub {
				my $start   = $hash->{start_date} || $_[0]->{$hash->{start_date_field}};
				my $end     = $hash->{end_date}   || $_[0]->{$hash->{end_date_field}};

				my $interval = _get_days_between( $start, $end );
				print STDERR "Interval: $start --> $interval --> $end" if $ENV{DEBUG};
				$interval >= $hash->{number_of_days};
				}
			} )
		);
	}

sub at_most_N_days_after
	{
	my( $bucket, $hash ) = @_;

	croak "Not implemented!";
	}

sub at_most_N_days_before
	{
	my( $bucket, $hash ) = @_;

	croak "Not implemented!";
	}

sub before_fixed_date
	{
	my( $bucket, $hash ) = @_;

	croak "Not implemented!";
	}

sub after_fixed_date
	{
	my( $bucket, $hash ) = @_;

	croak "Not implemented!";
	}

# return negative values if second date is earlier than first date
sub _get_days_between
	{
	my( $start, $stop ) = @_;

	my @dates;

	foreach my $date ( $start, $stop )
		{
		my( $year, $month, $day ) = _get_ymd_as_hashref( $date );

		push @dates, DateTime->new(
			_get_ymd_as_hashref( $date )
			);
		}

	my $duration = $dates[1]->delta_days( $dates[0] );

	my $days = $duration->delta_days;
	}

sub __get_ymd_as_hashref
	{
	my $date = shift;

	my %hash = eval {
		die "Could not parse date!"
			unless $date =~ m/
			\A
			(\d\d\d\d)
			(\d\d)
			(\d\d)
			\z
			/x;

		my $dt = DateTime->new( year => $1, month => $2, day => $3 );

		map { $_, $dt->$_ } qw( year month day );
		};

	if( $@ )
		{
		$@ =~ s/\s+at\s+$0.*//s;
		carp( "$@: I got [$date] but was expecting something in YYYYMMDD format!" );
		return;
		}

	\%hash;
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
