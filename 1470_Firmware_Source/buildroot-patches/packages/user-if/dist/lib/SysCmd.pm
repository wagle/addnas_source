#!/usr/bin/env perl
# Class   : SysCmd.pm
# Purpose : Access for storage stats. 
# Author  : B.James
# Date    : $Date: $
# Version : $Revision :$
#

=pod

=head1 DESCRIPTION

SysCmd - Holds the locations of various system commands used.

=head1 SYNOPSIS

my $ifconfig= 	SysCmd->ifconfig;		# => '/sbin/ifconfig'
my $df= 	SysCmd->df;			# => '/bin/df'
my $netstat= 	SysCmd->netstat;		# => '/bin/netstat'

=head1 DESCRIPTION


=cut

package SysCmd;
use nasCommon;

use constant ifconfig => '/sbin/ifconfig';
use constant df => '/bin/df';
use constant netstat => '/bin/netstat';
use constant ethtool => nasCommon->nas_nbin.'ethtool.sh';
use constant mdadm => nasCommon->nas_nbin.'mdadm.sh';


1;
