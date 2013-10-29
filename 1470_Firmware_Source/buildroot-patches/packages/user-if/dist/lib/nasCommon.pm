package nasCommon;

@ISA=qw(Exporter);
@EXPORT = qw(logger debug checkForFilenameCaseBraindamage listExternals getMessage getPasswordError getUsernameError validateDeviceName validateSharename validateWorkgroup isValidEmail copyFormVars mapUidToName mapNameToUid $shareGuest $sharesHome sudo ludo $nbin VALID INVALID SUCCESS FAILURE);

use constant VALID => 1;
use constant INVALID => 0;

use constant SUCCESS => 1;
use constant FAILURE => 0;

use strict;
use vars qw($nbin $shareGuest $sharesHome );
use Config::IniFiles;
use Exporter;
use Sys::Syslog;
#use Sys::Hostname;

use nasLanguage qw($message);

### Set test_prefix to the build directory location so we can simulate the nas files.
#use constant test_prefix =>	'/home/Anthony/Addonics_Proj/buildroot-7821/project_build_arm/OX820/root';
use constant test_prefix => '';
# Create constants for oxsemi specific file locations
# These can be accessed by for eg. nasCommon->smb_conf
# Dot's (.) in names have been replaced with _
# If it is a path/diretory. It ends with /
# bruce
# System config files
use constant version_file  => 	test_prefix.'/var/lib/current-version';
use constant smb_lib  => 	test_prefix.'/usr/local/samba/lib/';
use constant smb_home  => 	test_prefix.'/usr/local/samba/';
use constant smb_conf  => 	test_prefix.'/etc/smb.conf';
use constant bin_smbpasswd  => 	test_prefix.'/usr/local/samba/bin/smbpasswd';
use constant smbpasswd  => 	test_prefix.'/var/private/smbpasswd';
use constant network_settings  =>test_prefix.'/var/oxsemi/network-settings';
use constant default_settings  =>test_prefix.'/etc/default-settings';
use constant passwd  => 	test_prefix.'/etc/passwd';
use constant group  => 		test_prefix.'/etc/group';
use constant zone_tab  => 	test_prefix.'/usr/share/zoneinfo/zone.tab';
use constant TZ  => 		test_prefix.'/var/etc/TZ';
use constant storage_volume =>	test_prefix.'/shares/internal';
use constant external_storage_volume =>	test_prefix.'/shares/external';
use constant htdigest_user =>	test_prefix.'/var/private/lighttpd.htdigest.user';
use constant public_sharename => 'PUBLIC';
use constant public_share =>	storage_volume.'/'.public_sharename;
use constant share_guest =>	'www-data';
use constant mdadm_conf =>	test_prefix.'/etc/mdadm.conf';
use constant failed_drives =>	test_prefix.'/var/oxsemi/failed-drives';
use constant session_store =>	test_prefix.'/tmp/plxnas_sessions';
use constant cookieName =>	'plxnas';	# TODO: use mac address!
use constant FW_DOWNLOAD_FILE =>  'fw.tar.gz';
# NAS Config files                 
use constant senvid_inc  => 	test_prefix.'/var/oxsemi/senvid.inc';
use constant shares_inc  => 	test_prefix.'/var/oxsemi/shares.inc';
use constant nas_ini  => 	test_prefix.'/var/oxsemi/nas.ini';
use constant emailRecipients  => test_prefix.'/var/oxsemi/email-recipients';
use constant ssmtpConf	=>	test_prefix.'/var/etc/ssmtp/ssmtp.conf';
use constant nas_lock =>	test_prefix.'/tmp/dm_progress';
use constant network_lock =>	test_prefix.'/var/run/network_started';
use constant nas_paths =>	test_prefix.'/usr/www/nbin/setupPaths.sh';
# NAS www paths
use constant nas_home  => 	test_prefix.'/var/oxsemi/';
use constant nas_shares  => 	test_prefix.'/shares';
use constant nas_www  => 	test_prefix.'/usr/www/';
use constant nas_lib  => 	test_prefix.'/usr/www/lib';
use constant nas_templates  => 	test_prefix.'/usr/www/ptpl/';
use constant nas_nbin =>	test_prefix.'/usr/www/nbin/';
# use constant nas_patch  => 	'/var/oxsemi/patch/';
use constant nfs_exports => test_prefix.'/var/etc/exports';
use constant mdadm_conf => test_prefix.'/etc/mdadm.conf';
use constant serial_numbers => test_prefix.'/var/oxsemi/disk_serial_numbers';

