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

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		if ($cgi->param('nextstage') == 1) {
			$self->stage1($cgi, $config);
			last;
		}

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

	my $username = uc $cgi->param('new_username');
	my $pword1 = $cgi->param('pword1');
	my $pword2 = $cgi->param('pword2');
	my $usehomedd;
	my $homedd;
	if (-d $config->val('general','userhomebase')) { $usehomedd = 1; }
	if ($usehomedd) {
		$homedd = $config->val('general','userhomebase')."/".$username;
	}
    my $ecode = nasCommon::getUsernameError( $username );
    if ( $ecode )
    {
        nasCommon::setErrorMessage( $vars, $config, 'new_username', $ecode );
        $error = 1;
    }
            
    $ecode = nasCommon::getPasswordError( $pword1, $pword2 );
    if ( $ecode )
    {
        nasCommon::setErrorMessage( $vars, $config, 'pword1', $ecode );
        $error = 1;
    }
        
  
	# Does this username already exist?
	#
	my $name2uid = mapNameToUid();

	if (exists($name2uid->{$username})) {
		nasCommon::setErrorMessage( $vars, $config, 'new_username', 'e10001' );
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

	# Set the permissions on the shares
	#
	my $smbConf = new Config::IniFiles( -file => nasCommon->shares_inc );
	unless( $smbConf ) {
		# inifile cannot be opened. It is probably empty
		# Just ignore this for now.
#		$self->fatalError($config, 'f00031');
#		return;
	}  else {
		# Add the user to each share that permissions are specified for..
		foreach my $p ($cgi->param()) {
			if ($p =~ /sh_(\d+)_name/) {
				my $id = $1;
				my $name = $cgi->param("sh_${id}_name");
				my $perm = $cgi->param("sh_${id}_perms");

				# Is this share publically accessible?
				my $public = $smbConf->val($name, 'guest ok') =~ /Yes/i;

				# Determine public level of accessibility (irrelevant unless $public is true btw)
				my $pubFull = $smbConf->val($name, 'write list') =~ /.*www-data.*/;
				my $all = $smbConf->val($name, 'valid users');
				my $full = $smbConf->val($name, 'write list');
				my $ro = $smbConf->val($name, 'read list');

				if ($public) {
					# As this share is publically accessible, we have to give the user the maximum access
					# of either public level or the one requested at user create (this process).
					$all .= " $username";
					if ($perm eq 'f') {
						$full .= " $username";
					} else {
						# Not f
						if ($pubFull) {
							$full .= " $username";
						} else {
							$ro .= " $username";
						}
					}

				} else {
					# Not public
					$all .= " $username" if ($perm ne 'n');
					$full .= " $username" if ($perm eq 'f');
					$ro .= " $username" if ($perm eq 'r');
				}
				# Write back users perms
				$smbConf->newval($name, 'valid users', $all);
				$smbConf->newval($name, 'write list', $full);
				$smbConf->newval($name, 'read list', $ro);
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

	} # end if smbConf

	# Go back to the userman page
	print $cgi->redirect('/auth/fs_userman.pl');
}

1;
