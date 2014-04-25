#
#	Adds a Share
#
#	Ian Steel
#	September 2006
#
package nas::fs_addshare;

use IO::File;
use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

# [ ] -> fs_addshare.tpl      (start wizard)    -> [1]
# [1] -> fs_addshare1.tpl     (get volumename)  -> [2]
# [2] -> fs_addshare2.tpl     (get sharename)   -> [4]
# [4] -> fs_addshare4user.tpl (get perms)       -> [6]
# [6] -> ...                  (perform actions)

sub main($$$) {

  my ($self, $cgi, $config) = @_;

  {
    if ($cgi->param('nextstage') == 1) {
      $self->stage1($cgi, $config);
      last;
    }

    if ($cgi->param('nextstage') == 2) {
      $self->stage2($cgi, $config);
      last;
    }

    # if ($cgi->param('nextstage') == 3) {
    #   $self->stage3($cgi, $config);
    #   last;
    # }

    if ($cgi->param('nextstage') == 4) {
      $self->stage4($cgi, $config);
      last;
    }

    # if ($cgi->param('nextstage') == 5) {
    #   $self->stage5($cgi, $config);
    #   last;
    # }

    if ($cgi->param('nextstage') == 6) {
      $self->stage6($cgi, $config);
      last;
    }

    # default
    #
    $self->outputTemplate('fs_addshare.tpl', { tabon => 'fileshare' } );
  }

}

# start wizard (fs_addshare.tpl) -> stage 1 -> select volume (fs_addshare2.tpl)
sub stage1($$$) {
  my ($self, $cgi, $config) = @_;

  # Select the filesharing tab for display
  my $vars = { tabon => 'fileshare' };

  # Copy the form data into our local storage
  copyFormVars($cgi, $vars);

  # Add to the list of volumes any found in the external directory (ie,
  # pendrives, etc) so that these can be presented to the user as options
  # for volumes onto which the new share can be mapped
  my @vols = ();
  unless (nasCommon::listExternals(\@vols)) {
    $self->fatalError($config, 'f00026');
    return;
  }
  $vars->{extvols} = \@vols;

  # Display the next form
  $self->outputTemplate('fs_addshare1.tpl', $vars); # select a volume
}

sub listTopLevelFolders($$) {
  my ($volume, $folders) = @_;
  for (`find /shares/external/$volume -type d -maxdepth 1`) {
    chomp;
    next if m,^/shares/external/$volume$,;
    s,^/shares/external/$volume/,,;
    next if nasCommon::reserved_filename_p($_);
    push @$folders, { path => "$_" };
  }
  @$folders = sort { $a->{path} cmp $b->{path} } @$folders;
  return SUCCESS;
}


# select volume (fs_addshare2.tpl) -> stage 1 -> select share (fs_addshare2.tpl)
sub stage2($$$) {
  my ($self, $cgi, $config) = @_;

  # Select the filesharing tab for display
  my $vars = { tabon => 'fileshare' };

  # Copy the form data into our local storage
  copyFormVars($cgi, $vars);

  $vars->{frm}->{volume} = $cgi->param('volume');

  my @folders = ();
  unless (listTopLevelFolders($vars->{frm}->{volume}, \@folders)) {
    $self->fatalError($config, 'f00026');
    return;
  }
  $vars->{extfolders} = \@folders;

  # Display the next form
  $self->outputTemplate('fs_addshare2.tpl', $vars);
}

# sub stage3($$$) {
#
#   my ($self, $cgi, $config) = @_;
#
#   my $vars = { tabon => 'fileshare' };
#
#   copyFormVars($cgi, $vars);
#   $self->outputTemplate('fs_addshare3.tpl', $vars);
#
# }

