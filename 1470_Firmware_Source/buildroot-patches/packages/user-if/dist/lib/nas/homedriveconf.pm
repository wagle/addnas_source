
package nas::homedriveconf;

use Exporter;
@ISA=qw(nasCore);

use Service::Shares;
use strict;

use nasCommon;

sub main($$$) {
	my ($self, $cgi, $config) = @_;
	my $frm = {};
	my $hdpath = $config->val('general','userhomebase');

	if ($cgi->param('dofunc') eq "setdrive") {
		my $volume = $cgi->param('volume');
		my $pathtouse = "$sharesHome/external/$volume/users";
		if ($hdpath) {
			$config->setval('general','userhomebase',$pathtouse);
		} else {
			$config->newval('general','userhomebase',$pathtouse);
		}
		$frm->{hdconfigstatus2}="User home directory base changed.";	
		sudo("$nbin/mkdir.sh $pathtouse");
		sudo("$nbin/chown.sh www-data $pathtouse");
		$hdpath = $pathtouse;

	        my ($usersSorted, $errormesg ) = Service::Shares->getSortedlUsers();
        	if ( $errormesg )
        	{
           		$self->fatalError( $config, $errormesg );
           		return;
        	} else {
			foreach my $user (@$usersSorted) {
				my $username = $user->{name};
				sudo("$nbin/setusersymlink.sh '$username' '$hdpath/$username'");
			}		
		}
                unless ($config->RewriteConfig) {
                        $self->fatalError($config, 'f00013');
                        return;
                }


	}
	my $hdconfigured;
	my $hdpathexists;
	#First lets find out if the path has been configured and is valid
	if ($hdpath =~ /$sharesHome\/external\/.+$/) {
		$hdconfigured = 1;
	}
	if (-d $hdpath) {
		$hdpathexists = 1;
	}
	my @vols = ();
	unless (listExternals(\@vols)) {
		$self->fatalError($config, 'f00026');
		return;
	}

	if ($hdpathexists && $hdconfigured) {
		$frm->{hdconfigstatus} = "Home directories are configured, no changes are needed at this time.<BR>($hdpath)";
	} elsif ($hdconfigured && (!($hdpathexists))) {
		$frm->{hdconfigstatus} = "Home directories are configured, but drive has been removed, please select a new drive or connect the original. <BR>($hdpath)";
		$frm->{showdriveselector} = "1";
	} else {
		$frm->{hdconfigstatus} = "Home directories are not configured and running<BR>($hdpath)";
		$frm->{showdriveselector} = "1";
	}

	$frm->{showdriveselector} = "1";   ### WAGLE do always

	$self->outputTemplate('homedriveconf.tpl', {tabon => 'gensetup', frm => $frm, extvols => \@vols,});
}

1;