# system constants
use constant max_dev_length => 15;
use constant max_wkg_length => 15;


BEGIN {

  # the location of all the shell scripts required to manage the device
  #
  $nbin = '/usr/www/nbin';

  # The top directory for the shares
  #
  $sharesHome = '/shares';

  # The 'guest' username for Samba Shares
  #
  $shareGuest = 'www-data';

  # System files maintained via the devices web interface
  #
#  $sysFiles = {
#                'smb.conf' =>   '/etc/smb.conf',
#                'smbpasswd' =>  '/var/private/smbpasswd',
#                'passwd' =>     '/etc/passwd',
#                'senvid.inc' => '/var/oxsemi/senvid.inc',
#                'shares.inc' => '/var/oxsemi/shares.inc',
#                'zone.tab' =>   '/usr/share/zoneinfo/zone.tab',
#                'TZ' =>         '/etc/TZ'
#  }

}


sub logger {
	my $message = shift;
	system("touch /var/log/logger.log");
	open(OUT, ">> /var/log/logger.log");
	print OUT $message, "\n";
	close(OUT);
	#print STDERR $message;
}

sub debug($) {

	my ($mess) = @_;

	openlog($0, 'pid', 'user');
	syslog('notice', $mess);
	closelog();

}

sub commify {
	my $class=shift;
	# commify a number. Perl Cookbook, 2.17, p. 64
	my $text = reverse $_[0];
	$text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
	return scalar reverse $text;
}

# Returns the current language version of messaage identified by messageId
#
sub getMessage($$) {

	my ($config, $messId) = @_;

	my $language = $config->val('general', 'language');

	return $message->{$language}->{$messId};

}

sub setErrorMessage {

	my ($target, $config, $element, $messId) = @_;

    $target->{err}->{$element} = getMessage($config, $messId);
    unless ( $target->{focusOn} )
    {
        $target->{focusOn} = $element;
    }
}

sub hostname {
	# Determine the hostname (without caching);
	return `/bin/hostname`;
}

# Runs a shell script via sudo.
#	Make sure that sudoers is configured to match!
#
sub sudo($) {
	my ($cmd) = @_;

#	`sudo $cmd`;  # bruce - removed backticked version
# bruce - Not sure quite why I am getting 256 on  what look like successful
# return codes. Maybe to do with the shift right 8 becoming -1???
	my $rc = system( "sudo $cmd" );
	if ( $rc && ($rc != 256) ) {
		# An error occurred in a sub script.
		# Make sure we log the error
		logger( "nasCommon::sudo: $cmd produced the following error: ".join(',',$!,$?,$rc) );
		return FAILURE;
	} else {
		logger( "nasCommon::sudo: $cmd produced the following error: ".join(',',$!,$?,$rc) );
		return SUCCESS;
	}

#  return SUCCESS;	# bruce - removed constant success...
}

sub ludo($) {
	my ($cmd) = @_;
	my $rc = system($cmd);
	if ( $rc && ($rc != 256) ) {
		return FAILURE;
	} else {
		return SUCCESS;
	}
}

# Copies variables from one hash to another in effect.
#	Use this when you want to redisplay a web form which contains errors.
#
sub copyFormVars($$) {

	my ($cgi, $vars) = @_;

	my %vars = $cgi->Vars();

	map { $vars->{frm}->{$_} = $cgi->param($_); } $cgi->param();

}

# Ensure only letters, numbers and underscores in UTF-8 encoded string
#
sub validateIsWord {
	my ($utf8sharename) = @_;

        if ($utf8sharename =~ /\P{IsWord}/) {
		return INVALID;
        }
	return VALID;
}

# Ensure only letters and numbers in UTF-8 encoded string
#
sub validateIsAlnum {
	my ($utf8sharename) = @_;

        if ($utf8sharename =~ /\P{IsAlnum}/) {
		return INVALID;
        }
	return VALID;
}

# Validity check for paswords
#
sub getPasswordError {
	my ($pword1, $pword2) = @_;
	my $minlen = 5;
	my $maxlen = 20;

	# Password is required
	if ($pword1 eq '') {
		return 'e04002';
	}

	# Check passwords match
	if ($pword1 ne $pword2) {
		return 'e04003';
	}

	# Convert first password to UTF-8
	my $utf8pword1 = Encode::decode("utf8", $pword1);

	# Check password contains only the allowed characters
	if (!validateIsAlnum($utf8pword1)) {
		return 'e04006';
	}

	# Check password has a valid length
	if (length($utf8pword1) < $minlen || length($utf8pword1) > $maxlen) {
		return 'e04007';
	}

	return 0;
}

