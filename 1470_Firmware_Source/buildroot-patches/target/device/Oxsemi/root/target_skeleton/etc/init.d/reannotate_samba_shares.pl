#!/usr/local/bin/perl

# should be named "optimize_samba_share_configs.pl"

package wagle::reannotate_samba_shares;

use strict;

use Config::IniFiles;

my $sharesInc = undef;
$sharesInc = new Config::IniFiles( -file => "/var/oxsemi/shares.inc" );

my %fstype;
my %fstransport;
for (`cat /proc/mounts`) {
	chomp;
        my ($dev,$mpnt,$fstype) = split /\s+/;
	if ( $dev =~ m,^/dev/, ) {
		$fstype{$mpnt} = $fstype;
		my $scsi = $dev;
		$scsi =~ s,^/dev/,,;
		$scsi =~ s,\d+$,,;
		my $modalias = `cat /sys/block/$scsi/../../../../../modalias`;
		if ( $modalias =~ "platform:oxnassata" ) {
			$fstransport{$mpnt} = "esata";
		} else {
			$modalias = `cat /sys/block/$scsi/../../../../../../../../modalias`;
			if ( $modalias =~ "platform:oxnas-ehci" ) {
				$fstransport{$mpnt} = "usb";
			} else {
				$fstransport{$mpnt} = "unknown";
			}
		}
#		print "dev $dev mpnt $mpnt fstype $fstype transport $fstransport{$mpnt}\n";
	}
}

my $share = undef;
for $share ( $sharesInc->Sections ) {
	my $xfs = 0;
	my $fstransport = "unavailable";
	my $path = $sharesInc->val($share,'path');
	my $tcreatedir = $path;
	$tcreatedir =~ s,^/shares,,;
	system "/usr/www/nbin/makeSharedir.sh $tcreatedir";  ### to chown and chmod
	for my $mpnt ( keys %fstype ) {
		if ( $path eq "$mpnt/$share" ) {
			if ( $fstype{$mpnt} eq "xfs" ) {
				$fstransport = $fstransport{$mpnt};
				$xfs = 1;
				last;
			}
		}
	}
	$sharesInc->delval($share, 'preallocate');               
	$sharesInc->delval($share, 'incoherent');                        
	$sharesInc->delval($share, 'direct writes');                                                                                
	if ( $xfs ) {
		if ( $fstransport eq "esata" ) {
			$sharesInc->newval($share, 'preallocate', 'yes');
			$sharesInc->newval($share, 'incoherent', 'yes');
			$sharesInc->newval($share, 'direct writes', '2');
		} elsif ( $fstransport eq "usb" ) {
			$sharesInc->newval($share, 'preallocate', 'yes');
		} else {
			print stderr "unknown transport\n";
		}
	}
#	print "$share $path\n";
}
unless ($sharesInc->RewriteConfig) {
	print stderr "couldn't rewrite samba config file\n";
	exit 1;
}

exit 0;
