
package nas::upgrade_firmware;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon;

sub main($$$) {
	
	my ($self, $cgi, $config) = @_;
	my $url = $cgi->param('url');
	my $username = $cgi->param('username');
	my $pwd = $cgi->param('pwd');
	my $downloading = $cgi->param('downloading');
	if ($downloading) {
		my $fwfile = nasCommon->FW_DOWNLOAD_FILE;
        	my $status = 0;	
        	my $target = "";
		my $fwpath = "";
		my $sda1_found = 0;
		my $other_found = 0;
		for (`cat /proc/mounts`){
			chomp;
			if (m,^/dev/,){
				my ($device, $mountpoint) = split /\s+/;
				if ($device =~ m,/dev/sda1,) {
					$target = "$mountpoint/$fwfile";
					$fwpath = $mountpoint;
					$sda1_found = 1;
				} else {
					$other_found = 1;
				}
			}
		}

		if ($sda1_found && ! $other_found) {
			sudo("$nbin/remove.sh $target");
			my $retcode = sudo("$nbin/applyupgrade.sh $target $url $fwpath");
			#check for existing download
			if (-e $target) {
				$self->outputTemplate('firmware_download_finished.tpl', { tabon => 'general', path => $target, url => $url , retcode => $retcode});
			} else {
				$self->outputTemplate('firmware_download_error.tpl',{ tabon => 'general', retcode => $retcode });
			}
		} else {
			$self->outputTemplate('firmware_device_error.tpl',{ tabon => 'general' });
		}
	} else {	

		$self->outputTemplate('upgrade_firmware.tpl', { tabon => 'general' , url => $url, username => $username, pwd => $pwd} );
	}
}

1;
