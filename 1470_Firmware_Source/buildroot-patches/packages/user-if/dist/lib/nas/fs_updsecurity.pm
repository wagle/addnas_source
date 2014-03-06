#
#    File Share - Change the security on a share
#
#    Ian Steel
#    September 2006
#
package nas::fs_updsecurity;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;
use Service::Shares;
use IO::File;
#===============================================================================
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
        
    # List the shares 
    #
    my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
    unless ($smbConf) {
      $self->fatalError($config, 'f00022');
      return;
    }

    # IMPORTANT !!!!!
    #
    # Access Type is to be HARDCODED to 'user' for the time being
    #
    # my $accessType = $smbConf->val('global', 'security');
    my $accessType = 'user';
    
    $self->outputTemplate(
			  'fs_updsecurity.tpl', 
			  {
			   tabon       => 'fileshare',
			   accessType  => $accessType,
			   shares      => $self->getShares($config)
			  } );
  }
}
#===============================================================================
sub stage1($$$) {
  my ($self, $cgi, $config) = @_;

  my $vars = { tabon => 'fileshare' };
    
  my $sharename = $cgi->param('sharename');
    
  # Load a list of all known users (Samba passwd file)
  #
  unless (sudo("$nbin/chmod.sh 0644 " . nasCommon->smbpasswd )) {
    $self->fatalError($config, 'f00020');
    return;
  }
    
  my $allUsers = {};
    
  unless (open(SPW, "<" . nasCommon->smbpasswd ) ) {
    $self->fatalError($config, 'f00005');
    return;
  }
    
  while (<SPW>) {
    $_ =~ /^([^:]+):([\d]+):.+$/;
    my ($uname, $uid) = ($1, $2);
    unless (($uname eq 'root') || ($uname =~ /^sh\d+$/) || ($uname eq 'guest')) {
      $allUsers->{$uname} = $uid;
    }
  }
  close(SPW);

#
# read FTP perms for current share
#

  my %ftp_perm;
  unless (open(FTPACL, "$nbin/ftpacl.pl show_share \"$sharename\" |")) {
    $self->fatalError($config, 'f00042');
    return;
  }
  while (<FTPACL>) {
    chomp();
    for (split(/\n/)) {
      my ($user, $perm) = split(/\|/);
      $ftp_perm{$user} = $perm;
    }
  }
  close(FTPACL);

#
# open smb share include file
#

  my $sharesInc = undef;
  if ( -z nasCommon->shares_inc ) { 
    # empty file so create a new config
    $sharesInc = new Config::IniFiles();
    unless ($sharesInc) {
      $self->fatalError($config, 'f00012');
      return undef;
    }
    $sharesInc->SetFileName(nasCommon->shares_inc);
  } else {
    $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
    unless ($sharesInc) {
      $self->fatalError($config, 'f00012');
      return undef;
    }
  }
    
  my $users = [];
    
  my $name2uid;
  unless ($name2uid = mapNameToUid()) {
    $self->fatalError($config, 'f00004');
    return;
  }
    
  # add the default public user to all users list.
  my $guestUID = $name2uid->{$shareGuest};
  $allUsers->{$shareGuest} =  $guestUID;

  # Determine all full-access users
  #
  foreach my $u (split(/ /, $sharesInc->val($sharename, 'write list'))) {
    if (exists $name2uid->{$u}) {
      push @$users, { uid => $name2uid->{$u}, 
                      name => $u eq $shareGuest ? getMessage($config, 'm11020') : $u, 
                      smb_perm => 'f',
		      ftp_perm => $ftp_perm{$u}
		    };
      delete($allUsers->{$u});
    }
  }

  # Determine all read-only users
  #
  foreach my $u (split(/ /, $sharesInc->val($sharename, 'read list'))) {
    if (exists $name2uid->{$u}) {
      push @$users, { uid => $name2uid->{$u}, 
                      name => $u eq $shareGuest ? getMessage($config, 'm11020') : $u, 
                      smb_perm => 'r',
		      ftp_perm => $ftp_perm{$u}
		    };
      delete($allUsers->{$u});
    }
  }

  # all users which remain in allUsers are 'none' access
  #
  foreach my $u (keys %$allUsers) {
    push @$users, { uid => $allUsers->{$u},   
		    name => $u eq $shareGuest ? getMessage($config, 'm11020') : $u, 
		    smb_perm => 'n',
		    ftp_perm => $ftp_perm{$u}
		  };
  }

  ###    my @usersSorted = sort { $a->{name} cmp $b->{name} } @$users;
  my @usersSorted = sort { 
    if ($a->{name} eq getMessage($config, 'm11020')) {
      -1;
    } elsif ($b->{name} eq getMessage($config, 'm11020')) {
      1;
    } else {
      $a->{name} cmp $b->{name};
    }
  } @$users;
  ###  
  $vars->{users}    = \@usersSorted;
  $vars->{frm}->{sharename}  = $cgi->param('sharename');
  $vars->{frm}->{accessType} = $cgi->param('accessType');

  $self->outputTemplate( 'fs_updsecurity2.tpl', $vars );
}
#===============================================================================
sub stage2($$$) {
  my ($self, $cgi, $config) = @_;
    
  my $vars  = { tabon => 'fileshare' };
  # my $error = 0;
    
  my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
  unless ($smbConf) {
    $self->fatalError($config, 'f00022');
    return;
  }

  # IMPORTANT !!!!!
  #
  # Access Type is to be HARDCODED to 'user' for the time being
  #
  # my $accessType = $smbConf->val('global', 'security');
  my $accessType = 'user';
    
  my $sharename = $cgi->param('sharename');
  # my $pword1    = $cgi->param('pword1');
  # my $pword2    = $cgi->param('pword2');            
  # my $ecode;
    
  # if ($accessType ne 'user') 
  # {
  #     my $ecode = nasCommon::getPasswordError( $pword1, $pword2 );
  #     if ( $ecode )
  #     {
  #         nasCommon::setErrorMessage( $vars, $config, 'pword1', $ecode );
  #         $error = 1;
  #     }
  # }
    
  # if ($error) 
  # {
  #     copyFormVars($cgi, $vars);
  #     $vars->{shares} = $self->getShares($config);
  #     $self->outputTemplate('fs_updsecurity.tpl', $vars);
  #     return;
  # }
    
  my $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
  if (!$sharesInc->SectionExists($sharename)) {
    $self->fatalError($config, 'f00024');
    return;
  }
    
  if ($accessType eq 'user') {    
    my $uid2name;
    unless ($uid2name = mapUidToName()) {
      $self->fatalError($config, 'f00004');
      return;
    }
    
    # for the share, pick up each user/perm variable and add to appropriate perms list.
    # Update the Samba share config
    #
    my @smb_allPubUsers = ();
    my @smb_allUsers    = ();
    my @smb_fullUsers   = ();
    my @smb_roUsers     = ();

    my @ftp_allPubUsers = ();
    my @ftp_allUsers    = ();
    my @ftp_fullUsers   = ();
    my @ftp_roUsers     = ();
        
    my $smb_publicAccess = 'n';
    my $ftp_publicAccess = 'n';

    my $mpnt = $sharesInc->val($sharename,'path');
    $mpnt =~ s,/$sharename$,,;
    foreach my $p ($cgi->param()) {
      if ($p =~ /^u_(\d+)_smb_perm$/) {
	my $uid = $1;
	my $uname = $uid2name->{$uid};
                
	unless ($uname) {
	  $self->fatalError($config, 'f00018');
	  return;
	}
                
	if ($uname eq $shareGuest) {
	  # Note public access level requested
	  #
	  $smb_publicAccess = $cgi->param($p);
	} else {
	  push @smb_allPubUsers, $uname;
	  push @smb_allUsers, $uname unless ($cgi->param($p) eq 'n');
	  push @smb_fullUsers, $uname if ($cgi->param($p) eq 'f');
	  push @smb_roUsers, $uname if ($cgi->param($p) eq 'r');
	}
      } elsif ($p =~ /^u_(\d+)_ftp_perm$/) {
	my $uid = $1;
	my $uname = $uid2name->{$uid};
	unless ($uname) {
	  $self->fatalError($config, 'f00018');
	  return;
	}
                
	my $ftpperm = $cgi->param($p);
	if ($ftpperm eq 'f') {
	  ludo("$nbin/ftpacl.pl full \"$uname\" \"$sharename\"");
	} elsif ($ftpperm eq 'r') {
	  ludo("$nbin/ftpacl.pl read \"$uname\" \"$sharename\"");
	} elsif ($ftpperm eq 'n') {
	  ludo("$nbin/ftpacl.pl none \"$uname\" \"$sharename\"");
	} else {
	  $self->fatalError($config, 'f00041');
	  return;
	}
      }
    }
        
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
    } else {
      # Remove any existing guest access
      #
      $sharesInc->delval($sharename, 'guest ok');

      # Ensure there's still a user listed, but without a pwd so that Samba
      # does not default to granting access to anyone.
      push @smb_allUsers, $shareGuest;
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

    unless ($sharesInc->RewriteConfig) {
      $self->fatalError($config, 'f00013');
      return;
    }
        
    #        unless (sudo("$nbin/restartSamba.sh")) 
    #        {
    #            $self->fatalError($config, 'f00017');
    #            return;
    #        }
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
  } # else {
  #   if ($pword1 ne '') {        
  #     # For password protection we need to either assign a new username; or find the currently
  #     # assigned username for the share and change that users password.
  #     #
  #     my $username = $sharesInc->val($sharename, 'username');
  #     if ($username) {    
  # 	# Just change the password for the existing user
  # 	#
  # 	unless (sudo("$nbin/fs_chgPasswd.sh $username '$pword1'")) 
  # 	  {
  # 	    $self->fatalError($config, 'f00014');
  # 	    return;
  # 	  }
  #     } else {
        
  # 	# Generate a new username and assign password
  # 	#
  # 	$username = 'sh' . `date +%s`;
  # 	chomp $username;
                
  # 	unless (sudo("$nbin/fs_addUser.sh $username '$pword1'")) 
  # 	  {
  # 	    $self->fatalError($config, 'f00014');
  # 	    return;
  # 	  }
                
  # 	$sharesInc->newval($sharename, 'username', $username);
  # 	$sharesInc->newval($sharename, 'valid users', $username);
  # 	$sharesInc->newval($sharename, 'public', 'no');
                
  # 	# Save the Samba config and restart Samba
  # 	#
  # 	unless ($sharesInc->RewriteConfig) 
  # 	  {
  # 	    $self->fatalError($config, 'f00013');
  # 	    return;
  # 	  }
        
  # 	#                unless (sudo("$nbin/restartSamba.sh")) 
  # 	#                {
  # 	#                    $self->fatalError($config, 'f00017');
  # 	#                    return;
  # 	#                }
  # 	unless (sudo("$nbin/reconfigSamba.sh")) {
  # 	  $self->fatalError($config, 'f00034');
  # 	  return;
  # 	}

    
  #     }
  #   } else {
  #     # Make this share publically accessible
  #     #
            
  #     # If there is a user already assigned to this share (for private access) - delete the
  #     # user.
  #     #
  #     my $username = $sharesInc->val($sharename, 'username');
  #     if ($username) {
  # 	my $name2uid = mapNameToUid();
  # 	my $uid = $name2uid->{$username};
            
  # 	# Just change the password for the existing user
  # 	#
  # 	if ($uid) {
  # 	  unless (sudo("$nbin/fs_delUser.sh $username")) 
  # 	    {
  # 	      $self->fatalError($config, 'f00025');
  # 	      return;
  # 	    }
  # 	}
  #     }
            
  #     $sharesInc->delval($sharename, 'username');
  #     $sharesInc->delval($sharename, 'valid users');
  #     $sharesInc->newval($sharename, 'public', 'yes');
            
  #     # Save the Samba config and restart Samba
  #     #
  #     unless ($sharesInc->RewriteConfig)
  # 	{
  # 	  $self->fatalError($config, 'f00013');
  # 	  return;
  # 	}

  #     #            unless (sudo("$nbin/restartSamba.sh")) 
  #     #            {
  #     #                $self->fatalError($config, 'f00017');
  #     #                return;
  #     #            }
  #     unless (sudo("$nbin/reconfigSamba.sh")) {
  # 	$self->fatalError($config, 'f00034');
  # 	return;
  #     }
  #   }
  # }
    
  #print $cgi->redirect('/auth/fileshare.pl');
  my $vars = { tabon => 'fileshare' };
  $vars->{frm}->{sharename} = $cgi->param('sharename');
  $self->outputTemplate( 'fs_updsecurity3.tpl', $vars ); 

}
1;
