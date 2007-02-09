# $Id$
package Beancounter;
use strict;

use subs qw();
use vars qw($VERSION);

use Carp qw( carp croak );
use Data::Dumper;

$VERSION = '0.10_01';

=head1 NAME

Beancounter - This is the description

=head1 SYNOPSIS

	use Beancounter;

	my $bean = Beancounter->new( {
		external_packages => [ qw(Foo::Validator Bar::Validator) ]
		} );

	my @profile = (
		[ required  => sub { .... }    => $hash ],
		[ optional  => optional_fields => $hash ],

		[ inside    => in_number       => $hash ],

		[ outside   => ex_number       => $hash ],
		);

	my $results = $bean->apply( \@profile, \%input );

=head1 DESCRIPTION


=head2 Class methods

=over 4

=item Beancounter->new

Create a new C<Beancounter>. Currently this doesn't do anything other than
give you an object so you can call methods.

Future ideas? Maybe store several pools or profiles?

=cut

sub new
	{
	my( $class, $args ) = @_;
	
	my $self = bless {}, $class;

	$self->init( $args );
	
	$self->_load_external_packages( @{ $args->{external_packages} } );

	$self;
	}

sub _load_external_packages
	{
	my( $self, @packages ) = @_;
	
	my $pool_class = $self->pool_class;

	foreach my $package ( @packages )
		{
		eval "package $pool_class; require $package; $package->import";
		}
	
	}
	
=item Beancounter->error_str

The error message from the last things that happened.

=cut

{
my $Error;

sub error     { $_[0]->_set_error( $_[1] ); croak $_[1]; }
sub error_str { $Error }

# do some stuff to figure out caller, etc
sub _set_error { $Error = $_[1] }
}

=back

=head2 Instance methods

=over 4

=item $bean->init

Initialize the instance, or return it to a pristine state. Normally
you don't have to do this because C<new> does it for you, but if you
subclass this you might want to override it.

=cut

sub init
	{
	my( $self, $args ) = @_;

	my $pool_class = $self->pool_class;
	
	eval "require $pool_class";

	$self->{pools} = [];
	
	if( defined $args->{external_packages} && 
		! UNIVERSAL::isa( $args->{external_packages}, ref [] ) )
		{
		carp "'external_packages' value must be an anonymous array";
		$args->{external_packages} = [];
		}
	}

=item $bean->add_validator_packages( PACKAGES )

Load external validator packages into the pool. Each of these packages
should export the functions they want to make available. C<add_validator_package>
C<require>s each package and calls its C<import> routine.

=cut

sub add_validator_packages
	{
	my( $self, @packages ) = @_;
	
	$self->_load_external_packages( @packages );
	}


=item my $new_bean = $bean->clone;

Based on the current instance, create another one just like it but not
connected to it (in effect forking the instance). After the C<clone>
you can change new instance without affecting the old one. This is handy
in C<explain>, for instance, where I want a deep copy for a moment. At least
I think I want a deep copy.

That's the idea. Right now this just returns the instance. When not using
a copy breaks, I'll fix that.

=cut

sub clone
	{
	my( $bean ) = shift;

	$bean;
	}

=item my $result_arrayref = $bean->apply(  PROFILE_ARRAYREF, INPUT_DATA_HASHREF )

Apply the profile to the data in the input hash reference. It returns an
array reference whose elements correspond to the elements in the profile.

=cut

