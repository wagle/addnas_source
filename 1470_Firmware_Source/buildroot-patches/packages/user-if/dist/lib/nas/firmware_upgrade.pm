#
#	Checks for a firmware upgrade on the 'net, and optionally downloads
#	and installs.
#
#	Ian Steel
#	November 2006
#
package nas::firmware_upgrade;

use Errno qw(EAGAIN);

use Exporter;
@ISA = qw(nasCore);
@EXPORT = qw(getAndApply);

use strict;

use nasCommon;
use Service::Storage;
use Service::RAIDStatus;

sub main($$$) {

	my ( $self, $cgi, $config ) = @_;

	if ( $config->val( 'general', 'system_type' ) !~ /1nc/i ) {

		# It's not a 1nc, so check that the status is ok before continuing
		my $status = Service::Storage->driveStatusCode($config);
		if ( $status ne Service::RAIDStatus::OK ) {
			$self->outputTemplate( 'firmware_faulty.tpl',
				{ tabon => 'general', } );
			return;
		}
	}

	# Check that no shares are in use
	if (    # Short circuit if internal fails. external is less likely to happen
		(
			my $int_err = system(
				'sudo ' . nasCommon->nas_nbin . "shareControl.sh check_internal"
			)
		)
		|| (
			my $ext_err = system(
				'sudo ' . nasCommon->nas_nbin . "shareControl.sh check_external"
			)
		)
	  )
	{
		my $exit_value = $?;
		debug "int error:" . $int_err
		  . " ext_err:"
		  . $ext_err
		  . "error value "
		  . $exit_value;

		# Mount point was probably busy or something happened.
		$self->outputTemplate( 'firmware_busy.tpl', { tabon => 'general', } );
		return;
	}

	my $vars = { tabon => 'general' };

	# no need to lock here- lock handled in nasMaster.
	
	if ( $cgi->param('submit') ) {
		$self->getAndApply( $cgi, $config );
		return;
	}
	open( DEF, "</etc/default-settings" )
	  or die "Cannot open default-settings: $!\n";
	my ( $dev, $dev_mode ) = ();
	while (<DEF>) {
		chomp;
		if (/developer_mode/im) {
			( $dev, $dev_mode ) = split /=/;
			next;
		}
	}
	close DEF;
	open( DEF, "</var/oxsemi/network-settings" )
	  or die "Cannot open network-settings: $!\n";
	my ( $sys, $sys_type ) = ();
	while (<DEF>) {
		chomp;
		if (/system_type/im) {
			( $sys, $sys_type ) = split /=/;
			next;
		}
	}
	close DEF;
	if ( ( $dev_mode =~ /yes/i ) && ( !$cgi->param('fwserver') ) ) {
		$self->outputTemplate( 'firmware_mode.tpl', $vars );
		return SUCCESS;
	}
	my $fws = "oxsemi.com";
	if ( $cgi->param('fwserver') ) {
		$fws = $cgi->param('fwserver') . "/list.asp";
	}
	$self->checkForUpgrade( $cgi, $config, $fws, $sys_type );
}

