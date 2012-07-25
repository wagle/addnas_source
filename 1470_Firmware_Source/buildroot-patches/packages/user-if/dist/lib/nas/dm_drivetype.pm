#!/usr/bin/env perl
#
# Program : dm_drivetype.pm
# Purpose : Handler for drive type page
#
package nas::dm_drivetype;

use Errno qw(EAGAIN);
use base( 'nasCore' );
use strict;
use warnings;

=pod

=head1 NAME

nas::dm_drivetype - Page handler for drive management page

=head1 SYNOPSIS

new nas::driveman->processRequest();

=head1 DESCRIPTION


=head2 Form Inputs

=over 

=item drive_type - radio button (raid0,raid1)

=item change_drive_type - submit button name

=item format_internal - submit button name

=item format_external - submit button name

=item restore_raid - submit button name

=item nextstage - hidden

=head2 Process

=head3 dm_setDriveType.sh notes

=head4 Usage: dm_setDriveType.sh <LEVEL>

LEVEL is either raid0 for single large volume or 1 for raid1

=head4 Partitions

=over

=item md1 -> rootfs

=item md2 -> swap

=item md3 -> /var

=item md4 -> /shares/internal

=back

=cut

use nasCommon;
use Service::Storage;
use Service::Shares;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	# See if there is already a drive change running.
	if ( -r nasCommon->nas_lock ) {
		# Process is already running.
		print $cgi->redirect( '/auth/dm_progress.pl' );
		return;
	} elsif ( $cgi->param( 'b_change_drive_type' )) {
		# Change drive type button.
		$self->confirm( $cgi,$config,$cgi->param('drive_type') );
		return;
	} elsif ( $cgi->param( 'b_confirm' )) {
		# Confirm button
		$self->run( $cgi, $config );
		return;
	} elsif ( $cgi->param( 'b_cancel' )) {
		# Cancel button
		print $cgi->redirect('/auth/gensetup.pl');
		return;
	}

	# Collect data to display the initial page
	my $drive_type='raid0';
	my $s = new Service::Storage( nasCommon->storage_volume );
	if ($s) {
		$drive_type=$s->drive_type();	# raid0 or raid1	
	}

	$self->outputTemplate('dm_drivetype.tpl', { 
		tabon => 'driveman',
		frm => { drive_type => $drive_type },
	});
}

sub confirm {
	my $self=shift;
	my $cgi=shift;
	my $config=shift;
	my $drive_type=shift;
	$self->outputTemplate('dm_confirm.tpl', { 
		handler => '/auth/dm_drivetype.pl',
		title => getMessage( $config, 'm16008' ),
		warning => getMessage( $config, 'm16032' ),
		tabon => 'driveman',
		data => $drive_type,
	});
}

sub run {
	my $self=shift;
	my $cgi=shift;
	my $config=shift;
    my $rc = 0;

    # only procede if there ore two good disks, (synchronising is OK)
	my $storage=new Service::Storage('/shares/internal');
    my $driveStatus = $storage->driveStatusCode( $config );
    if (($driveStatus != Service::RAIDStatus::SYNCHRONISING) &&
        ($driveStatus != Service::RAIDStatus::OK)) {
        $rc |= 1;
    }
    
	# Check for open files on shares before doing anything to disrupt sharing
	$rc|=system('sudo '.nasCommon->nas_nbin."shareControl.sh check_internal");
	if ($rc==0) {
		# Create disk ops lock to serialise disk ops
		system('sudo '.nasCommon->nas_nbin."touch.sh ".nasCommon->nas_lock);

		# Stop file sharing
		system('sudo '.nasCommon->nas_nbin."shareControl.sh stop");

		# Delete all the internal shares
		Service::Shares->deleteAllInternal();
#		Service::nfsShares->deleteAllInternal();

		FORK: {
			if (my $pid = fork) {
				# Parent here, just return normally
			} elsif (defined $pid) {
				my $s=new Service::Storage( nasCommon->storage_volume );
				my $md=$s->data_volume();
				my @dv=$s->rawdata_volumes();
				my $sda=shift @dv;
				my $sdb=shift @dv;
				my $type = $cgi->param('data'); # The drive type from the confirm page

				# Run the setDriveType process to change & format the drive
				for ($type) {
					(/raid0/) && (system('sudo '.nasCommon->nas_nbin."dm_setDriveType.sh 0 $md $sda $sdb"), last); 
					(/raid1/) && (system('sudo '.nasCommon->nas_nbin."dm_setDriveType.sh 1 $md $sda $sdb"), last); 
				}

				# Recreate the public share directory. Assumes umask 0022 and SUID/GUID inheritance
				Service::Shares->createDefault();

				# Start file sharing
				system('sudo '.nasCommon->nas_nbin."shareControl.sh start");

				# Remove disk ops lock
				system('sudo '.nasCommon->nas_nbin."remove.sh /tmp/dm_progress");

				# Make child die as it has finished its work
				exit 0;
			} elsif ($! == EAGAIN) {
				sleep 5;
				redo FORK;
			} else {
				die "Can't fork: $!\n";
			}
		}
	}

	if ($rc==0) {
		# Go to the progress page (which will automatically be displayed by this handler)
		print $cgi->redirect('/auth/dm_progress.pl');
	} else {
		# Mount point was probably busy or something happened.
		$self->outputTemplate('dm_busy.tpl', { 
			tabon => 'driveman',
		});
	}
}

1;
