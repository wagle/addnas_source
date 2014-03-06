#
#	File Share - Add new user
#
#	Ian Steel
#	September 2006
#
package nas::fs_newuser;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;
# use nasFTP;

sub main($$$) {
  my ($self, $cgi, $config) = @_;
  {
    if ($cgi->param('nextstage') == 1) {
      $self->stage1($cgi, $config);
      last;
    }
    #
    # List the shares and allow user to choose access level for each
    #
    $self->outputTemplate('fs_newuser.tpl', { tabon => 'fileshare',
                                              shares => $self->getShares($config)
                                            } );
  }
}

#
#	Ensure username and password are fit for purpose
#
sub stage1($$$) {
  my ($self, $cgi, $config) = @_;
  
  my $vars = { tabon => 'fileshare' };
  my $error = 0;

#  my $username = uc $cgi->param('new_username');
  my $username = $cgi->param('new_username');
  my $pword1 = $cgi->param('pword1');
  my $pword2 = $cgi->param('pword2');
  my $usehomedd;
  my $homedd;
  if (-d $config->val('general','userhomebase')) {
    $usehomedd = 1;
  }
  if ($usehomedd) {
    $homedd = $config->val('general','userhomebase')."/".$username;
  }
  my $ecode = nasCommon::getUsernameError($username);
  if ($ecode) {
    nasCommon::setErrorMessage($vars, $config, 'new_username', $ecode);
    $error = 1;
  }
            
  $ecode = nasCommon::getPasswordError($pword1, $pword2);
  if ($ecode) {
    nasCommon::setErrorMessage($vars, $config, 'pword1', $ecode);
    $error = 1;
  }
  #
  # Does this username already exist?
  #
  my $name2uid = mapNameToUid();
  if (exists($name2uid->{$username})) {
    nasCommon::setErrorMessage($vars, $config, 'new_username', 'e10001');
    $error = 1;
  }

  if ($error) {
    copyFormVars($cgi, $vars);
    $vars->{shares} = $self->getShares($config);
    $self->outputTemplate('fs_newuser.tpl', $vars);
    return;
  }
  if ($homedd) {
    unless (sudo("$nbin/fs_addUser.sh '$username' '$pword1' '$homedd'")) {
      $self->fatalError($config, 'f00014');
      return;
    }
  } else {
    unless (sudo("$nbin/fs_addUser.sh '$username' '$pword1'")) {
      $self->fatalError($config, 'f00014');
      return;
    }
  }

  unless (ludo("$nbin/ftpacl.pl add_user \"$username\"")) {
    $self->fatalError($config, 'f00038');
    return;
  }

  #
  # Set the permissions on the shares
  #
  my $smbConf = new Config::IniFiles(-file => nasCommon->shares_inc);
  unless ($smbConf) {
    # inifile cannot be opened. It is probably empty
    # Just ignore this for now.
#   $self->fatalError($config, 'f00031');
#   return;
  }  else {
    # Add the user to each share that permissions are specified for..
    foreach my $p ($cgi->param()) {
      if ($p =~ /sh_(\d+)_name/) {
	my $id = $1;
	my $name = $cgi->param("sh_${id}_name");
	my $smbperm = $cgi->param("sx_${id}_smbperm");
	my $ftpperm = $cgi->param("sy_${id}_ftpperm");

	# Is this share publically accessible?
	my $public = $smbConf->val($name, 'guest ok') =~ /Yes/i;
	# Determine public level of accessibility (irrelevant unless $public is true btw)
	my $pubFull = $smbConf->val($name, 'write list') =~ /.*www-data.*/;

	my $smb_all = $smbConf->val($name, 'valid users');
	my $smb_full = $smbConf->val($name, 'write list');
	my $smb_ro = $smbConf->val($name, 'read list');
	
	if ($public) {
	  # As this share is publically accessible, we have to give the user the maximum access
	  # of either public level or the one requested at user create (this process).
	  $smb_all .= " $username";
	  if ($smbperm eq 'f') {
	    $smb_full .= " $username";
	  } else {
	    # Not f
	    if ($pubFull) {
	      $smb_full .= " $username";
	    } else {
	      $smb_ro .= " $username";
	    }
	  }
	} else {
	  # Not public
	  $smb_all .= " $username" if ($smbperm ne 'n');
	  $smb_full .= " $username" if ($smbperm eq 'f');
	  $smb_ro .= " $username" if ($smbperm eq 'r');
	}
	# Write back users perms
	$smbConf->newval($name, 'valid users', $smb_all);
	$smbConf->newval($name, 'write list', $smb_full);
	$smbConf->newval($name, 'read list', $smb_ro);

	my $mpnt = $smbConf->val($name,'path');
	$mpnt =~ s,/$name$,,;

	if ($ftpperm eq 'f') {
	  # doConsole("ftp perm f");
	  # ftpUpsertUserToFULL($username, $mpnt, $name);
	  ludo("$nbin/ftpacl.pl full \"$username\" \"$name\"");
	} elsif ($ftpperm eq 'r') {
	  # doConsole("ftp perm r");
	  # ftpUpsertUserToREAD($username, $mpnt, $name);
	  ludo("$nbin/ftpacl.pl read \"$username\" \"$name\"");
	} elsif ($ftpperm eq 'n') {
	  # doConsole("ftp perm n");
	  # ftpUpsertUserToNONE($username, $mpnt, $name);
	  ludo("$nbin/ftpacl.pl none \"$username\" \"$name\"");
	} else {
	  $self->fatalError($config, 'f00041');
	  return;
	}
      }
    }
    # Write back the ini file
    unless ($smbConf->RewriteConfig) {
      $self->fatalError($config, 'f00013');
      return;
    }
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
  } # end if smbConf
  # Go back to the userman page
  print $cgi->redirect('/auth/fs_userman.pl');
}

1;