sub stage4($$$) {

  my ($self, $cgi, $config) = @_;

  my $vars = { tabon => 'fileshare' };
  my $error = 0;

  copyFormVars($cgi, $vars);

  # open (my $con, "> /dev/console");
  # print $con "SUBMIT1! ", "" ne $vars->{frm}->{submit1}, " : ", $vars->{frm}->{sharename}, "\n";
  # print $con "SUBMIT2! ", "" ne $vars->{frm}->{submit2}, " : ", $vars->{frm}->{folder}, "\n";
  # print $con "SUBMIT3! ", "" ne $vars->{frm}->{submit3}, "\n";
  # close $con;

  if ($vars->{frm}->{submit2} ne "") {
    $vars->{frm}->{sharename} = $vars->{frm}->{folder};
  }

  $vars->{frm}->{wholedisk} = ($vars->{frm}->{submit3} ne "");

  # Convert the share name to uppercase UTF-8
  my $utf8name = uc Encode::decode("utf8", $vars->{frm}->{sharename});

  # Check that the share name is allowed and not a duplicate
  my $error = nasCommon::validateSharename($utf8name, $self->getShares($config));
  if ($error) {
    my @folders = ();
    unless (listTopLevelFolders($vars->{frm}->{volume}, \@folders)) {
      $self->fatalError($config, 'f00026');
      return;
    }
    $vars->{extfolders} = \@folders;
    nasCommon::setErrorMessage($vars, $config, 'sharename', $error);
    $self->outputTemplate('fs_addshare2.tpl', $vars);
    return;
  }

  # Feed back the uppercased share name to the next form
  $vars->{frm}->{sharename} = $utf8name;

  ###if ($cgi->param('cif')) {
    my ($errcode,$errmessage) = checkForFilenameCaseBraindamage("/shares/external/".$vars->{frm}->{volume}."/".$vars->{frm}->{sharename});
    if ( $errcode ) {
      $self->fatalError($config, $errcode, $errmessage);
      return;
    }	

    unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->smb_conf )) {
      $self->fatalError($config, 'f00020');
      return;
    }

    my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
    unless ($smbConf) {
      $self->fatalError($config, 'f00005');
      return;
    }

    # my $accessType = undef;

    # if ($smbConf->val('global', 'security') eq 'user') {
    #   $accessType = 'user';
    # } else {
    #   $accessType = 'pw';
    # }

    # IMPORTANT !!!!!
    #
    # Access Type is to be HARDCODED to 'user' for the time being
    #
    my $accessType = 'user';

    # Are we using user level security, or password/public?
    #
    if ($accessType eq 'user') {

      # List all existing users
      #
      my $users = [];

      unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->smbpasswd )) {
	$self->fatalError($config, 'f00020');
	return;
      }

      unless (open(SPW, "<" . nasCommon->smbpasswd ) ) {
	$self->fatalError($config, 'f00005');
	return;
      }

      while (<SPW>) {
	$_ =~ /^([^:]+):([^:]+).*$/;
	my ($uname, $uid) = ($1, $2);
	unless (($uname eq 'root') || ($uname eq $shareGuest) || ($uname =~ /^sh\d+$/) || ($uname eq 'guest')) {
	  push @$users, { name => $uname, id => $uid };
	}
      }
      close(SPW);

      # Add the 'guest' user - this is used for 'public' accessing of this share
      #
      my $name2uid = mapNameToUid();

      push @$users, {
		     name => getMessage($config, 'm11020'),
		     id => $name2uid->{$shareGuest} 
		    };

      ### my @sorted = sort { $a->{name} cmp $b->{name} } @$users;
      my @sorted = sort {
	if ($a->{name} eq getMessage($config, 'm11020')) {
	  -1;
	} elsif ($b->{name} eq getMessage($config, 'm11020')) {
	  1;
	} else {
	  $a->{name} cmp $b->{name};
	}
      } @$users;
      ###  
      $vars->{users} = \@sorted;

      $self->outputTemplate('fs_addshare4user.tpl', $vars);
    }	 # else {
    #   $self->outputTemplate('fs_addshare4password.tpl', $vars);
    # }
  ###} elsif ($cgi->param('nfs')) {
  ###  $self->outputTemplate('fs_addshare4user.tpl', $vars);
  ###} else {
  ###  $self->outputTemplate('fs_addshare5.tpl', $vars);
  ###}
}

# sub stage5($$$) {
#
#   my ($self, $cgi, $config) = @_;
#
#   my $vars = { tabon => 'fileshare' };
#   my $error = 0;
#
#   copyFormVars($cgi, $vars);
#
#   my $users = [];
#   foreach my $p ($cgi->param()) {
#
#     # Copy the user share permissions required to the next page
#     #
#     if ($p =~ /^user_(\d+)_smb_perm$/) {
#       push @$users, { id => $1, smb_perm => $cgi->param($p) };
#     } elsif ($p =~ /^user_(\d+)_ftp_perm$/) {
#       push @$users, { id => $1, ftp_perm => $cgi->param($p) };
#     }
#   }
#   $vars->{users} = $users;
#
#   $self->outputTemplate('fs_addshare5.tpl', $vars);
#
# }

