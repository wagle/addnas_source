#
# 	Update the firmware directly from a given URL - in the 
#       factory.
#
#	Access the web page using wget using this command
# wget --no-proxy 'http://10.0.0.21/home_update.pl?url="http://10.0.0.20/download.wdg"'
# NB: the quotes are important and can be done using MS IE or Firefox but putting
#     the page address in the navigation bar.
#
#
package nas::home_update;

use Errno qw(EAGAIN);

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;
use nas::firmware_upgrade qw(getAndApply);

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'general' };
	if ($cgi->param('url')) {
		$self->nas::firmware_upgrade::getAndApply($cgi, $config);
		return;
	}
}

1;
