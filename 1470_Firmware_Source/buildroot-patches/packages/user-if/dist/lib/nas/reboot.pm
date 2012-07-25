
package nas::reboot;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon;

sub main($$$) {
	my ($self, $cgi, $config) = @_;
	if($cgi->param("rebooting")){
		system("reboot");
		#this page won't get loaded because the system will be down.
		$self->outputTemplate('rebooting.tpl', { tabon => 'general'});
	}
	$self->outputTemplate('reboot.tpl', { tabon => 'general' } );
}

1;