# Validity check for usernames
#
sub getUsernameError {
	my ($uname) = @_;
	my $minlen = 5;
	my $maxlen = 20;

	# Username is required
	if ($uname eq '') {
		return 'e04001';
	}

	# Convert username to UTF-8
	my $utf8uname = Encode::decode("utf8", $uname);

	# Check username contains only the allowed characters
	if (!validateIsAlnum($utf8uname)) {
		return 'e04004';
	}

	# Check username  has a valid length
	if (length($utf8uname) < $minlen || length($utf8uname) > $maxlen) {
		return 'e04005';
	}

	return 0;
}

sub reserved_filename_p($) {
  my $file = uc $_[0];
  return 1 if $file eq "DEV";
  return 1 if $file eq "OPT";
  return 1 if $file eq "FW.TAR.GZ";
  return 1 if $file eq "LOST+FOUND";
  return 0;
}

# Validity check for share names in UTF-8 encoded string
#
sub validateSharename {
  my ($utf8sharename, $shares) = @_;

  # Share name cannot be zero length
  if ($utf8sharename eq '') {
    return 'e12001';
  }

  # Share names shall contain only letters, numbers and underscores
  if (!validateIsAlnum($utf8sharename)) {
    return 'e12003';
  }

  # Share name shall not start with a digit
  if ($utf8sharename =~ /^\p{IsDigit}/) {
    return 'e12004';
  }

  # Is there already a share with this name?
  map {
    if ($_->{name} eq $utf8sharename) {
      return 'e12002';
    }
  } @$shares;

  if ( reserved_filename_p($utf8sharename) ) {
    return 'f00036';
  }

  return 0;
}

# Validity check for workgroup name
#
sub validateWorkgroup {
	my ($utf8workgroup) = @_;

        # Workgroup cannot be zero length
        if ($utf8workgroup eq '') {
		return 'e07002';
        }

        # Workgroup shall contain only letters, numbers and underscores
	if (!validateIsWord($utf8workgroup)) {
		return 'e07004';
	}

	# Check workgroup is not too long
	if (max_wkg_length < length($utf8workgroup)) {
		return 'e07006';
	}

	return 0;
}

# Validity check for device name
#
sub validateDevicename {
	my ($utf8devicename) = @_;

        # Device name cannot be zero length
        if ($utf8devicename eq '') {
		return 'e07001';
        }

        # Device name shall contain only letters, numbers and underscores
	if (!validateIsWord($utf8devicename)) {
		return 'e07003';
	}

        # Device name shall not start with a digit
        if ($utf8devicename =~ /^\p{IsDigit}/) {
		return 'e07007';
        }

	# Check device name is not too long
	if (max_dev_length < length($utf8devicename)) {
		return 'e07005';
	}

	return 0;
}

# Validity check for FTP port number
#
sub validateFtpportnumber {
    my ($ftpportnumber) = @_;

    unless ( $ftpportnumber =~ /^[0-9]{1,5}$/) {
        return 'e21005';
    }

    if ( $ftpportnumber < 0 ) {
        return 'e21006';
    }

    if ( $ftpportnumber > 65535 ) {
        return 'e21006';
    }

    return 0;

}

##
# getOctError, ensures a number is present between 0 .. 255 inclusive
sub getOctError {

    my ( $vars ) = @_;

    unless ( $vars =~ /^[0-9]{1,3}$/) {
        return 'e08004';
    }

    if ( $vars < 0 ) {
        return 'e08001';
    }

    if ( $vars > 255 ) {
        return 'e08001';
    }

    return 0;
}

