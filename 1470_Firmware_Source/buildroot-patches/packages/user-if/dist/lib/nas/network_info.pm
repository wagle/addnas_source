#
#	Change change FTP port number
#
package nas::network_info;

use Exporter;
@ISA=qw(nasCore);

use strict;
use Errno qw(EAGAIN);

use nasCommon;
use Config::Tiny;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	my ($hn,$wg,$ts,$sd,$ha,$ip,$gw,$ns) = ('???','???','???','???','???','???','???','???');
	my $cmd = nasCommon->nas_nbin . "/" . "network_get_info.sh";
	foreach (`$cmd`) {
		chomp;
		if (/^HN (.*)$/) { $hn = $1; }; 
                if (/^WG (.*)$/) { $wg = $1; }; 
                if (/^TS (.*)$/) { $ts = $1; }; 
                if (/^SD (.*)$/) { $sd = $1; }; 
                if (/^HA (.*)$/) { $ha = $1; }; 
                if (/^IP (.*)$/) { $ip = $1; }; 
                if (/^GW (.*)$/) { $gw = $1; }; 
                if (/^NS (.*)$/) { $ns = $1; }; 
	}
        my $vars = { tabon => 'general',
                     frm => { hostname    => $hn,
                              workgroup   => $wg,
                              timeservers => $ts,
                              netmode     => $sd,
                              macaddr     => $ha,
                              ipaddr      => $ip,
                              gateway     => $gw,
                              nameservers => $ns,
                            },
                   };

	$self->outputTemplate('network_info.tpl', $vars );
}

1;
