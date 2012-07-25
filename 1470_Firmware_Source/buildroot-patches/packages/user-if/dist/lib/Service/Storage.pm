#!/usr/bin/env perl
# Class   : Service::Storage.pm
# Purpose : Access for storage stats. 
# Author  : B.James
# Date    : $Date: $
# Version : $Revision :$
#
use strict;

=pod

=head1 DESCRIPTION

Service::Storage - Access Storage information

=head1 SYNOPSIS

my $eth = new Service::Storage();

=head1 DESCRIPTION

This class provides an interface to various OS commands such as
df . It is used to gather information and present it as an 
OO accessor interface.

=cut

package Service::Storage;

use SysCmd;
use IO::File;
use Service::RAIDStatus;

sub new {
	my $class=shift;
	my $this={};
	bless $this, $class;

	$this->{data}={};

	# Specify the mountpoint from which we collect stats
	$this->{data}->{mountpoint} = shift || die( "Please specify a mountpoint." );
	# Fetch the status

	# Collect data if the last timestamp was more than STALETIME seconds ago
	$this->collect();

	return $this;
}


# INFORMATION methods

sub collect {
	# Collect data from various sources and update the object
	my $this=shift;
	my $fd = new IO::File( SysCmd->df ." -k 2>&1|" );
	while (<$fd>) {
		chomp;
		#print( "df:$_\n" );
		my ($fs, $total, $used, $available, $pc_used, $mountpoint) = split(/\s+/,$_);
		next unless $mountpoint =~/^$this->{data}->{mountpoint}/;
		$this->{data}->{fs}=$fs;
		$this->{data}->{total}+=$total;
		$this->{data}->{used}+=$used;
		$this->{data}->{available}+=$available;
	}
	undef $fd;

	# Collect a list of available disks
	my $fd = new IO::File( '/proc/partitions' );
	while( <$fd> ) {
		chomp;
		my ($major,$minor,$blocks,$name) = split(/\s+/,$_);
		$this->{data}->{disks}->{$name}=$blocks;
	}
	undef $fd;

	# Clean up some of the data
	$this->{data}->{pc_used}=~s/[^\d.]//g;	# Remove any non numeric

	$this->{data}->{timestamp}=time;
	return 1;
}

sub fs {
	my $this=shift;
	return $this->{data}->{fs};
}
sub total {
	my $this=shift;
	return $this->{data}->{total};
}
sub used {
	my $this=shift;
	return $this->{data}->{used};
}
sub available {
	my $this=shift;
	return $this->{data}->{available};
}
sub pc_used {
	my $this=shift;
	my $used;
	return 0 if ($this->used() < 1);
	return 100 if ($this->used() >= $this->total);	# !
	if ( $this->used && $this->total ) {
		$used = sprintf( "%d",($this->used / $this->total) * 100 );
	}
	return $used;
}
sub pc_free {
	my $this=shift;
	my $free;
	return 0 if ($this->available() < 1);
	return 100 if ($this->available() >= $this->total);	# !
	if ( $this->available && $this->total ) {
		$free = sprintf( "%d",($this->available / $this->total) * 100 );
	}
	return $free;
}

# Drive Status Methods

sub data_volume_available {
	# Returns the volume name (/shares/internal) if the device is currently mounted
	my $this=shift;
	my $volume;
        my $fd = new IO::File( '/bin/mount|' );
        while( <$fd> ) {
                chomp;
                (/^([\/\w\d]+) on \/shares\/internal/) && do {
			return $1 ;
		};
	}
	return;
}

sub data_volume {
	# It's always md4, so don't muck about trying to work this out from the
	# running system
	return '\/dev\/md4';
}

