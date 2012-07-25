
package nas::drive_info;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon;

sub main($$$) {
	
	my ($self, $cgi, $config) = @_;

	my %drives = ();

	for (`cat /proc/mounts`){ ### <device_name> <mount_point> <fs_type> <options> 0 0

		chomp;
		if(/^\/dev/){
			my @dat = split /\s+/, $_;
			$drives{$dat[0]}{$dat[1]}{type} = $dat[2];
			my $diskdevice = $dat[0];
			$diskdevice =~ s,^/dev/(...)[\d+]$,$1,;
			$drives{$dat[0]}{$dat[1]}{vendor} = `cat /sys/block/$diskdevice/device/vendor`;
			$drives{$dat[0]}{$dat[1]}{model} = `cat /sys/block/$diskdevice/device/model`;
		}
	}

	for (`df`){
		chomp;
		if(/^\/dev/){
			my @dat = split /\s+/, $_;
			$drives{$dat[0]}{$dat[5]}{size} = $dat[1];
			$drives{$dat[0]}{$dat[5]}{used} = $dat[2];
			$drives{$dat[0]}{$dat[5]}{avail} = $dat[3];
			$drives{$dat[0]}{$dat[5]}{pct} = $dat[4];
		}
	}

	my $table = "<tr><th nowrap=\"nowrap\">".join("</th><th nowrap=\"nowrap\">",
				(
					"Device",
					"Vendor",
					"Model",
					"Mount Point",
					"Type",
					"Size",
					"Used",
					"Available",
					"% Used"
				)
				);

	for my $dr (sort keys %drives){
		my $ind = 0;
		for my $part (keys %{$drives{$dr}}){
			my @p = split /\//, $part;
			$table .= "<tr><td nowrap=\"nowrap\">";
		       	$table .= join("</td><td nowrap=\"nowrap\">",
				(	
					(split('/',$dr))[2],
					$drives{$dr}{$part}{vendor},
					$drives{$dr}{$part}{model},
					$p[3], 
					$drives{$dr}{$part}{type},
					int($drives{$dr}{$part}{size}/1000)." MB",
					int($drives{$dr}{$part}{used}/1000)." MB",
					int($drives{$dr}{$part}{avail}/1000)." MB",
					$drives{$dr}{$part}{pct}
				));
			$table .= "\n";
		}
	}

	$self->outputTemplate('drive_info.tpl', {tabon => 'general', info_table => $table});
}

1;
