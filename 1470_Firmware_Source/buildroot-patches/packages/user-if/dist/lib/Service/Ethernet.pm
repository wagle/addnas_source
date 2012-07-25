#!/usr/bin/env perl
# Class   : Service::Ethernet.pm
# Purpose : Access for ethernet stats. 
# Author  : B.James
# Date    : $Date: $
# Version : $Revision :$
#

=pod

=head1 DESCRIPTION

Service::Ethernet - Access Ethernet information

=head1 SYNOPSIS

my $eth = new Service::Ethernet();

my $speed = $eth->speed();	# 10/100baseT
my $gw    = $eth->gw();		# 192.168.1.250
my $status = $eth->status();	# UP | DOWN

=head1 DESCRIPTION

This class provides an interface to various OS commands such as
ifconfig and netstat. It is used to gather information and present it
as an OO accessor interface.

=cut

package Service::Ethernet;

use nasCommon;
use SysCmd;
use IO::File;

# Cache for interface data
our $DATA;


sub new {
	my $class=shift;
	my $this={};
	bless $this, $class;

	# Set the ethernet port we are working on..
	my $interface = shift || die( "Please specify an ethernet interface." );

	# Initialise the cache for this interface if necessary
	$DATA->{$interface}={ interface=> $interface } unless $DATA->{$interface};

	# Fetch cached data for this interface
	$this->{data} = $DATA->{$interface};

	# Fetch the status
	$this->collect();

	return $this;
}

sub collect {
	# Collect data from various sources and update the object
	my $this=shift;

	# Extract most of the info from ifconfig.
	my $fd = new IO::File( SysCmd->ifconfig." ".$this->{data}->{interface}."|" );
	while (<$fd>) {
		chomp;
		#print( ":$_:\n" );
		(/inet addr:(\S+)/) && 	($this->{data}->{address}=$1);
		(/\s(UP|DOWN)/) && 	($this->{data}->{status}=$1);
	}

	# Determine the default gateway
	# NB. This will be the first 'default' gateway found in the results.
	# There have been sightings of more than 1 default!
	my $fd = new IO::File( SysCmd->netstat." -rn |" );
	my $gw='';
	while (<$fd>) {
		chomp;
		(/^\s*default\s+(\S+)/) && ($gw = $1);
		(/^\s*0.0.0.0\s+(\S+)/) && ($gw = $1);
	}
	$this->{data}->{gw}=$gw;

	# Determine the link speed for eth0
	# Bruce - removed caching of speed. Aparrently not an issue now.
#	unless( $this->{data}->{speed} ) {
		my $fd = new IO::File( 'sudo '.SysCmd->ethtool." ".$this->{data}->{interface}."|" );
		my $speed;
		while (<$fd>) {
			(/speed:\s+(\S+)/i) && ($speed=$1);
		}
		$this->{data}->{speed}=$speed;
#	}

	return 1;
}

sub address {
	my $this=shift;
	return $this->{data}->{address} || '?';
}
sub speed {
	my $this=shift;
	return $this->{data}->{speed} || '?';
}

sub gw {
	my $this=shift;
	return $this->{data}->{gw} || '';
}

sub status {
	my $this=shift;
	return $this->{data}->{status} || '?';
}

1;
