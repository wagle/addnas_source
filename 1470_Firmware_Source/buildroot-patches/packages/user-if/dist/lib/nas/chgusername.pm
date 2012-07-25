#
#	Change username and password (for admin purposes)
#
#	Ian Steel
#	September 2006
#
package nas::chgusername;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		my $vars = {tabon => 'general'};
		if ($cgi->param('nextstage') == 1) {
			$self->stage1($cgi, $config);
			return;
		}

		# default
		#
		open(HTD, "<".nasCommon->htdigest_user) or die "Cannot open htdigest file: $!\n";
		my $us = <HTD>;
		close HTD;
		my $i = index $us, ':';
		$vars->{frm}->{pword1} = '';
		$vars->{frm}->{pword2} = '';
		$vars->{frm}->{username} = substr $us, 0, $i;
		$self->outputTemplate('chgusername.tpl', $vars );
	}

}

#
#	Ensure username and password are fit for purpose
#
sub stage1($$$) {
	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'general' };

	my $username = $cgi->param('username');
	my $pword1 = $cgi->param('pword1');
	my $pword2 = $cgi->param('pword2');

	# Validate the username
	my $error = nasCommon::getUsernameError($username);
	if ($error) {
		copyFormVars($cgi, $vars);
		nasCommon::setErrorMessage($vars, $config, 'username', $error);
		$self->outputTemplate('chgusername.tpl', $vars);
		return;
	}

	# Validate the passwords
	$error = nasCommon::getPasswordError($pword1, $pword2);
	if ($error) {
		# Username was ok so copy it back into the form
		$vars->{frm}->{new_username} = $username;

		copyFormVars($cgi, $vars);
		nasCommon::setErrorMessage($vars, $config, 'pword1', $error);
		$self->outputTemplate('chgusername.tpl', $vars);
		return;
	}

	# Flush the pipe immediately
	$|=1;

	$self->outputTemplate('chgusername1.tpl', { tabon => 'general' });

	# Allow time for page to render before applying the changes and
	# restarting the web server
	sleep(2);

	unless (sudo("$nbin/setAdminUser.sh '$username' '$pword1'")) {
		$self->fatalError($config, 'f00009');
		return;
	}
}

1;