sub apply
	{
	my( $bean, $profile, $input ) = @_;

	my( $pool, $refs ) = $bean->create_pool( $profile );

	my @entries = map {
		my $e = $pool->get_from_pool( $_ );
		[ map { $e->$_ } qw(get_coderef get_name) ]
		} @$refs;

	my @results = ();

	foreach my $index ( 0 .. $#entries )
		{
		my $e    = $entries[$index];
		my $name = $profile->[$index][0];

		print STDERR "Checking $name..." if $ENV{DEBUG};

		my $result = eval{ $e->[0]->( $input ) };
		my $eval_error = $@;

		#print STDERR Data::Dumper->Dump( [$eval_error], [qw(eval_error)] );

		$result = 0 if ref $eval_error;

		my $handler = ref $@ ? $@->{handler} : $profile->[$index][1];

		push @results, [ $name, $handler, $result, $@ ];

		print STDERR do {
			if( ref $eval_error )
				{
				"failed";
				}
			elsif( defined $eval_error and $eval_error )
				{
				'unknown';
				}
			elsif( $result == 1 )
				{
				"passed";
				}

			}, "\n" if $ENV{DEBUG};

		}

	return \@results;
	}

=item $bean->explain( PROFILE_ARRAYREF )

Turn the profile into a textual description without applying it to any
data. This does not add the profile to instance and it does not add
the constraints to the pool.

If everything goes right, this returns a single string that represents
the profile.

If the profile does not pass the C<lint> test, this returns undef or the
empty list.

If you want to do something with a datastructure, you probably want to
write a different method very similar to this instead of trying to parse
the output.

Future notes: maybe this is just really a dispatcher to things that do
it in different ways (text output, hash output).

=cut

sub explain
	{
	my( $bean, $profile ) = @_;

	my $temp_bean = $bean->clone;

	if( $temp_bean->lint( $profile ) )
		{
		carp "Profile did not validate!";
		return;
		}

	my( $pool, $refs ) = $temp_bean->create_pool( $profile );
		#print STDERR Data::Dumper->Dump( [ $pool ], [qw(pool)] );
		#print STDERR Data::Dumper->Dump( [ $refs ], [qw(refs)] );

	my @entries = map {
		my $e = $pool->get_from_pool( $_ );
		[ map { $e->$_ } qw(get_coderef get_name) ]
		} @$refs;

	#print STDERR Data::Dumper->Dump( [ \@entries ], [qw(entries)] );

	my $level = 0;
	my $str   = '';
	foreach my $index ( 0 .. $#entries )
		{
		my $tuple = $entries[$index];

		my @uses = ( [ $level, $tuple->[0] ] );

		#print STDERR Data::Dumper->Dump( [ \@uses ], [qw(uses)] );

		while( my $pair = shift @uses )
			{
			my $entry = $pool->get_from_pool( $pair->[1] );
			#print Data::Dumper->Dump( [ $entry ], [qw(entry)] );
			next unless $entry;

			$str .=  "\t" x $pair->[0] . $entry->get_name . "\n";

			unshift @uses, map {
				[ $pair->[0] + 1, $_ ]
				} @{ $entry->get_comprises( $pair->[1] ) };
			#print Data::Dumper->Dump( [ \@uses ], [qw(uses)] );
			}

		$str.= "\n";
		}

	$str;
	}

=item $bean->lint

Examine the profile and complain about irregularities in format. This
only checks the format; it does not try to determine if the profile
works or makes sense. It returns a hash whose key is the index of the
profile element and whose value is an anonymous hash to indicate what
had the error:

	format  -   the element is an arrayref
	name    -   the name is a scalar
	method  -   is a code ref or can be found in the package
					$bean->pool_class returns
	args    -   the last element is a hash reference

If the profile is not an array reference, C<lint> immediately returns
undef or the empty list. In scalar context, C<lint> returns 0 for
format success and the number of errors (so true) for format failures.
If there is a format error (e.g. an element is not an array ref), it
immediately returns the number of errors up to that point.

	my $lint = $bean->lint( \@profile );

	print do {
		if( not defined $lint ) { "Profile must be an array ref\n" }
		elsif( $lint )          { "Did not validate, had $lint problems" }
		else                    { "Woo hoo! Everything's good!" }
		};

In list context, it returns a hash (a list of one element). The result
will look something like this hash, which has keys for the elements
that lint thinks are bad, and the values are anonymous hashes with
keys for the parts that failed:

	%lint = (
		1 => {
			method => "Could not find method foo in package",
			},
		4 => {
			args => "Arguments should be a hash ref, but it was a scalar",
			}
		);

If you are using C<AUTOLOAD> to generate some of the methods at
runtime (i.e. after C<lint> has a chance to check for it), use a
C<can> method to let C<lint> know that it will be available later.

TO DO:

Errors for duplicate names?

=cut

sub lint
	{
	my( $bean, $profile ) = @_;

	return unless(
		eval { $profile->isa( ref [] ) } or
		UNIVERSAL::isa( $profile, ref [] )
		);

	my $lint = {};

	foreach my $index ( 0 .. $#$profile )
		{
		my $h = $lint->{$index} = {};

		unless( eval { $profile->[$index]->isa( ref [] ) } or
			UNIVERSAL::isa(  $profile->[$index], ref [] )
			)
			{
			$h->{format} = "Not an array reference!";
			last;
			}

		my( $name, $method, $args ) = @{ $profile->[$index] };

		$h->{name} = "Profile name is not a simple scalar!" if ref $name;

		$h->{args} = "Couldn't find method [$method]" unless
			eval { $method->isa( ref sub {} ) } or
			UNIVERSAL::isa( $method, sub {} )    or
			eval { $bean->pool_class->can( $method ) }; #XXX which class though?

		$h->{args} = "Args is not a hash reference" unless
			eval { $args->isa( ref {} ) } or
			UNIVERSAL::isa( $args, ref {} );

		# args needs what?

		delete $lint->{$index} if 0 == keys %{$lint->{$index}};
		}

#print STDERR Data::Dumper->Dump( [$lint], [qw(lint)] );
#use Data::Dumper;

	# set errors;
	wantarray ? %$lint : ( scalar keys %$lint );
	}

=item $bean->create_pool( PROFILE_ARRAYREF )

This method creates a C<Beancounter::Pool> instance (or an instance in
the package returned by C<$bean->pool_class> ) based on the profile
and returns the pool instance. Along the way it affects the args
hashref in each profile element to add the element name as the key
C<profile_name> and the actual coderef (not just the method name) as
the key C<code>. The closure generators are allowed to use those keys.
For instance, C<__make_constraint>, which is usually the top level
closure, uses it to name the closure in the pool.

If the profile doesn't pass C<lint> test, this method croaks. You
might want to safeguard that by calling C<lint> first.

	my $pool = do {
		if( my( $lint ) = $bean->lint( $profile ) )
			{
			$bean->create_pool( $profile );
			}
		else
			{
			Data::Dumper->Dump( [ $lint ], [qw(lint)] );
			undef;
			}
		};

From the profile it extracts the method name to create the closure for
it based on its arguments. If the method item is already a code
reference it uses it add is, but still adds it to the pool. This could
be handy for using closures from other classes, but I haven't
investigated the consequences of that.

In scalar context this returns a new pool instance. If the profile might
be bad, use an eval to catch the croak:

	my $pool = eval{ $bean->create_pool( \@profile ) };

In list context, it returns the C<$pool> instance and an anonymous array
reference with the stringified closures (which are also the keys in the
pool). The elements in the anonymous array correspond to the elements in
the profile. This is handy in C<explain> which needs to find the pool
entries for each profile elements. You probably won't need the second
argument most of the time.

	my( $pool, $refs ) = eval { $bean->create_pool( \@profile ) };

=cut

sub create_pool
	{
	my( $bean, $profile ) = @_;

	unless( 0 == $bean->lint( $profile || [] ) ) # zero but true!
		{
		croak "Bad profile for create_pool! Perhaps you need to check it with lint"
		};

	my $pool = $bean->pool_class->new;

	my @coderefs = ();
	foreach my $entry ( @$profile )
		{
		my( $name, $method, $args ) = @$entry;

		$args->{profile_name} = $name;

		$args->{code} = do {
			if( eval { $method->isa( ref {} ) } or
				UNIVERSAL::isa( $method, ref sub {} ) )
				{
				$method;
				}
			elsif( my $code = eval{ $pool->$method( $args ) } )
				{
				$code;
				}
			elsif( $@ ) { croak $@ }
			};

		push @coderefs, map { "$_" } $pool->add_to_pool( $args );
		}

	wantarray ? ( $pool, \@coderefs ) : $pool;
	}

=item $bean->pool_class

The namespace where the constraint building blocks are defined. By default
this is C<Beancounter::Pool>. If you don't like that, override this in a
subclass.

=cut

sub pool_class { 'Beancounter::Pool' }


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
