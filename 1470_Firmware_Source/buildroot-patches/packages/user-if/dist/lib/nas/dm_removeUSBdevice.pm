#!/usr/bin/env perl
#
# Program : driveman.pm
# Purpose : Handler for drive management page
#
package nas::dm_removeUSBdevice;

use base( 'nasCore' );
use strict;
use warnings;

=pod

=head1 NAME

nas::driveman - Page handler for drive management page

=head1 SYNOPSIS

new nas::driveman->processRequest();

=head1 DESCRIPTION

=cut

use nasCommon;
use Service::Storage;
use Service::Shares;


# This will remove all the external storage 
sub main($$$) {
  my ($self, $cgi, $config) = @_;
  my $error;
  # See if there is already a process running.

  if ( -r nasCommon->nas_lock ) {
    # Process is already running.
    print $cgi->redirect( '/auth/dm_progress.pl' );
  } else {
    if ($cgi->param( 'dofunc' ) eq "remove") {
      my $remdevice = '/dev/'.$cgi->param( 'device' );
      my $frm = {};
      $frm->{showform} = 0;
      my $ss = new Service::Storage( '/shares/internal' );
      my $external_volumes = $ss->external_volumes();
      my $devname = $external_volumes->{$remdevice}->{name};
      my $devname = (split(' ',$devname))[0];
      system("echo remdevice $remdevice devname $devname > /dev/console");

      # Abort if the device is busy
      my $rc = system( 'sudo '.nasCommon->nas_nbin."shareControl.sh check_external $devname" );
      return $self->busy_error if ($rc != 0);
      # Deactivate External Shares on Device
      Service::Shares->disableExternalPartition($devname);
      $rc ||= system( 'sudo '.nasCommon->nas_nbin."dm_removeUSBdevice.sh ".$remdevice );
      if ($rc == 0) {
	$frm->{devicename} = $devname . " (" . $remdevice . ")";
	$self->outputTemplate('dm_removeUSBdevice.tpl', { 
          tabon => 'general',
          title => nasCommon::getMessage( $config, 'm16009' ),
	  error => $error,
	  frm => $frm,
	});
      } else {
	system('sudo echo 6 >> /root/test');
	# Check the device was unmounted properly
	return $self->busy_error;
      }
    } else {
      # Get the name of the external device
      my $devices = [];
      my $frm = {};
      $frm->{devices} = $devices;

      my $s = new Service::Storage( '/shares/external' );
      my $external_volumes = $s->external_volumes();

      # get a list of external drives that can be removed from the entries
      # in /var/run/block/
      my $fd = new IO::File( "ls /var/run/block|" );
      while ( <$fd> ) {
	chomp;
	my $key = '/dev/' . $_;

	# Get the device name from the devices structure using the device
	# node
	if ($key) {
	  my $name = $external_volumes->{$key}->{name};
	  if ( defined( $name ) ) {
	    my $counterr = `grep -c -i "$name" /proc/mounts`;
	    if ($counterr != 0) {
	      push( @$devices, { id=>$_, name => $name} );
	    }
	  }
	}
      }
      undef $fd;

      # set the number of devices
      $frm->{numberofdevices} = scalar( @$devices ) ;
      $frm->{showform} = 1;
      # If we found devices then remove them or redirect to the drive 
      # management page
      if (scalar( @$devices ) > 0) {
	# Display the initial page
	$self->outputTemplate('dm_removeUSBdevice.tpl', { 
	  tabon => 'general',
	  title => nasCommon::getMessage( $config, 'm16009' ),
	  error => $error,
	  frm => $frm,
	});
      } else {
	print $cgi->redirect('/auth/gensetup.pl')
      }
    }
  }
  close (LOG);
}

sub busy_error {
  my $self=shift;
  # Something extraordinary happened that prevented the unmount
  $self->outputTemplate('dm_busy.tpl', {
    tabon => 'general',
  });
  return;
}

1;
