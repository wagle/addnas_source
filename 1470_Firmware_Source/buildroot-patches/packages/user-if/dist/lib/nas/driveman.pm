#!/usr/bin/env perl
#
# Program : driveman.pm
# Purpose : Handler for drive management page
#
package nas::driveman;

use base( 'nasCore' );
use strict;
use warnings;

=pod

=head1 NAME

nas::driveman - Page handler for drive management page

=head1 SYNOPSIS

new nas::driveman->processRequest();

=head1 DESCRIPTION

=head2 Buttons

CGI Parameters sent by buttons.

=over

=item b_drivetype

Parameter set when the 'Set Drive Type' button is pressed.

=item b_formatInternal

Parameter set when the 'Format Internal Drive' button is pressed.

=item b_formatExternal

Parameter set when the 'Format External Drive' button is pressed.

=back

=cut


sub main($$$) {

	my ($self, $cgi, $config) = @_;

	my $error;
	my $drives = $config->val('general', 'drives');
        if ( -r nasCommon->nas_lock ) {
                # Process is already running.
		print $cgi->redirect( '/auth/dm_progress.pl' );
                return;
	}

	# DEFAULT
	$self->outputTemplate('driveman.tpl', { 
		tabon => 'driveman',
		error => $error,
		type  => $config->val('general','system_type'),
	});
}

1;
