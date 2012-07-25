#!/usr/bin/perl
#
# Class  : nas::ajax_time
# Purpose: Returns date and time
# Author : $Author: $
# Version: $revision: $
# Date   : $Date: $
#
package nas::ajax_time;
use strict;

use base 'nasCore';
use nasCommon;

sub main($$$) {
	my ($self, $cgi, $config) = @_;

	# Outputs the NAS time for display in the home pages.
	my $msg=`/bin/date "+%A, %B %d, %Y / %l:%M%P %Z"`;

	$self->outputSubTemplate( 'ajax.tpl', 
		{ data => $msg }
	);

}

1;
