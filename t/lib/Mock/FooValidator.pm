package Mock::FooValidator;
use base qw(Exporter);

use vars qw( @EXPORT );

@EXPORT = qw( _is_the_number_3 _is_the_letter_e );

sub _is_the_number_3
	{
	my( $pool, $hash ) = @_;

	$pool->add_to_pool( {
		description => "It's the number 3",
		args        => [ $hash ],
		fields      => [ $hash->{field} ],
		code        => sub { $_[0] == 3  or die
			{
			message => "$_[0] was not the letter 'e'",
			handler => "_is_the_letter_e",
			} },
		} );
	}
	
sub _is_the_letter_e
	{
	my( $pool, $hash ) = @_;

	$pool->add_to_pool( {
		description => "It's the letter e",
		args        => [ $hash ],
		fields      => [ $hash->{field} ],
		code        => sub { $_[0] eq 'e' or die
			{
			message => "$_[0] was not the letter 'e'",
			handler => "_is_the_letter_e",
			} },
		} );
	}

1;