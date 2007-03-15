# $Id: Selectors.pm 2183 2007-02-27 23:24:59Z comdog $
package Brick::Result;
use strict;

use vars qw($VERSION);

$VERSION = sprintf "1.%04d", q$Revision: 2183 $ =~ m/ (\d+) /xg;


=head1 NAME

Brick::Result - the result of applying a profile

=head1 SYNOPSIS

	use Brick;
	
	my $result = $brick->apply( $Profile, $Input );

	
=head1 DESCRIPTION

=over

=cut

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
