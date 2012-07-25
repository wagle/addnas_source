#
#	Determines progress of firmware download and installation
#
#
package nas::home_status;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;
	my $mess = undef;

	{
		if ( -r '/var/upgrade/fwinstalled' ) {
			$mess = getMessage($config, 'm18007');
			last;
		}

		if ( -r '/var/upgrade/fwdownloaded' ) {
			$mess = getMessage($config, 'm18008');
			last;
		}
		if (  -r 'var/upgrade/latestfw.sh'  || system("ps -A | grep wget > /dev/null") == 0 ) {
			# Find current size of downloaded file
			#
			my @stat = stat('/var/upgrade/latestfw.sh');
			$mess = getMessage($config, 'm18009') . ' ' . $stat[7];
			last;
		}

		$mess = getMessage($config, 'm18011');

	}

	$self->outputSubTemplate('firmware_progress.tpl', 
				{ message => $mess } );

}

1;
