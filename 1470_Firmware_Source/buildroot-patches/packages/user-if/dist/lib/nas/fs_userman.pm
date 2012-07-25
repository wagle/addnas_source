#
#	File Share - User Management
#
#	Ian Steel
#	September 2006
#
package nas::fs_userman;

use Exporter;
use  Service::Shares;
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

        my ( $usersSorted, $errormesg ) = Service::Shares->getSortedlUsers();
        if ( $errormesg )
        {
           $self->fatalError( $config, $errormesg );
           return;
        }
        
		my $vars = { tabon => 'fileshare', users => $usersSorted };

		$self->outputTemplate('fs_userman.tpl', $vars );
	}

}

#
#	Ensure username and password are fit for purpose
#
sub stage1($$$) {

	my ($self, $cgi, $config) = @_;

	my ( $usersSorted, $errormesg ) = Service::Shares->getSortedlUsers();
	if ( $errormesg ) {
		# can't get users!
		$self->fatalError( $config, $errormesg );
		return;
	}
        
	my $vars = { tabon => 'fileshare', users => $usersSorted };

	my $uid = $cgi->param('uid');
	my $pword1 = $cgi->param('pword1');
	my $pword2 = $cgi->param('pword2');

        # Get a lookup of uid to username
        my $uid2name = mapUidToName();

        if (!$uid) {
                print $cgi->redirect('/auth/fs_userman.pl');
                return;
        }

	# Lookup username from uid
	my $username = $uid2name->{$uid};

	if ($username) {
		# Go ahead and change password
		$errormesg = nasCommon::getPasswordError( $pword1, $pword2 );
		if ( $errormesg )
		{
			# bad password...
			copyFormVars($cgi, $vars);

			nasCommon::setErrorMessage( $vars, $config, 'pword1', $errormesg );
			$self->outputTemplate('fs_userman.tpl', $vars);
			return;
		}

		# Its good to go....
		$config->setval('shares', 'access_type', $cgi->param('new_level'));
		$config->RewriteConfig;

		# Change the password in smbpasswd
		unless (sudo("$nbin/fs_chgPasswd.sh '$username' '$pword1'")) {
			$self->fatalError($config, 'f00014');
			return;
		}
		$self->outputTemplate('fs_userman1.tpl', { tabon => 'fileshare' });
	} else {
		# No username found
                print $cgi->redirect('/auth/fs_userman.pl');
                return;
	}
}

1;
