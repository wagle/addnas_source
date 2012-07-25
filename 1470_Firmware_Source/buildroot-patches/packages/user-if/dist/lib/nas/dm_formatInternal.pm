#!/usr/bin/env perl
#
# Program : dm_formatInternal.pm
# Purpose : Handler for format internal drive page
#
package nas::dm_formatInternal;

use Errno qw(EAGAIN);
use base( 'nasCore' );
use strict;
use warnings;

=pod

=head1 NAME

dm_formatInternal - Handler for format internal drive page

=head1 SYNOPSIS

new nas::dm_formatInternal->processRequest();

=head1 DESCRIPTION

=cut

use nasCommon;
use Service::Storage;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	my $error;

	# Get data from the storage
	my $storage=new Service::Storage( '/shares/internal' );
	my $type = $storage->drive_type();

        if ( -r nasCommon->nas_lock ) {
                # Process is already running.
		print $cgi->redirect( '/auth/dm_progress.pl' );
                return;
        } elsif ( $cgi->param( 'b_format' )) {
                # Change drive type button.
                $self->confirm( $cgi,$config, $storage );
                return;
        } elsif ( $cgi->param( 'b_confirm' )) {
                # Confirm button
                $self->run( $cgi ,$config );
                return;
        } elsif ( $cgi->param( 'b_cancel' )) {
                # Cancel button
                print $cgi->redirect('/auth/gensetup.pl');
                return;
        }
        
	my $frm;
    
    #get a hashref of good and replacement drives
    my $goodreplace = $storage->goodReplacementDrive($config);
    
    if ($goodreplace) {
        $frm->{replacement} = $goodreplace->{replacementPort};
    }

	$frm->{drive_type} = $type;   # raid0 or raid1

	# Display the initial page
	$self->outputTemplate('dm_formatInternal.tpl', { 
		tabon => 'driveman',
		error => $error,
		frm => $frm,
	});
}

sub confirm {
    my $self=shift;
    my $cgi=shift;
    my $config=shift;
	my $storage=shift;

	my $type = $storage->drive_type();
    my $device = $storage->goodReplacementDrive($config)->{replacementPort};
	
	return $self->fatalError($self->{config}, 'e16002') unless ($type);
	my $warning;
	if ($type eq 'raid0') {
		# Warn that all data will be destroyed
		$warning = nasCommon::getMessage( $config, 'm16032' );
	} else {
		# Warn that rebuild will take place
		$warning = nasCommon::getMessage( $config, 'm16031' );
	}
        $self->outputTemplate('dm_confirm.tpl', {
		handler => 	'/auth/dm_formatInternal.pl',
		title =>  	nasCommon::getMessage( $config, 'm16010' ),
		warning => 	$warning,
		data => 	$device,
        tabon => 	'driveman',
        });
	return 1;
}

sub run {
	my $self=shift;
	my $cgi=shift;
	my $config = shift;
	my $device=$cgi->param( 'data' );

	# Find the raid device from the chosen device
	my $storage=new Service::Storage('/shares/internal');

	# Get the good and replacement disk info
	my $driveInfo = $storage->goodReplacementDrive($config);
	if ($driveInfo) {
		my $rc=0;

		# Pick a remaining good disk to copy boot sectors from
		my $good = $driveInfo->{good};
		my $replacement = $driveInfo->{replacement};

		# Any failed devices to recover?
		if ($replacement && $good) {
			# Check for open files on shares before doing anything to disrupt sharing
			$rc=system('sudo '.nasCommon->nas_nbin."shareControl.sh check_internal");
			if ($rc==0) {
				# Create disk ops lock to serialise disk ops
				system( 'sudo '.nasCommon->nas_nbin."touch.sh ".nasCommon->nas_lock );

				# Stop file sharing
				system('sudo '.nasCommon->nas_nbin."shareControl.sh stop");

				# What's the type of the internal storage?
				my $type = $storage->drive_type();
				if ($type eq 'raid0') {
					# Delete all the internal shares
					Service::Shares->deleteAllInternal();
#					Service::nfsShares->deleteAllInternal();
				}

				FORK: {
					if (my $pid = fork) {
						# Parent here, just return normally
					} elsif (defined $pid) {
						my $md = '/dev/md';

						# Run the formatting in the child, so WebUI is available while formatting is in progress
						system('sudo '.nasCommon->nas_nbin."dm_formatInternal.sh ".join(' ',$replacement, $good, $md, $type));

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
		}

		if ($rc==0) {
			# Go to the progress page (which will automatically be displayed by this handler)
			print $cgi->redirect( '/auth/dm_progress.pl' );
		} else {
			# Mount point was probably busy or something happened.
			$self->outputTemplate('dm_busy.tpl', {
				tabon => 'driveman',
			});
		}
	} else {
		$self->warning($self->{config}, 'e16001');
	}
}


1;
