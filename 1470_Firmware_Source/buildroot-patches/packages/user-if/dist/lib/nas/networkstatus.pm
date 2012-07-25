#!/usr/bin/perl
#
# Class  : nas::networkstatus
# Purpose: Display a networkstatusing page while a cgi param is set
# Author : $Author: $
# Version: $revision: $
# Date   : $Date: $
#
package nas::networkstatus;
use strict;

use base 'nasCore';
use nasCommon;

sub main($$$) {
	my ($self, $cgi, $config) = @_;

        my $msg;
        if (-r nasCommon->network_lock ) {
		# The network is up and ready
                $msg = getMessage($config, 'm01031');
        } else {
		# Please wait...
		$msg = getMessage($config, 'm01030');
	}

        $self->outputSubTemplate( 'dm_progress.tpl', 
                { message => $msg }
        );
}

1;
