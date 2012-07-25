#!/usr/bin/perl
#
# Class  : nas::dm_progress
# Purpose: Display progress of disk format progress
# Author : $Author: $
# Version: $revision: $
# Date   : $Date: $
#
package nas::dm_progress;
use strict;

use base 'nasCore';
use nasCommon;
use Service::Shares;
our $LOCK=0;

sub main($$$) {
	my ($self, $cgi, $config) = @_;

	# If mkext is still in the process table, put up the progress message
	my $msg;
	if (-r nasCommon->nas_lock ) {
		# Format in progress
		$msg = getMessage($config, 'm16014');
		$LOCK=1;
	} else {	
		# No format in progress - must have finished
		$msg=getMessage($config, 'm16015');
    }

	$self->outputTemplate('dm_progress.tpl',
		{       tabon => 'driveman',
			head => '<META HTTP-EQUIV="Refresh" content="60;URL=/auth/dm_progress.pl">',
			message => $msg,
		}
	);

#	$self->outputSubTemplate( 'dm_progress.tpl', 
#		{ message => $msg }
#	);

}

1;
