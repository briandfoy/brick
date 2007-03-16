# $Id: Selectors.pm 2183 2007-02-27 23:24:59Z comdog $
package Brick::Result;
use strict;

use vars qw($VERSION);

use Carp qw(croak);

$VERSION = sprintf "1.%04d", q$Revision: 2183 $ =~ m/ (\d+) /xg;

=head1 NAME

Brick::Result - the result of applying a profile

=head1 SYNOPSIS

	use Brick;
	
	my $result = $brick->apply( $Profile, $Input );

	$result->explain;
	
=head1 DESCRIPTION

This class provides methods to turn the data structure returned
by apply() into a useable form for particular situations.

=over

=item explain

Create a string the shows the result in an outline form.

=cut

sub explain
	{
	my( $result ) = @_;

	my $str   = '';

	foreach my $element ( @$result )
		{
		my $level = 0;
		
		$str .= "$$element[0]: ";
		
		if( $element->[2] ) 
			{
			$str .= "passed $$element[1]\n\n";
			next;
			}
		else
			{
			$str .= "failed $$element[1]\n";
			}
			
		my @uses = ( [ $level, $element->[3] ] );

		while( my $pair = shift @uses )
			{
			# is it a single error or a composition?
			unless( ref $pair->[1] )
				{
				next;
				}
			elsif( exists $pair->[1]->{errors} )
				{
				unshift @uses, map {
					[ $pair->[0] + 1, $_ ]
					} @{ $pair->[1]->{errors} };
				}
			else
				{
				# this could come back as an array ref instead of a string
				$str .=  "\t" . #x $pair->[0] . 
					
					join( ": ", @{ $pair->[1] }{qw(failed_field handler message)} ) . "\n";
				}

			}

		$str.= "\n";
		}

	$str;
	}

=item flatten

Collapse the result structure to an array of flat hashes.

=cut

sub flatten
	{
	my( $result ) = @_;

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

=item flatten_by_field

Similar to flatten, but keyed by the field that failed the constraint.

=cut

sub flatten_by_field
	{
	my( $result ) = @_;

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

=item flatten_by

Similar to flatten, but keyed by the hash key named in the argument list.

=cut

sub flatten_by
	{
	my( $result, $key ) = @_;

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
				my $field = $hash->{$key};
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
	
=item dump

What should this do?

=cut

sub dump { croak "Not yet implemented" }



=back

=head1 TO DO

TBA

=head1 SEE ALSO


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
