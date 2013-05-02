#
#	File Share - Delete user
#
#	Ian Steel
#	September 2006
#
package nas::fs_deluser;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		# Make sure the uid is above 1000 to prevent deleting unix
		# system users.
		unless ($cgi->param('uid') && ($cgi->param('uid')>=1000)) {
			# Don't allow system users below id 1000 to be deleted
			$self->fatalError($config, 'f00027');
			return;
		}

		if ($cgi->param('nextstage') == 1) {
			$self->stage1($cgi, $config);
			return;
		}

		# Show the confirmation page - give the user one last chance
		#
		my $uid2name = mapUidToName();

		$self->outputTemplate('fs_deluser.tpl', { 
			tabon => 'fileshare',
			user => { 
				uid => $cgi->param('uid'),
				name => $uid2name->{$cgi->param('uid')},
			},
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

	my $uid = $cgi->param('uid');

	# Get a lookup of uid to username
	my $uid2name = mapUidToName();

	if (!$uid) {
		print $cgi->redirect('/auth/fs_userman.pl');
		return;
	}

	unless (sudo("$nbin/fs_delUser.sh '$uid2name->{$uid}'")) {
		$self->fatalError($config, 'f00025');
		return;
	}

  # Remove the user from any shares they may have access to
  #
  my $sharesInc = undef;
  if ( -z nasCommon->shares_inc ) { # empty file so create a new config
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

	# Lookup username from uid
  my $username = $uid2name->{$uid};

  if ($username) {

    foreach my $sect ($sharesInc->Sections()) {

      # remove the user from the 3 lists they may exist in
      #
      $sharesInc->newval($sect, 'valid users', join(' ', 
                                  grep { $_ eq $username ? 0 : 1 } 
                                     split(' ', $sharesInc->val($sect, 'valid users'))));
    
      $sharesInc->newval($sect, 'read list', join(' ', 
                                  grep { $_ eq $username ? 0 : 1 } 
                                     split(' ', $sharesInc->val($sect, 'read list'))));
    
      $sharesInc->newval($sect, 'write list', join(' ', 
                                  grep { $_ eq $username ? 0 : 1 } 
                                     split(' ', $sharesInc->val($sect, 'write list'))));
    
    }
  }

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

  unless (system("$nbin/ftpacl.pl del $username") {
    $self->fatalError($config, 'f00037');
    return;
  }

  unless (system("$nbin/ftpacl.pl rebuild)) {
    $self->fatalError($config, 'f00038');
    return;
  }
  unless (sudo("$nbin/rereadFTPconfig.sh")) {
    $self->fatalError($config, 'f00038');
    return;
  }

  print $cgi->redirect('/auth/fs_userman.pl');
}

1;
