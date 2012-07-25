#!/usr/bin/perl
#
# Class  : nas::hold
# Purpose: Display a holding page while a cgi param is set
# Author : $Author: $
# Version: $revision: $
# Date   : $Date: $
#
package nas::hold;
use strict;

use base 'nasCore';
use nasCommon;

sub main($$$) {
	my ($self, $cgi, $config) = @_;

	# Display this holding page
	$self->outputTemplate( 'hold.tpl', 
		{ 	tabon => 'home', 
#			originalPage => $cgi->param('originalPage') || $self->{originalPage},
			head => '<META HTTP-EQUIV="Refresh" content="60;URL=home.pl">',
		}
	);
}

1;