####################################################################################################
# Actually create the share
####################################################################################################
sub stage6($$$) {

  my ($self, $cgi, $config) = @_;

  my $vars = { tabon => 'fileshare' };
  my $error = 0;
  my $sharenameNospaces;

  my $sharesInc = undef;
  $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
  unless ($sharesInc) {
    $sharesInc = new Config::IniFiles();
    unless ($sharesInc) {
      $self->fatalError($config, 'f00012');
      return undef;
    }
    $sharesInc->SetFileName(nasCommon->shares_inc);
  }

  my $sharewholedisk = $cgi->param('wholedisk');

  my $sharename = $cgi->param('sharename');
  my $sharenameNospaces = $sharename;
  $sharenameNospaces =~ s/ /_/g;

  # Only need to make the directory if this share is on the internal drive(s). ie, it is
  # volume 'main'.
  #
  my $volume = $cgi->param('volume');
 
  # if we're creating any internal share, replace spaces with underscores and
  # create the directory
  if ($cgi->param('cif') eq 'y') {
    # if ($volume =~ /main/i) {
    #   my $tcreatedir = "internal/".$sharenameNospaces;
    #   unless (sudo("$nbin/makeSharedir.sh $tcreatedir")) {
    #     $self->fatalError($config, 'f00019');
    #     return;
    #   }
    # } else {
    if ($sharewholedisk) {
      my $tinitdir = "external"."/".$volume;
      unless (sudo("$nbin/initWholediskRoot.sh $tinitdir")) {
        $self->fatalError($config, 'f00019');
        return;
      }
    } else {
      my $tcreatedir = "external"."/".$volume."/".$sharenameNospaces;
      unless (sudo("$nbin/makeSharedir.sh $tcreatedir")) {
        $self->fatalError($config, 'f00019');
        return;
      }
    }
    # }
  }

  # The parameters from the CGI will be some of :
  #
  #   pword: The password required for password based share
  #   user_xxx_perm: xxx is the userid, and the value of this param will be 'r' or 'f' (read/full)
  #   cif: set to 'y' if CIF required
  #   ftp: set to 'y' if FTP required
  #   nfs: set to 'y' if NFS required
  #   http: set to 'y' if HTTP required (not supported currently)
  #
  if ($cgi->param('cif') eq 'y') {

    $sharesInc->AddSection($sharename);
    # internal and external directories have different top level dir...
    #
    # if ($volume =~ /main/i) {
    #   $sharesInc->newval($sharename, 'path', "$sharesHome/internal/$sharenameNospaces");
    #   $sharesInc->newval($sharename, 'preallocate', 'Yes');
    # } else {
      if ($sharewholedisk) {
        $sharesInc->newval($sharename, 'path', "$sharesHome/external/$volume");
      } else {
        $sharesInc->newval($sharename, 'path', "$sharesHome/external/$volume/$sharenameNospaces");
      }
      for (`cat /proc/mounts`) {
        chomp;
        my ($dev,$mpnt,$fstype) = split /\s+/, $_;
        if (($mpnt eq "$sharesHome/external/$volume") and ($fstype eq "xfs")) {
          $sharesInc->newval($sharename, 'preallocate', 'yes');
          $sharesInc->newval($sharename, 'incoherent', 'yes');
          $sharesInc->newval($sharename, 'direct writes', '2');
          last;
        }
      }
    # }

    $sharesInc->newval($sharename, 'force user', 'www-data');

    # If we are running in 'user' security mode, set permissions for each user required.
    #
    unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->smb_conf )) {
      $self->fatalError($config, 'f00020');
      return;
    }

    my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
    unless ($smbConf) {
      $self->fatalError($config, 'f00005');
      return;
    }

    # my $accessType = undef;

    # if ($smbConf->val('global', 'security') eq 'user') {
    #   $accessType = 'user';
    # } else {
    #   $accessType = 'pw';
    # }

    # IMPORTANT !!!!!
    #
    # Access Type is to be HARDCODED to 'user' for the time being
    #
    my $accessType = 'user';

    # Are we using user level security, or password/public?
    #
    if ($accessType eq 'user') {

      # User/password prtected share
      #
      my $full = '';
      my $read = '';
      my $allUsers = '';
  
      my $uid2name = mapUidToName();

      #
      # loop over the radio buttons returned from the form
      #
      my $smb_publicAccess = 'n';
      my @smb_allUsers = ();
      my @smb_allPubUsers = ();
      my @smb_roUsers = ();
      my @smb_fullUsers = ();
      my @ftp_noneUsers = ();
      my @ftp_readUsers = ();
      my @ftp_fullUsers = ();

      foreach my $p ($cgi->param()) {
        if ($p =~ /^user_(\d+)_smb_perm$/) {
          my $uid = $1;
          my $uname = $uid2name->{$uid};
          unless ($uname) {
            $self->fatalError($config, 'f00018');
            return;
          }
	  #
          # For a public share, we have to explicitly allow guest access as user www-data
          #
          if ($uname eq $shareGuest) {
            $smb_publicAccess = $cgi->param($p);
          } else {
            push @smb_allPubUsers, $uname;
            push @smb_allUsers, $uname unless ($cgi->param($p) eq 'n');
            push @smb_fullUsers, $uname if ($cgi->param($p) eq 'f');
            push @smb_roUsers, $uname if ($cgi->param($p) eq 'r');
          }
        } elsif ($p =~ /^user_(\d+)_ftp_perm$/) {
          my $uid = $1;
          my $uname = $uid2name->{$uid};
          unless ($uname) {
            $self->fatalError($config, 'f00018');
            return;
          }
	  #
          # For a public share, we have to explicitly allow guest access as user www-data
          #
	  push @ftp_fullUsers, $uname if ($cgi->param($p) eq 'f');
	  push @ftp_readUsers, $uname if ($cgi->param($p) eq 'r');
	  push @ftp_noneUsers, $uname if ($cgi->param($p) eq 'n');
        }
      }
      #
      # Has public access been specified?
      #
      if ($smb_publicAccess ne 'n') {
        $sharesInc->newval($sharename, 'guest ok', 'Yes');
        @smb_allUsers = @smb_allPubUsers;
        push @smb_allUsers, $shareGuest;

        if ($smb_publicAccess eq 'r') {

          # Read only users are all those valid users who are NOT to have specific full access,
          #   plus www-data (guest)
          #
          @smb_roUsers = grep { my $ret = 1;
				foreach my $u (@smb_fullUsers) {
				  if ($u eq $_) {
				    $ret = 0;
				  }
				}
				$ret;
			      } @smb_allPubUsers;
          push @smb_roUsers, $shareGuest;

        }

        if ($smb_publicAccess eq 'f') {

          # Full users are all the valid users plus www-data (guest). The logic here is that
          # if you have granted Public write access, there is no way to give someone specifically
          # readonly access as all they have to do is connect as someone else.
          #
          @smb_fullUsers = @smb_allUsers;
          @smb_roUsers = ();

        }
      }

      if (@smb_allUsers) {
        $sharesInc->newval($sharename, 'valid users', join(' ', @smb_allUsers)) if (@smb_allUsers);
      } else {
        $sharesInc->delval($sharename, 'valid users');
      }
      if (@smb_fullUsers) {
        $sharesInc->newval($sharename, 'write list', join(' ', @smb_fullUsers)) if (@smb_fullUsers);
      } else {
        $sharesInc->delval($sharename, 'write list');
      }
      if (@smb_roUsers) {
        $sharesInc->newval($sharename, 'read list', join(' ', @smb_roUsers)) if (@smb_roUsers);
      } else {
        $sharesInc->delval($sharename, 'read list');
      }
      #
      #  FTP
      #
      my $mpnt = $sharesInc->val($sharename, 'path');
      $mpnt =~ s,/$sharename$,,;
      if ($sharewholedisk) {
	ludo("$nbin/ftpacl.pl create_wholedisk_share \"$mpnt\" \"$sharename\"");
      } else {
	ludo("$nbin/ftpacl.pl create_normal_share \"$mpnt\" \"$sharename\"");
      }
      for my $username (@ftp_fullUsers) {
	ludo("$nbin/ftpacl.pl full \"$username\" \"$sharename\"");
      }
      for my $username (@ftp_readUsers) {
	ludo("$nbin/ftpacl.pl read \"$username\" \"$sharename\"");
      }
      for my $username (@ftp_noneUsers) {
	ludo("$nbin/ftpacl.pl none \"$username\" \"$sharename\"");
      }
    }				# else {

    #   if ($cgi->param('pword') ne '') {

    #     # Password protected share required
    #     # Create a unique user for this share and assign the requested password to it.
    #     #
    #     my $username = 'sh' . `date +%s`;
    #     chomp $username;

    #     unless (sudo("$nbin/fs_addUser.sh $username '" . $cgi->param('pword') . "'")) {
    #       $self->fatalError($config, 'f00014');
    #       return;
    #     }

    #     $sharesInc->newval($sharename, 'username', $username);
    #     $sharesInc->newval($sharename, 'read only', 'no');
    #     $sharesInc->newval($sharename, 'public', 'no');

    #   } else {			# Public access (no password required)

    #     $sharesInc->newval($sharename, 'public', 'yes');
    #     $sharesInc->newval($sharename, 'read only', 'no');

    #   }

    # }

    unless ($sharesInc->RewriteConfig) {
      $self->fatalError($config, 'f00013');
      return;
    }

    #    unless (sudo("$nbin/restartSamba.sh")) {
    #      $self->fatalError($config, 'f00017');
    #      return;
    #    }
    unless (sudo("$nbin/reconfigSamba.sh")) {
      $self->fatalError($config, 'f00034');
      return;
    }
    unless (ludo("$nbin/ftpacl.pl rebuild_configs")) {
      $self->fatalError($config, 'f00039');
      return;
    }
    unless (sudo("$nbin/rereadFTPconfig.sh")) {
      $self->fatalError($config, 'f00040');
      return;
    }
  }

  if ($cgi->param('ftp') eq 'y') {

  }

  print $cgi->redirect('/auth/fileshare.pl');

}

1;
