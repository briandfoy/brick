# $Revision$


=pod

=head1 NAME

Brick::User - How to use Brick

=head1 SYNOPSIS

=head1 DESCRIPTION

Some one told you to use this module to validate data, and you need to know
the shortest way to get that done. Someone else has created all the validation
routines, or "bricks", already and you just have to use them.

=head2 Construct your profile

Your profile describes the business rules that you want to apply to your input.
It's just a list of anonymous arrays that tell Brick what to do:

	@Profile = (
		[ label => constraint_name => { setup hash } ],
		...
		);
	
When I C<apply> this profile, Brick does it's magic.

	my $Brick = Brick->new();
	
	my $result = $Brick->apply( \@Profile, \%Input );

Brick goes through the profile one anonymous array at a time, and in order.
It validates one row of the anonymous array, saves the result, and moves on
to the next anonymous array. At the end, I have an anonymous array in C<$result>.
That anonymous array's elements correspond item for item to the elements in 
the profile. The first element in C<$result> goes with the first element
in C<@Profile>.

Each element in C<$result> is an anonymous array holding four items:

=over 4

=item The label of the profile element

=item The constraint it ran

=item The result: True if the data passed, and false otherwise.

=item The error message, if any, as an anonymous hash.

=back

=head2 Getting the error messages

	XXX: In progress

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