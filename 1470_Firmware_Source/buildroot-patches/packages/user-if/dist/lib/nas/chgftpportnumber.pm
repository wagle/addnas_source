#
#	Change change FTP port number
#
package nas::chgftpportnumber;

use Exporter;
@ISA=qw(nasCore);

use strict;
use Errno qw(EAGAIN);

use nasCommon;
use Config::Tiny;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		if ($cgi->param('nextstage') == 1) {
			$self->stage1($cgi, $config);
			last;
		}

		my $vars = { tabon => 'general',
                             frm => { ftpportnumber => `/etc/init.d/proftpd.sh get_port`},
                           };

		$self->outputTemplate('chgftpportnumber.tpl', $vars );
	}
}

#
#	Ensure ftp port number is fit for purpose
#
sub stage1($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'general' };
	my $error = 0;

	# Get the port number from the form
	my $ftpportnumber = $cgi->param('ftpportnumber');

        # Convert the device name to UTF-8 for validity checking
        my $utf8ftpportnumber = Encode::decode("utf8", $ftpportnumber);

	# Check that the device name is valid
	$error = nasCommon::validateFtpportnumber($utf8ftpportnumber);
	if ($error) {
		copyFormVars($cgi, $vars);
		nasCommon::setErrorMessage($vars, $config, 'ftpportnumber', $error);
		$self->outputTemplate('chgftpportnumber.tpl', $vars);
		return;
	}

	sudo("/etc/init.d/proftpd.sh set_port " . $utf8ftpportnumber);

        $self->outputTemplate('chgftpportnumber1.tpl', { tabon => 'general' });


}

1;