##
# getIpError, takes vars as pre-populted 'frm', and checks prefix[1..4] to ensure that
# it falls into a good range for the ip address.
sub getIpError {

    my ( $vars, $prefix, $allow_all_blanks )  = @_;
    my $populated         = 0;

    foreach my $quad ( 1..4 )
    {
        my $value  = $vars->{frm}->{$prefix.$quad};

        if ( ! $populated )
        {
            if ( "" eq $value )
            {
                next;
            }

            unless ( $quad == 1 )
            {
                unless ( $vars->{focusOn} ) {
                    $vars->{focusOn} = $prefix.$quad;
                }
                return 'e08001';
            }

            $populated = 1;
        }

        if ( my $ecode = getOctError( $value ) )
        {
            $vars->{frm}->{$prefix.$quad} = "xxx";
                unless ( $vars->{focusOn} ) {
                    $vars->{focusOn} = $prefix.$quad;
                }
            return $ecode;
        }

        if ( $quad == 1 )
        {
           if ( $value > 224 )
           {
               $vars->{frm}->{$prefix.$quad} = "xxx";
                unless ( $vars->{focusOn} ) {
                    $vars->{focusOn} = $prefix.$quad;
                }
                return 'e08002';
           }

           if ( $value == 127 )
           {
               $vars->{frm}->{$prefix.$quad} = "xxx";
                unless ( $vars->{focusOn} ) {
                    $vars->{focusOn} = $prefix.$quad;
                }
               return 'e08003';
           }

           if ( $value == 0 )
           {
               $vars->{frm}->{$prefix.$quad} = "xxx";
                unless ( $vars->{focusOn} ) {
                    $vars->{focusOn} = $prefix.$quad;
                }
               return 'e08006';
           }
        }
    }

	if ($populated == 0 && $allow_all_blanks == 0) {
		return 'e08004';
	}

    return 0;
}

sub getGwError {
    my ( $vars ) = @_;
    my $populated = 0;

    # Are any of the bytes of the gateway address populated?
    foreach my $byte ( 1..4 ) {
        my $value  = $vars->{frm}->{"gw".$byte};

	if ( $value eq "" ) {
            next;
        }

	$populated = 1;
    }

    if ( $populated == 1) {
	foreach my $byte ( 1,4 ) {
            my $value  = $vars->{frm}->{"gw".$byte};
            if ( $value < 1 || $value > 254 ) {
                $vars->{frm}->{"gw".$byte} = "xxx";
                $vars->{focusOn} = "gw".$byte;
                return 'e08009'
    	    }
	}
    }

    return 0;
}

# Returns a hash, keyed by user id and containing username
#
sub mapUidToName() {

  # Need the passwd file later to map uid to real username
  #
  unless (open(PW, "<" . nasCommon->passwd ) ) {
    return undef;
  }

  my $ret = {};

  while (<PW>) {
    $_ =~ /(^[^:]+):[^:]+:([\d]+):.+$/;
    $ret->{$2} = $1;
  }

  close(PW);

  return $ret;
}

sub mapNameToUid() {

  # Need the passwd file later to map uid to real username
  #
  unless (open(PW, "<" . nasCommon->passwd ) ) {
    return undef;
  }

  my $ret = {};

  while (<PW>) {
    $_ =~ /(^[^:]+):[^:]+:([\d]+):.+$/;
    $ret->{$1} = $2;
  }

  close(PW);

  return $ret;
}

sub isValidEmail($) {

	my ($email) = @_;
debug("email: $email");
	if ($email =~ /^[a-zA-Z0-9_\.]+@[a-zA-Z0-9_\.]+$/) {
		return VALID;
	} else {
		return INVALID;
	}
}

sub checkForFilenameCaseBraindamage($) {
	my ($sharepath) = @_;
	if ( $sharepath =~ m,^$sharesHome/external/([^/]+)/([^/]+)$, ) {
		my $volume = $1;
                my $sharename = $2;
		my $TLD = undef;
		unless (opendir($TLD, "$sharesHome/external/$volume")) {
			return('f00034',"The mount point was $volume.");
		}
		while (my $file = readdir $TLD) {
			next if ($file =~ /^\./);    # skip hidden, ourselves and the parent
			if ( $sharename eq $file ) {
				next;
			} elsif ( $sharename eq (uc $file) ) {
				return('f00035', "File $file exists, you tried $sharename.");
			}
		}
		close(TLD);
	}	
	return ("","");
}

sub listExternals($) {

	my ($vols) = @_;

	for (`cat /proc/mounts`) {
		chomp;
		next unless m,^/dev/,;
		my ($device, $mpoint) = split (' ');
		my $uuid = (split('/',$mpoint))[3];
		if ( $device =~ m,^/dev/(...)(\d+)$, ) {
			my $diskdevice = $1;
			my $diskpartition = $2;
			my $diskvendor = `cat /sys/block/$diskdevice/device/vendor`;
               		my $diskmodel  = `cat /sys/block/$diskdevice/device/model`;
			push @$vols, { path => "$uuid", prefix => "$diskdevice$diskpartition $diskvendor $diskmodel" };
		}
        }

	@$vols = sort { $a->{prefix} cmp $b->{prefix} } @$vols;

        return SUCCESS;
}

1;
