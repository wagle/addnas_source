
package nas::gensetup;

use Exporter;
@ISA=qw(nasCore);

use strict;
use warnings;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	my $error;
	my $drives = $config->val('general', 'drives');
        if ( -r '/tmp/dm_progress' ) {
                # Process is already running.
		print $cgi->redirect( '/auth/dm_progress.pl' );
		return;
	}

	$self->outputTemplate('gensetup.tpl', {
		tabon => 'general',
		error => $error,
		type  => $config->val('general','system_type'),
	});
}

1;
