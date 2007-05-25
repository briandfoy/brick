# $Id: Regexes.pm 2193 2007-03-15 06:41:50Z comdog $
package Brick::File;
use strict;

use base qw(Exporter);
use vars qw($VERSION);

$VERSION = sprintf "1.%04d", q$Revision: 2193 $ =~ m/ (\d+) /xg;

package Brick::Bucket;
use strict;

use Carp qw(croak);

=head1 NAME

Brick::File - This is the description

=head1 SYNOPSIS

see L<Brick>

=head1 DESCRIPTION

See C<Brick::Constraints> for the general discussion of constraint
creation.

=head2 Utilities

=over 4

=item is_file_format

=cut


# returns MIME type from File::MMagic on success, undef otherwise
sub _file_magic_type 
	{
	my( $bucket, $file ) = @_;
		
	require File::MMagic;
	
	my $mm = File::MMagic->new; 
	
	my $format = $mm->checktype_filename( $file || '' );
	
	## File::MMagic returns the illegal "application/msword" for all
	## microsoft junk.
	## We map this to either application/x-msword (default)
	## or application/vnd.ms-excel, depending on the extension
	
	my( $uploaded_ext ) = $file =~ m/\.(\w*)?$/g;

	if( $format eq "application/msword" ) 
		{
		no warnings 'uninitialized';
		
		$format = ($uploaded_ext =~ /^xl[st]$/)
			? 
			"application/vnd.ms-excel" 
				: 
			"application/x-msword";
		}
	elsif( $format =~ m|x-system/x-error| )
		{
		$format = undef;
		}
		
	return $format;
	}

sub _get_file_extensions_by_mime_type
	{
	my( $bucket, $type ) = @_;
	
	require MIME::Types;
       
	my $mime_types = MIME::Types->new;
	my $t          = $mime_types->type( $type || '' );
	my @extensions = $t ? $t->extensions : ();
	}


sub is_mime_type {
	my( $bucket, $setup ) = @_;

	my @caller = $bucket->__caller_chain_as_list;

	unless( UNIVERSAL::isa( $setup->{mime_types}, ref [] ) )
		{
    	croak( "The mime_types key must be an array reference!" );
		}
	
	my $hash = {
			name        => $setup->{name} || $caller[0]{'sub'},
			description => ( $setup->{description} || "Match a file extension" ),
			fields      => [ $setup->{field} ],
			code        => sub {
				my( $input ) = @_;
				
				die {
					message      => "[$input->{ $setup->{file_field} }] did not exist.",
					failed_field => $setup->{file_field},
					failed_value => $input->{ $setup->{file_field} },
					handler      => $caller[0]{'sub'},
					} unless -e $input->{ $setup->{file_field} };

				my $mime_type = $bucket->_file_magic_type( $input->{ $setup->{file_field} } );

				die {
					message      => "[$input->{ $setup->{file_field} }] did not yeild a mime type.",
					failed_field => $setup->{file_field},
					failed_value => $input->{ $setup->{file_field} },
					handler      => $caller[0]{'sub'},
					} unless $mime_type;
				
				foreach my $expected_type ( @{ $setup->{mime_types} } )
					{
					return 1 if lc $mime_type eq lc $expected_type;
					}

				die {
					message      => "[$input->{ $setup->{file_field} }] did not have the right mime type. I think it's $mime_type.",
					failed_field => $setup->{filename},
					failed_value => $input->{ $setup->{file_field} },
					handler      => $caller[0]{'sub'},
					};
				},
			};
			
	$bucket->__make_constraint(
		$bucket->add_to_bucket ( $hash )
		);	
	
	}

=item has_file_extension( ARRAY_REF )

This constraint checks the extension against a list of extensions
which are the elements of ARRAY_REF.

=cut

sub Brick::_get_file_extension # just a sub, not a method
	{ 
	lc +( split /\./, $_[0] )[-1];
	}
	
sub has_file_extension
	{
	my( $bucket, $setup ) = @_;

	my @caller = $bucket->__caller_chain_as_list;

	my %extensions = map { lc $_, 1 } @{ $setup->{extensions} };
		
	my $hash = {
			name        => $setup->{name} || $caller[0]{'sub'},
			description => ( $setup->{description} || "Match a file extension" ),
			fields      => [ $setup->{field} ],
			code        => sub {
				my $extension = Brick::_get_file_extension( $_[0]->{ $setup->{field} } );
				
				die {
					message      => "[$_[0]->{ $setup->{field} }] did not have the right extension",
					failed_field => $setup->{field},
					failed_value => $_[0]->{ $setup->{field} },
					handler      => $caller[0]{'sub'},
					} unless exists $extensions{ $extension };
				},
			};
			
	$bucket->__make_constraint(
		$bucket->add_to_bucket ( $hash )
		);

	}

=item

=cut

=pod

sub file_clamav_clean {
    my $clamscan = "/usr/local/bin/clamscan";

    return sub {
        my $dfv = shift;
        $dfv->name_this('file_clamav_clean');
        my $q = $dfv->get_input_data;

        # Set $ENV{PATH} to the empty string to avoid taint error from
        # exec call. Use local to temporarily clear it out in the context
        # of this sub.
        local $ENV{PATH} = q{};


        $q->UNIVERSAL::can('param') or
            die 'valid_file_clamav_clean: data object missing param() method';

        my $field = $dfv->get_current_constraint_field;

        my $img = $q->upload($field);

        if (not $img and my $err = $q->cgi_error) {
            warn $err;
            return undef;
        }

        my $tmp_file = $q->tmpFileName($q->param($field)) or
            (warn "$0: can't find tmp file for field named $field"),
                return undef;

        ## now return true if $tmp_file is not a virus, false otherwise
        unless (-x $clamscan) {
            warn "$0: can't find clamscan, skipping test";
            return 1;                   # it's valid because we don't see it
        }

        defined (my $pid = open KID, "-|") or die "Can't fork: $!";
        unless ($pid) {               # child does:
            open STDIN, "<$tmp_file" or die "Cannot open $tmp_file for input: $!";
            exec $clamscan, qw(--no-summary -i --stdout -);
            die "Cannot find $clamscan: $!";
        }
        ## parent does:
        my $results = join '', <KID>;
        close KID;
        return if $results; ## if clamscan spoke, it's a virus

        return 1;
    };
}

=back

=head1 TO DO

Regex::Common support

=head1 SEE ALSO

TBA

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
