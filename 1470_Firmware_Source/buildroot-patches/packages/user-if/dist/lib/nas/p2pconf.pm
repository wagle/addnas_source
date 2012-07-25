
package nas::p2pconf;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {
	my ($self, $cgi, $config) = @_;
	my $frm={};
    my $sharesInc = undef;
    $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
    unless ($sharesInc) {
        $sharesInc = new Config::IniFiles();
        unless ($sharesInc) {
            $self->fatalError($config, 'f00012');
            return undef;
        }
        $sharesInc->SetFileName(nasCommon->shares_inc);
    }

	if ($cgi->param('dofunc') eq "setdrive") {
		my $sharename="MLD";
		my $sharenameNospaces="MLDonkey";
		my $volume = $cgi->param('volume');

		# if we're creating any internal share, replace spaces with underscores and
		# create the directory
		if ($volume =~ /main/i) {
			my $tcreatedir = "internal/".$sharenameNospaces;
			unless (sudo("$nbin/makeSharedir.sh $tcreatedir")) {
				$self->fatalError($config, 'f00019');
				return;
			}
		} else {
			my $tcreatedir = "external"."/".$volume."/".$sharenameNospaces;
			unless (sudo("$nbin/makeSharedir.sh $tcreatedir")) {
				$self->fatalError($config, 'f00019');
				return;
			}
		}
		# internal and external directories have different top level dir...
		#
		if ($volume =~ /main/i) {
			$sharesInc->newval($sharename, 'path', "$sharesHome/internal/$sharenameNospaces");
			$sharesInc->newval($sharename, 'preallocate', 'Yes');
		} else {
			my $pathtouse = "$sharesHome/external/$volume/$sharenameNospaces";
			open(MC, ">/var/oxsemi/mlpath");
			print MC $pathtouse;
			close MC;
			$sharesInc->AddSection('MLDonkey');
			$sharesInc->newval('MLDonkey', 'path', $pathtouse);
			$sharesInc->newval('MLDonkey', 'force user', 'www-data');
			$sharesInc->newval('MLDonkey', 'veto files', '/.*/ *.ini *.tmp *_tmp /dev /mlnet* /old_config /temp');
		}

		unless ($sharesInc->RewriteConfig) {
			$self->fatalError($config, 'f00013');
			return;
		}
		unless (sudo("$nbin/reconfigSamba.sh")) {
			$self->fatalError($config, 'f00034');
			return;
		}
		$frm->{mlconfigstatus2}="MLDonkey shares created, please set permissions in the share config.";	

	} elsif ($cgi->param('dofunc') eq "START") {
		sudo("$nbin/mlnet.sh start");
	} elsif ($cgi->param('dofunc') eq "STOP") {
		sudo("$nbin/mlnet.sh stop");
	} elsif ($cgi->param('dofunc') eq "RESTART") {
		sudo("$nbin/mlnet.sh restart");
	} elsif ($cgi->param('dofunc') eq "RESETPW") {
		sudo("$nbin/mlnet.sh resetpw");
	}

	#First lets find out if the path has been configured and is valid
	my $mlpath = `cat /var/oxsemi/mlpath`;
	my $mlconfigured;
	my $mlpathexists;
	my $mlsharepath = $sharesInc->val('MLDonkey', 'path');
	if ($mlsharepath =~ /$sharesHome\/external\/.+$/) {
		$mlconfigured=1;
	}
	if (-d $mlpath) {
		$mlpathexists=1;
	}
	my @vols = ();
	unless (listExternals(\@vols)) {
		$self->fatalError($config, 'f00026');
		return;
	}

	if ($mlpathexists && $mlconfigured) {
		$frm->{mlconfigstatus}="MLDonkey is configured and the shares exist.<BR>If you wish to move MLDonkey, please remove the 'MLDonkey' share from the configuration. You will lose all configuration and files!<BR>Please use the mldonkey interface to set a password using the command input box, and be sure never to share the root directory (/)";
	} elsif ($mlconfigured && (!($mlpathexists))) {
		$frm->{mlconfigstatus}="MLDonkey path is configured but drive or share has been removed, please select a new drive";
		$frm->{showdriveselector}="1";
	} else {
		$frm->{mlconfigstatus}="MLDonkey is not configured.";
		$frm->{showdriveselector}="1";
	}

	my $mlpid = `pidof mlnet.static`;
	if ($mlpid) {
		$frm->{mlrunning}=1;
	}
	$self->outputTemplate('p2pconf.tpl', {tabon => 'p2pconf', frm => $frm, extvols => \@vols,});
}

1;