#
#	Check for firmware upgrade being available
#
sub checkForUpgrade {

	my ( $self, $cgi, $config, $fws, $sys_type ) = @_;

	my $vars  = { tabon => 'general' };
	my $error = 0;

	open( FWV, "</var/lib/current-version" )
	  || return $self->fatalError( $config, 'f00029' );
	my $fwVersion = <FWV>;
	chomp $fwVersion;
	close FWV;

	sudo(
"$nbin/wget.sh /var/upgrade/fwv.tmp http://${fws}?type=${sys_type}+fw=${fwVersion}"
	);

	unless ( -r '/var/upgrade/fwv.tmp' ) {
		$self->fatalError( $config, 'f00030' );
		return FAILURE;
	}

	my $tmp = $/;
	undef $/;
	open( FWV, "</var/upgrade/fwv.tmp" )
	  || return $self->fatalError( $config, 'e18003' );
	my $fwv = <FWV>;
	close FWV || die "failed to close";
	$/ = $tmp;

	# Is there a later version available?
	#
	debug( "DAYWAN: " . $fwv );
	if ( $fwv =~ /no upgrade available/im ) {
		$self->outputTemplate( 'firmware_upd_notavail.tpl', $vars );
		return SUCCESS;
	}

	# Extract the url which points to the latest firmware
	#

	if ( $fwv =~ /.*href="([^"]+)"/is ) {
		$vars->{frm}->{url} = $1;
		$self->outputTemplate( 'firmware_upd_avail.tpl', $vars );
		debug( "DAYWAN: " . $1 );
	}
	else {
		$self->outputTemplate( 'firmware_upd_notavail.tpl', $vars );
	}

	return SUCCESS;
}
# this is a shared function allowing calling functions to download and install.
# it is local and used by home_update.pm for final factory update.
sub getAndApply($$$) {

	my ( $self, $cgi, $config ) = @_;

	my $vars  = { tabon => 'general' };
	my $error = 0;

	my $rc = system( 'sudo ' . nasCommon->nas_nbin . "shareControl.sh stop" );
	if ( $rc == 0 ) {

		# Submit to the background shell script to download and apply new
		#	firmware.
		# give myself access to lock files and remove.
		#
		my $url = $cgi->param('url');

		sudo("$nbin/chmod.sh 0777 /var/upgrade");
		sudo("$nbin/chmod.sh 0666 /var/upgrade/latestfw.sh");
		unlink '/var/upgrade/latestfw.sh';
		sudo("$nbin/chmod.sh 0666 /var/upgrade/fwdownloaded");
		unlink '/var/upgrade/fwdownloaded';
		sudo("$nbin/chmod.sh 0666 /var/upgrade/fwinstalled");
		unlink '/var/upgrade/fwinstalled';
	  FORK: {

			if ( my $pid = fork ) {
				sleep 1;
				print $cgi->redirect('/auth/firmware_progress.pl');
				return SUCCESS;
			}
			elsif ( defined $pid ) {

				# child process does this bit.
				sudo( "$nbin/getupgrade.sh " . $url );
				CheckUpgradeFile();    
				exit;
			}
			elsif ( $! = EAGAIN ) {
				sleep 5;
				redo FORK;
			}
			else {
				debug "can\'t fork";
				return FAILURE;
			}
		}
	}
	else {

		# Mount point was probably busy or something happened.
		$self->outputTemplate( 'firmware_busy.tpl', { tabon => 'general', } );
		return;
	}

	return SUCCESS;

}

sub UseUpgradeFile ($$$) {
	my $cgi    = shift;
	my $status = undef;

	FORK: {
		if ( my $pid = fork ) {
			open FLAG, '>/var/upgrade/fwdownloaded';
			close FLAG;
			print $cgi->redirect('/auth/firmware_progress.pl');
			$status = SUCCESS;
		}
		elsif ( defined $pid ) {
			CheckUpgradeFile();
			# child process does this!
			exit;

		}
		elsif ( $! = EAGAIN ) {
			sleep 5;
			redo FORK;
		}
		else {
			debug "can\'t fork";
			$status = FAILURE;
		}
	}

	return ($status);
}

sub CheckUpgradeFile($$$) {
	if ( sudo("$nbin/checkupgrade.sh") == SUCCESS ) {
		open FLAG, '>/var/upgrade/md5pass';
		close FLAG;
		sudo("$nbin/applyupgrade.sh");
	}
	else {
		opendir UPDIR, "/var/upgrade/.";
		my @dir_list = readdir UPDIR;
		foreach my $ifile (@dir_list) {
			my $ofile = "/var/upgrade/" . $ifile;
			if ( -f $ofile ) {
				sudo( "$nbin/remove.sh " . $ofile );
			}
		}
		sudo( "$nbin/remove.sh /tmp/active_upgrade");
		open FLAG, '>/var/upgrade/md5fail';
		close FLAG;
	}
}    

1;
