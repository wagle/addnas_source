#
#	Determines progress of firmware download and installation
#
#   (used by the AJAX calls from the web front end)
#
#	Ian Steel
#	November 2006
#
package nas::firmware_progress;

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
		if (  -e '/var/upgrade/latestfw.sh'  || system("ps -A | grep wget > /dev/null") == 0 ) {
			# Find current size of downloaded file
			#
			my @stat = stat('/var/upgrade/latestfw.sh');
			$mess = getMessage($config, 'm18009') . ' ' . $stat[7];
			last;
		}

		$mess = getMessage($config, 'm18011');

	}

	$self->outputTemplate('firmware_progress.tpl', { 
		tabon => 'general',
		head => '<META HTTP-EQUIV="Refresh" content="60;URL=/auth/firmware_progress.pl">',
		message => $mess 
	});

}

1;
