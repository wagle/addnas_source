#!/usr/bin/env perl
# Class   : Service::Shares.pm
# Purpose : Manipulate shares
# Author  : $Author: $
# Date    : $Date: $
# Version : $Revision :$
#

=pod

=head1 DESCRIPTION

Service::Shares - Manipulate shares

=head1 SYNOPSIS

my $s = new Service::Shares();

my $ini = Service::Shares->open( $iniFileName );

Service::Shares->createDefault();

Service::Shares->deleteAllInternal();  ### removed

Service::Shares->deleteAllExternal();

Service::Shares->delete( $shareName );

=head1 DESCRIPTION

This class provides an interface to the samba shares file.

=over

=item new()

=item open( $inifile )

Opens an existing shares file or creates if it does not exist.
Returns a Config::IniFiles object or undef if the file cannot be opened.

=item createDefault()

Creates a default share called Public.

=item deleteAllInternal()

Deletes all the internal shares from the conf file where the path starts shares/internal.

=item deleteAllExternal()

Deletes all the internal shares from the conf file where the path starts shares/external.

=back

=cut

package Service::Shares;
use strict;
use nasCommon;
use Config::IniFiles;
use Service::Storage;

sub new {
	my $class = shift;
	my $this = {};
	bless $this, $class;

	return $this;
}

### DEAD
sub deleteAllInternal {
	# Go through the shares.inc and remove all internal shares
	my $class=shift;

	foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;

		foreach my $sharename ($smbConf->Sections()) {
			# See if the share path is shares/internal
			if($smbConf->val($sharename, 'path')=~/$sharesHome\/internal\/.+$/) {
				# Delete the share
				$smbConf->DeleteSection($sharename);
			}
		}
		$smbConf->RewriteConfig();
	}
	return 1;
}

### DEAD
sub deleteAllExternal {
	# Go through the shares.inc and remove all external shares
	my $class=shift;
	foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;
		foreach my $sharename ($smbConf->Sections()) {
			# See if the share path is shares/external
			if($smbConf->val($sharename, 'path')=~/$sharesHome\/external\/.+$/) {
				# Delete the share
				$smbConf->DeleteSection($sharename);
			}
		}
		$smbConf->RewriteConfig();
	}
	return 1;
}

### NEW
sub enableExternalPartition ($$) {
	my ($self, $uuid) = @_;
	foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;
		foreach my $sharename ($smbConf->Sections()) {
			my $dirpath = $smbConf->val($sharename, 'path');
			if (($dirpath =~ m,^$sharesHome/external/$uuid$,) && (-d $dirpath)) {                 ### whole disk
				$smbConf->delval($sharename,'available');  # default is 'yes'
			} elsif (($dirpath =~ m,^$sharesHome/external/$uuid/$sharename$,) && (-d $dirpath)) { ### disk of folders
				$smbConf->delval($sharename,'available');  # default is 'yes'
			}
		}
		$smbConf->RewriteConfig();
	}
	ludo("$nbin/ftpacl.pl enable_partition \"$sharesHome/external/$uuid\"");
	ludo("$nbin/ftpacl.pl rebuild_configs");
	sudo("$nbin/reconfigSamba.sh");
	sudo("$nbin/rereadFTPconfig.sh");
	return 1;
}

### NEW
sub disableExternalPartition ($$) {
	my ($self, $uuid) = @_;
	foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;
		foreach my $sharename ($smbConf->Sections()) {
			my $dirpath = $smbConf->val($sharename, 'path');
			if (($dirpath =~ m,^$sharesHome/external/$uuid$,) && (-d $dirpath)) {                 ### whole disk
				$smbConf->newval($sharename,'available','no');
			} elsif (($dirpath =~ m,^$sharesHome/external/$uuid/$sharename$,) && (-d $dirpath)) { ### disk of folders
				$smbConf->newval($sharename,'available','no');
			}
		}
		$smbConf->RewriteConfig();
	}
	ludo("$nbin/ftpacl.pl enable_partition \"$sharesHome/external/$uuid\"");
	ludo("$nbin/ftpacl.pl rebuild_configs");
	sudo("$nbin/reconfigSamba.sh");
	sudo("$nbin/rereadFTPconfig.sh");
	return 1;
}

sub deleteAllExternalFromDev($$) {
	my ($self, $name) = @_;
	system('echo delete name: '.$name.' > /var/oxsemi/debug');
	FILES: foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;
		foreach my $sharename ($smbConf->Sections()) {
			my $dirpath = $smbConf->val($sharename, 'path');
			if ($dirpath =~ /$sharesHome\/external\/$name\/.+$/) {
				$smbConf->DeleteSection($sharename);
			}
		}
		$smbConf->RewriteConfig();
	}
	sudo("$nbin/reconfigSamba.sh");
	return 1;
}

### DEAD
sub disableExternalDev($$) {
	my ($self, $name) = @_;
	system('echo disable name: '.$name.' > /var/oxsemi/debug');
	FILES: foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;
		foreach my $sharename ($smbConf->Sections()) {
			my $dirpath = $smbConf->val($sharename, 'path');
			if ($dirpath =~ /$sharesHome\/external\/$name\/.+$/) {
				$smbConf->newval($sharename,'available','no');
			}
		}
		$smbConf->RewriteConfig();
	}
	sudo("$nbin/reconfigSamba.sh");
	return 1;
}