sub drive_type {
	# Returns either raid0 or raid1 for the current volume
	my $this=shift;
	my $data_volume=$this->data_volume();
	my $fd = new IO::File( 'sudo '.SysCmd->mdadm.' --misc --query '.$data_volume."|" );
	while (<$fd>) {
		chomp;
		my ($device, $size, $type, $devices)=split(/\s+/,$_);
		return $type if ($type =~ /raid1|raid0/);
	}
    undef $fd;
    
    # couldn't get the raid type from an active RAID array, to try the 
    # mdadm.conf file
    my $fd = new IO::File( nasCommon->mdadm_conf );
    my @lines = grep( /$data_volume/, <$fd> );
    foreach my $line ( @lines ) {
        if ( $line =~ /raid0/ ){
            return 'raid0';
        } elsif ( $line =~ /raid1/ ){
            return 'raid1';
        }
    }
    undef $fd;
    
	return;
}

sub rawdata_volumes {
	# Returns the device nodes that comprise the collection of
	# raw data volumes (not raided).
	# [ '/dev/sda4','/dev/sdb4' ]
	my $this=shift;
	my @volumes;
	
	my $data_volume=$this->data_volume();
	($data_volume=~/\w(\d+)$/) && do {
		my $part=$1;
		push( @volumes, '/dev/sda'.$part );
		push( @volumes, '/dev/sdb'.$part );
	};

	return @volumes;
}

# CLASS Methods

sub all_devices {
	# Returns a list of all available devices.
	# fdisk output:
	# Disk /dev/sda: 400.0 GB, 400088457216 bytes
	# 255 heads, 63 sectors/track, 48641 cylinders
	# Units = cylinders of 16065 * 512 = 8225280 bytes
	#
	#    Device Boot    Start       End    Blocks   Id  System
	#    /dev/sda1               2         124      987997+  83  Linux
	#    /dev/sda2             125         186      498015   82  Linux swap
	#    /dev/sda3             187       19457   154794307+   5  Extended
	#    /dev/sda5             187       48641   389214756   83  Linux
	#
	my $class=shift;
	my $fd = new IO::File( 'sudo '.nasCommon->nas_nbin.'/fdisk.sh -l|' );
	my @devices;
	while (<$fd>) {
		chomp;
		(/\s*(\/dev\/[\w\/]+\d+)/) && do {
			push @devices, $1;
		};
	}

	return @devices;
}

sub get_vendor_and_model {
	my $device = shift;
	$device =~ s,^/dev/,,;
	my $vendor = `cat /sys/block/$device/device/vendor`;
        my $model = `cat /sys/block/$device/device/model`;
	return "$vendor $model";
}

