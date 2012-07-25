
package nas::user_info;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon;

sub main($$$) {
	
	my ($self, $cgi, $config) = @_;

	#get the info...
	my @sambainfo = ();
	my @ftpinfo = ();
	my $mlpath = undef;
	my $start = 0;
	for (`/usr/local/samba/bin/smbstatus`){
		chomp;
		if(/^Service/){
			last;
		}
		if(/^PID/){
			$start = 1;
			next;
		}
		if($start && !/^----/){
			s/^\s+//;
			my @dat = split /\s+/, $_;
			next unless @dat;
			$dat[4] =~ s/\(//;
			$dat[4] =~ s/\)//;
			push @sambainfo, "<tr><td>".join("</td><td>",(@dat[1,3,4]))."</td></tr>\n";	
		}
	}
	$start = 0;
	my $usr;
	my $client;
	for (`/usr/sbin/ftpwho -v`){
		chomp;
		if(!$start && /^\s*\d+\s+(\S+)\s+/){
			$usr = $1;
			$start = 1;
		}elsif(/^\s*client:\s*(\S+)\s+/){
			$client = $1;
		}elsif(/^\s*server:/){
			$start = 0;
			push @ftpinfo, "<tr><td>".join("</td><td>",($usr,$client))."</td></tr>\n";
		}
	}

	for(`/bin/ps aux | /bin/grep -v grep | /bin/grep mlnet.static`){
		$mlpath = (`/bin/cat /var/oxsemi/mlpath`)[0];
		chomp $mlpath;
		my @mlp = split '/', $mlpath;
		$mlpath = join('/', ($mlp[-3],$mlp[-2],$mlp[-1]));
		last;
	}
	
	#now generate the html...
	my $output;
	if(@sambainfo){
        	$output = "<h3>Samba</h3>\n";
		$output .= "<table width=\"100%\"><tr><th align=left wrap=\"nowrap\">".join("</th><th align=left nowrap=\"nowrap\">",
				(
					"Username",
					"Host",
					"IP",
				)
				);
		$output .= "</th></tr>";
     		$output .= join("\n",@sambainfo);
		$output .= "</table>\n";
	}

	if(@ftpinfo){
		$output .= "<h3>FTP</h3>\n";
		$output .= "<table width=\"100%\"><tr><th align=left nowrap=\"nowrap\">".join("</th><th align=left nowrap=\"nowrap\">",
				(
					"Username",
					"Client"
				)
				);
     		$output .= join("\n",@ftpinfo);
		$output .= "</table>\n";
	}

	if($mlpath){
		$output .= "<h3>MLDonkey Path</h3>\n";
		$output .= "$mlpath\n";
	}

	$self->outputTemplate('drive_info.tpl', {tabon => 'general', info_table => $output});
}

1;
