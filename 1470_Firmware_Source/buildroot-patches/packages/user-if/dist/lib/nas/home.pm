
package nas::home;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon;
sub main($$$) {

	my ($self, $cgi, $config) = @_;
        
	$self->outputTemplate('home.tpl', { tabon => 'home' } );

}

1;
