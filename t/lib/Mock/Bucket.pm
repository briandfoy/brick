package Mock::Pool;
use base qw(Beancounter::Pool);

use Beancounter;

sub new { bless {}, $_[0] }

sub add_to_pool { return $_[1]->{code} }

sub pool_class { Beancounter->pool_class }

sub comprise {}

1;