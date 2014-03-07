#!/usr/bin/env perl
#
# Program : dm_formatExternal.pm
# Purpose : Handler for drive management page
###
package nas::dm_formatExternal;

use base( 'nasCore' );
use strict;
use warnings;

=pod

=head1 NAME

nas::driveman - Page handler for drive management page

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

LEVEL is either raid0 for single large volume or 1 for raid 1

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
#use Service::nfsShares;


sub main($$$) {

	my ($self, $cgi, $config) = @_;

	my $error;
        # See if there is already a process running.

        if ( -r nasCommon->nas_lock ) {
                # Process is already running.
		print $cgi->redirect( '/auth/dm_progress.pl' );
#                $self->outputTemplate('dm_waiting.tpl', {
#                        tabon => 'general',
#                });
                return;
        } elsif ( $cgi->param( 'b_format' )) {
                # Change drive type button.
                $self->confirm( $cgi,$config, $cgi->param( 'device' ) );
                return;
        } elsif ( $cgi->param( 'b_confirm' )) {
                # Confirm button
                $self->run( $cgi );
                return;
        } elsif ( $cgi->param( 'b_cancel' )) {
                # Cancel button
	                print $cgi->redirect('/auth/gensetup.pl');
                return;
        }

	# Get the name of the external device
	my $s=new Service::Storage( '/shares/internal' );
	my $external_volumes = $s->external_volumes();
	# We are assuming that only one will be available so take the first volume. 
	my @keys = keys( %{$external_volumes} );

	my $devices = [];
	my $frm={};
	$frm->{devices} = $devices;
	foreach(@keys) {
		my $key = $_;
		if ($key) {
			my $name = $external_volumes->{$key}->{name};
			if ( defined( $name ) ) {
				push( @$devices, { id=>$key, name=>$name} );
			}
		}
	}
	$frm->{numberofdevices} = scalar( @$devices );
	# Display the initial page
	$self->outputTemplate('dm_formatExternal.tpl', { 
		tabon => 'general',
		title => nasCommon::getMessage( $config, 'm16009' ),
		warning => nasCommon::getMessage( $config, 'm16032' ),
		error => $error,
		frm => $frm,
	});
}

sub confirm {
        my $self=shift;
        my $cgi=shift;
        my $config=shift;
	my $device=shift;
	my $fstype=$cgi->param( 'fstype' );
	my $pttype=$cgi->param( 'pttype' );
        $self->outputTemplate('dm_confirm.tpl', {
		handler => '/auth/dm_formatExternal.pl',
		title => nasCommon::getMessage( $config, 'm16009' ),
		data => $device,
		fstype => $fstype,
		pttype => $pttype,
                tabon => 'general',
        });
}

sub run {
        my $self = shift;
        my $cgi = shift;
	my $device = $cgi->param('data');
	my $fstype = $cgi->param('fstype');
	my $pttype = $cgi->param('pttype');
	# See if anything is using the shares...
	# get the name so we can check if used
	my $ss = new Service::Storage('/shares/internal/');
	my $external_volumes = $ss->external_volumes();
	my $devname = $external_volumes->{$device}->{name};
	my $devname = (split(' ',$devname))[0];

	my @cmd = ("sudo", nasCommon->nas_nbin."shareControl.sh","check_external", $devname);
	my $rc = system @cmd;
	system("echo cmd @cmd rc $rc error $? msg $! > /dev/console");
	if ($rc == 0) {
		# Remove external shares
	        my $s = new Service::Storage( '/shares/internal' );
	        my $external_volumes = $s->external_volumes();

		foreach my $part (keys %{$external_volumes->{$device}->{partitions}}) {
			my $name = $external_volumes->{$device}->{partitions}->{$part}->{name};
			Service::Shares->deleteAllExternalFromDev($name);
		}

		# Display the initial page
		system( 'sudo '.nasCommon->nas_nbin."touch.sh ".nasCommon->nas_lock );
		system( 'sudo '.nasCommon->nas_nbin."dm_formatExternal.sh ".$device." ".$fstype." ".$pttype." &" );
		print $cgi->redirect('/auth/dm_progress.pl');
	} else {
		# Mount point was probably busy or something happened.
		$self->outputTemplate('dm_busy.tpl', {
			tabon => 'general',
		});
		return;
	}
}


1;