sub external_volumes {
	# Returns a hashref with details of external volumes.
	# TODO: Refactor. 
	# If they are mounted, then name information will be available.
	# $hashref = 	{ '/dev/sdc' => 	{
	#			name => 'LEXAR_JUMPDRIVE',
	#			partitions => {
	#				'dev/sdc1' => { 
	#					name => 'Partition-1', 
	#					type => 'msdos',
	#				}
	#				'dev/sdc2' => { 
	#					name => 'Partition-2', 
	#					type => 'ext3fs',
	#				}
	#			}
	#		}
	#	}
	my $class=shift;
	my $data={};
	my %ignore;	# A list of devices we will ignore

	# Use mdstat to build an ignore list of mounted raid volumes
	# This is so we ignore all the md1,2,3,4 and root devices.
	my $fd = new IO::File( '/proc/mdstat' );
	while (<$fd>) {
		chomp;
		my ($vol,$colon,$state,$raid,$disk1,$disk2)=split(/\s+/,$_);
		if ( $state eq 'active' ) {
			my $device="/dev/".$vol;
			# Ignore disk (/dev/md4)
			$ignore{$device}++;
			# Ignore device (/dev/md)
			$device=~s/\d//g;
			$ignore{$device}++;
		
			# Ignore each constituent disk
			foreach my $disk ($disk1,$disk2) {
				# Ignore the constituent disks
				next unless $disk;
				$disk=~s/\[.*$//;
				# Ignore disk (/dev/sda4)
				$ignore{'/dev/'.$disk}++;
				# Ignore device (/dev/sda)
				$disk=~s/\d//g;
				$ignore{'/dev/'.$disk}++;
			}
		}
	}
	undef $fd;
#	use Data::Dumper;
#	print STDERR "Ignore 1 -".Dumper( \%ignore );


	# Grep the mount command to find mounted external devices
	my $fd = new IO::File( '/proc/mounts' );
	while( <$fd> ) {
		chomp;
		my ($device, $mountpoint, $type)= split(/\s/);
		($device=~/^(\/dev\/\w+\d*)/) && do {
			# Ignore devices that are mounted in some way
			my $part=$device;
			# (/dev/sdb1)
			$ignore{$device}++;
			# Ignore device (/dev/sdb)
			$device=~s/\d//g;
			$ignore{$device}++;
			if ($mountpoint =~ m,/shares/external/([^/]+)$,) {
				my $partitionName = $1;

				$data->{$device}->{name} =  $device . " " . get_vendor_and_model($device);
				$data->{$device}->{partitions}->{$part}->{name}=$partitionName;
				$data->{$device}->{partitions}->{$part}->{type}=$type;
			}
		}
	}
	undef $fd;
#	print STDERR "Ignore 2 -".Dumper( \%ignore );

	# Make sure we catch all devices that are unmountable in /var/run/block
	my $fd=new IO::File( "ls /var/run/block|" );
	while( <$fd> ) {
		chomp;
		my $device='/dev/'.$_;
		($device && (!$ignore{$device}++)) && do {
			$data->{$device}->{name} = $device . " " . get_vendor_and_model($device);
			$data->{$device}->{partitions}->{$device}->{name}=$device;
			$data->{$device}->{partitions}->{$device}->{type}=$device;
		};
	}
	undef $fd;
#	print STDERR "Ignore 3 -".Dumper( \%ignore );

	# Use fdisk to find any leftover disks that are available but not mounted
	my $fd=new IO::File( "sudo ".nasCommon->nas_nbin."fdisk.sh -l|" );
	while( <$fd> ) {
		chomp;
		( /^Disk ([^:]+):/ ) && do {
			my $device = $1;
			($device && (!$ignore{$device}++)) && do {
				$data->{$device}->{name} = $device . " " . get_vendor_and_model($device);
				$data->{$device}->{partitions}->{$device}->{name}=$device;
				$data->{$device}->{partitions}->{$device}->{type}=$device;
			};
		};
	}
	undef $fd;
#	print STDERR "found -".Dumper( $data );

	return $data;
}


sub failed_disks {
	# Returns a hashref of devices '/dev/sdc' with their raid devices '/dev/md' which are marked as failed.
	# Returns undef if no failures were detected
	my $class=shift;
	my $disks;

	my $fs=Config::Tiny->read( nasCommon->failed_drives ) || Config::Tiny->new();
	foreach my $raidDevice ( keys %{$fs->{_}} ) {
		my $disk = $fs->{_}->{$raidDevice};
		$raidDevice=~s/\d+$//;
		$disk=~s/\d+$//;
		$disks->{$disk}=$raidDevice;
	}

	return $disks;
}

### FOLLOWING ARE UNUSED AT PRESENT

sub volume_status {
	# Returns the raid status for a given volume;
	# This will consist of an array containing volumes that comprise the	
	# raid0 or raid1 array and their status;
	# Status is U-Up, F-Fail, R-Replaced
	# eg.
	# $status={ '/dev/md3' =>  [[ '/dev/sda3','U' ], [ '/dev/sdb3', 'F' ]] };
	# $status={ '/dev/md3' =>  [[ '/dev/sda3','U' ], [ '/dev/sdb3', 'R' ]] };
	my $this=shift;
	my $volume = shift || return;
	$volume=~s/([^\/]+)$/$1/;	# Remove any preceding path
	my $status;
	my $fd = new IO::File( '/proc/mdstat' );
	while (<$fd>) {
		chomp;
		my ($vol,$colon,$state,$raid,$disk1,$disk2)=split(/\s+/,$_);
		if ($vol eq $volume) {
			push( @{$status->{$vol}}, $disk1);
			push( @{$status->{$vol}}, $disk2);
		}
	}

	return $status;
}

# returns the device-node name of the good drive. It should be safe to assume 
# that if present and larger, then the other of sda or sdb is the replacement 
sub goodReplacementDrive {
	my $this=shift;
    my ($config) = @_; 
    my $result;
    
    # Identify the good disk based on its still being used by RAID for partition
    # md1
    # run mdadm to query the drive state
    foreach my $raiddevice ( '/dev/md1', '/dev/md2', '/dev/md3' ) {
        # run mdadm to query the drive state
        open( CommandOutput, "sudo ".SysCmd->mdadm." --detail $raiddevice|");

        # find the good drive, there should only be one, otherwise this code 
        # is meaningless.
        my @workingDrives = grep ( /active sync/, <CommandOutput> ) ;
        if (scalar( @workingDrives ) == 1) {
            $workingDrives[0] =~ /(\/dev\/sd.)/;
            my $good = $1;
            
            # need both sda and sdb to be on internal SATA ports
            if((! -e '/sys/devices/platform/oxnassata.0/host0/target0:0:0' ) ||
                (! -e '/sys/devices/platform/oxnassata.0/host1/target1:0:0' )) {
                return undef;
            }

            # based on the good drive, select a candidate for a replacement
            my $replacement;
            my $replacementDisk;
            my $replacementPort;
            my $goodDisk;
            if ( $good eq '/dev/sda' ) {
                $replacement = '/dev/sdb';
                $replacementDisk = '/sys/block/sdb';
                $replacementPort = nasCommon::getMessage($config, 'm20008');
                $goodDisk = '/sys/block/sda';
            } elsif ( $good eq '/dev/sdb' ) {
                $replacement = '/dev/sda';
                $replacementDisk = '/sys/block/sda';
                $replacementPort = nasCommon::getMessage($config, 'm20009');
                $goodDisk = '/sys/block/sdb';
            }
            
            # check the replacement can be read system will return non zero on
            # failure
#            if ( system('sudo dd of=/dev/null count=1b if='.$replacement) ) {
#                # this disk cannot be read,
#                return undef;
#            }
            
            # check the replacement is big enough
            my $goodDiskSize = `cat $goodDisk/size`;
            my $replacementDiskSize = `cat $replacementDisk/size`;
            if ($replacementDiskSize >= $goodDiskSize) {
                $result = {
                    good => $good,
                    replacement => $replacement,
                    replacementPort => $replacementPort
                };
                return \%$result;
            }
        }
        close( CommandOutput );
    }    
    
    return undef;
}



# Returns text describing the internal drive status.
#
# NOTE: Drive naming follows the text printed on the motherboard rather
# than Linux device node names
#
sub driveStatusCode {
	# Returns a code describing the state of the drives.
	# Codes:
	# ok		Drives are ok
	# ok_sync	Raid partitions are resyncing, but basically OK
	# faulty_b	Drive B is faulty
	# faulty_a	drive A is faulty
	# faulty	Something undetermined is faulty
	# unknown	Cannot determine state
	# 
	my $this=shift;
	my $config = shift;

	if (ref($config) &&  $config->val('general','system_type') =~ /1nc/i ) {
		# If running on a 1nc system, always return ok
		return Service::RAIDStatus::OK;
	}

	my $rc = Service::RAIDStatus::UNKNOWN;
    foreach my $raiddevice ( '/dev/md1', '/dev/md2', '/dev/md3', '/dev/md4' ) {
        # run mdadm to query the drive state
        open( CommandOutput, "sudo ".SysCmd->mdadm." --detail $raiddevice|");
        my @lines = <CommandOutput>;
        if (grep( /State : clean, degraded\n/, @lines)) {
            # "clean, degraded" is a sign that a drive has failed in the RAID 
            # set has failed, but it is also shown when the drive is waiting to
            # rebuild.
            if ((grep /spare rebuilding/, @lines)) {
                # if "spare rebuilding" is found, then it hasn't failed,
                # it is in the queue to rebuild rebuild.
                $rc->upgradeStatus( Service::RAIDStatus::SYNCHRONISING );
            }
            
            # if the disk has just failed, we can use the text in mdadm --query
            elsif ((grep /faulty spare   \/dev\/sda/, @lines)) {
                $rc->upgradeStatus( Service::RAIDStatus::FAULTYB );
            } elsif ((grep /faulty spare   \/dev\/sdb/, @lines)) {
                $rc->upgradeStatus( Service::RAIDStatus::FAULTYA );
            }
            
            # if not, have to work out which port the only disk is attached
            # to
            elsif (! -e '/sys/devices/platform/oxnassata.0/host1/target1:0:0' ){
                $rc->upgradeStatus( Service::RAIDStatus::FAULTYA );
            } elsif (! -e '/sys/devices/platform/oxnassata.0/host0/target0:0:0' ) {
                $rc->upgradeStatus( Service::RAIDStatus::FAULTYB );
            } else {
                # try and work out the failed drive by process of deduction
                my @workingDrives = grep ( /active sync/, @lines ) ;
                if (scalar( @workingDrives ) == 1) {
                    $workingDrives[0] =~ /(\/dev\/sd.)/;
                    my $good = $1;
        
                    if ( $good eq '/dev/sda' ) {
                        $rc->upgradeStatus( Service::RAIDStatus::FAULTYA );
                    } elsif ( $good eq '/dev/sdb' ) {
                        $rc->upgradeStatus( Service::RAIDStatus::FAULTYB );
                    } else {
                        # can't work out which disk has failed
                        $rc->upgradeStatus( Service::RAIDStatus::FAULTY );
                    }
                } else {
                    # can't work out which disk has failed
                    $rc->upgradeStatus( Service::RAIDStatus::FAULTY );
                }
            }
        }

        if ((grep( /State : clean, degraded, recovering\n/, @lines)) ||
            (grep( /State : clean, resyncing\n/, @lines)) ||
            (grep( /State : active, resyncing\n/, @lines))) {
            # rebuilding
            $rc->upgradeStatus( Service::RAIDStatus::SYNCHRONISING );
        }

        # clean
        if (grep( /State : clean\n/, @lines)) {
            $rc->upgradeStatus( Service::RAIDStatus::OK );
        }
        close( CommandOutput );
    }
    
    # if the disk is broken, yet present, check the serial numbers, it may be 
    # a new disk
    if (($rc eq Service::RAIDStatus::FAULTYA) &&
        (-e '/sys/devices/platform/oxnassata.0/host1/target1:0:0' ) ) {
    
        # Get a serial number of the disk (sdb is disk A)
        open(CommandOutput, 'sudo /sbin/hdparm -I /dev/sdb|grep "Serial Number" |');
        my @DiskSerialNumbers = <CommandOutput>;
        close( CommandOutput );
        if (scalar(@DiskSerialNumbers) == 1) {
            my $fd = new IO::File(nasCommon->serial_numbers,'r');
            my @KnownSN = <$fd>;
            # If it isn't in the list of known disks, this is a new disk
            if(!grep(/$DiskSerialNumbers[0]/, @KnownSN )) {
                $rc = Service::RAIDStatus::NEWDRIVEA
            }
        }
    }
    if (($rc eq Service::RAIDStatus::FAULTYB) &&
        (-e '/sys/devices/platform/oxnassata.0/host0/target0:0:0' ) ) {
    
        # Get a serial number of the disk (sdb is disk B)
        open(CommandOutput, 'sudo /sbin/hdparm -I /dev/sda|grep "Serial Number" |');
        my @DiskSerialNumbers = <CommandOutput>;
        close( CommandOutput );
        if (scalar(@DiskSerialNumbers) == 1) {
            my $fd = new IO::File(nasCommon->serial_numbers,'r');
            my @KnownSN = <$fd>;
            # If it isn't in the list of known disks, this is a new disk
            if(!grep(/$DiskSerialNumbers[0]/, @KnownSN )) {
                $rc = Service::RAIDStatus::NEWDRIVEB
            }
        }
    }
    
    return $rc;
}


sub driveStatus {
	# Returns a display string corresponding to the current drive status.
	# If we are on a 1nc system, we just return OK
	my $this=shift;
	my $config=shift;

	# Get the drive status code
	return $this->driveStatusCode($config)->toMessage( $config );
}

    
1;
