#
#	Change device name
#
package nas::chgdevicename;

use Exporter;
@ISA=qw(nasCore);

use strict;
use Errno qw(EAGAIN);

use nasCommon;
use Config::Tiny;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		if ($cgi->param('nextstage') == 1) {
			$self->stage1($cgi, $config);
			last;
		}

		my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );

		my $vars = { tabon => 'general',
                 	 frm => {  workgroup  => $smbConf->val('global', 'workgroup'),
                              devicename => `hostname`
					 		},
					};

		$self->outputTemplate('chgdevicename.tpl', $vars );
	}
}

#
#	Ensure device name is fit for purpose
#
sub stage1($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'general' };
	my $error = 0;

	# Get the device name from the form
	my $devicename = $cgi->param('devicename');

        # Convert the device name to UTF-8 for validity checking
        my $utf8devicename = Encode::decode("utf8", $devicename);

	# Check that the device name is valid
	$error = nasCommon::validateDevicename($utf8devicename);
	if ($error) {
		copyFormVars($cgi, $vars);
		nasCommon::setErrorMessage($vars, $config, 'devicename', $error);
		$self->outputTemplate('chgdevicename.tpl', $vars);
		return;
	}

	# Get the workgroup from the form
	my $workgroup = $cgi->param('workgroup');

        # Convert the workgroup UTF-8 for validity checking
        my $utf8workgroup = Encode::decode("utf8", $workgroup);

	# Check that the workgroup is valid
	$error = nasCommon::validateWorkgroup($utf8workgroup);
	if ($error) {
		copyFormVars($cgi, $vars);
		nasCommon::setErrorMessage($vars, $config, 'workgroup', $error);
		$self->outputTemplate('chgdevicename.tpl', $vars);
		return;
	}
 
	# Write network-settings - Either read existing file or create new one
	my $cfg=Config::Tiny->read( nasCommon->network_settings ) || Config::Tiny->new();
	# Create settings in the root '_' section
	$cfg->{_}->{hostname} = $devicename;
	$cfg->{_}->{workgroup} = $workgroup;
	$cfg->write( nasCommon->network_settings );

	# Remove the network started lock file
	unless (sudo("$nbin/remove.sh /var/run/network_started")) {
		$self->fatalError($config, 'f00010');
		return;
	}

	FORK: {
		if (my $pid = fork) {
			# Parent here, just return normally
		} elsif (defined $pid) {
			# Give the browser time to see the hold page
			sleep 2;

			# Invoke script to restart networking
			system('sudo '.nasCommon->nas_nbin."quickRestartNetwork.sh");

			# Make child die as it has finished its work
			exit 0;
		} elsif ($! == EAGAIN) {
			sleep 5;
			redo FORK;
		} else {
			die "Can't fork: $!\n";
		}
	}

	print $cgi->redirect( 'hold.pl' );
}

1;