### DEAD
sub deleteAllRemovedExternal {
	# This will go through the external shares, check if the storage still
	# exists if the storage has been removed, the share will be removed.
	my $class = shift;
	my $num_delays = 0;

	FILES: foreach my $file ( nasCommon->shares_inc, nasCommon->senvid_inc ) {
		my $smbConf = new Config::IniFiles( -file => $file ) || next;

		foreach my $sharename ($smbConf->Sections()) {
			# If the share path is to an external drive which doesn't exist
			# delete the share
			my $dirpath = $smbConf->val($sharename, 'path');
			if (($dirpath =~ /$sharesHome\/external\/.+$/) && (!(-d $dirpath))) {
				if ($num_delays >= 6) {
					# We've waited for 1 minute for the external drive to spin
					# up so give up and delete the share
# TSI: commenting out following line, we want to just set the share inactive, not delete it.
#					$smbConf->DeleteSection($sharename);
$smbConf->newval($sharename,'available','no');
ludo("$nbin/ftpacl.pl disable \"$sharename\"");
				} else {
					# The first occurance of an external share not matching with
					# an available directory will cause a 10s delay to allow
					# slow external disks to become ready
					my $delay = 10;

					debug("Delaying 10s to allow external drives to spin up");
					while ($delay > 0) {
						$delay -= sleep($delay);
					}

					$num_delays += 1;
					redo FILES;
				}
			}
		}

		$smbConf->RewriteConfig();
	}

	return 1;
}

sub findAllUsers {
	# Returns a hashRef of all share users excluding share_guest
	# users matching sh\d+, guest
	my %users;
	my $fd = new IO::File( nasCommon->smbpasswd );
	while (<$fd>) {
		my ($uname, $uid) = split(':',$_);
		unless ($uname && (
			($uname eq 'root') || 
			($uname eq $shareGuest) || 
			($uname =~ /^sh\d+$/) ||
			($uname eq 'guest')
		)) {
			# If it's none of the above, add to the hash
			$users{$uname} = $uid;
		}
	}
	return \%users;
}


sub getSortedlUsers {
	# Returns a hashRef of all share users excluding share_guest
	# users matching sh\d+, guest
    
	my $users    = [];
	my $errormsg = 0;

    unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->smbpasswd )) 
    {
      $errormsg = 'f00020';
      return ( $users, $errormsg );
    }

   if ( my $fd = new IO::File( nasCommon->smbpasswd ) )
   {
       # this is most likely not required as the smbuid should be in sync, nevertheless
       # the change operation will fail if the uid is not in /ets/paswrds, so it is
       # worth checking...
       my $name2uid = mapNameToUid();
        
       while (<$fd>) {
            my ($uname, $uid) = split(':',$_);
            unless ($uname && (
                ($uname eq 'root') || 
                ($uname eq $shareGuest) || 
                ($uname =~ /^sh\d+$/) ||
                ($uname eq 'guest')
            )) {
                # If it's none of the above, add to the array
               push @$users, { name => $uname, uid => $name2uid->{$uname} };
            }
        } 
   }
   else
   {
       $errormsg = 'f00005';
       return ( $users, $errormsg );
  }
   
    # now sort it...
    my @usersSorted = sort { $a->{name} cmp $b->{name} } @$users;
    
    return ( \@usersSorted, $errormsg );
}


sub createDefault {
	# Create the default 'PUBLIC' share
	my $class=shift;
	my $name=nasCommon->public_sharename;

	# Create a default share if it doesn't exist
	# Assumes umask 0022 and SUID/GUID inheritance
	# Also, the data volume has to be available (mounted)
	my $s=new Service::Storage( nasCommon->storage_volume );
	if ( (! -w nasCommon->public_share) && $s->data_volume_available()) {
		# Create the directory to contain the PUBLIC share
		my $public_share_name=nasCommon->public_sharename;
		sudo("$nbin/makeSharedir.sh $public_share_name");

		# Open or create the shares.inc file
		my $smbConf = $class->open( nasCommon->shares_inc );

		# First, delete existing PUBLIC share, just in case	
		$smbConf->DeleteSection( $name );

		# Create the new PUBLIC share
		$smbConf->AddSection( $name );

		# Get the list of all users
		my $users=$class->findAllUsers();

		# Set up the PUBLIC share's parameters
		$smbConf->newval( $name, 'path', nasCommon->public_share );
		$smbConf->newval( $name, 'force user', 'www-data' );
		$smbConf->newval( $name, 'valid users', join(' ',nasCommon->share_guest,keys( %{$users})));
		$smbConf->newval( $name, 'write list',  join(' ',nasCommon->share_guest,keys( %{$users})));
		$smbConf->newval( $name, 'guest ok', 'Yes' );
		$smbConf->newval( $name, 'preallocate', 'Yes');

		# Write the file
		$smbConf->RewriteConfig;
	}
}

sub open {
	# Opens an existing shares file or creates if it does not exist
	# Returns a Config::IniFiles object
	# or undef if the file cannot be opened
	my $class=shift;
	my $file = shift || return;

        my $ini = new Config::IniFiles( -file => $file );
        unless ($ini) {
		# Cannot open existing file, so create one
                $ini = new Config::IniFiles();
                return unless ($ini);
                $ini->SetFileName( $file );
        }

	return $ini;
}


1;
