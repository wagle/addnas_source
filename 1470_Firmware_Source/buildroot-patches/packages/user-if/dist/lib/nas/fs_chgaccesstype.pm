#
#	Change Share Security Level
#
#	Ian Steel
#	September 2006
#
package nas::fs_chgaccesstype;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		if ($cgi->param('nextstage') == 1) {
			$self->stage1($cgi, $config);
			last;
		}

    my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
    unless ($smbConf) {
      $self->fatalError($config, 'f00005');
      return;
    }

		my $vars = { tabon => 'fileshare',
                  current_level => $smbConf->val('global', 'security') eq 'user' ?
                                    getMessage($config, 'm09007') : getMessage($config, 'm09008'),
                  current_level_raw => $smbConf->val('global', 'security')
               };

		$self->outputTemplate('fs_chgaccesstype.tpl', $vars );
	}

}

#
#	Ensure username and password are fit for purpose
#
sub stage1($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'general' };
	my $error = 0;

  my $sambaAccessType = 'user';
  $sambaAccessType = 'share' unless ($cgi->param('new_level') eq 'user');

  # Update the samba server
  #
  my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
  unless ($smbConf) {
    $self->fatalError($config, 'f00005');
    return;
  }
  $smbConf->newval('global', 'security', $sambaAccessType);

  unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->smb_conf )) {
    $self->fatalError($config, 'f00020');
    return;
  }

  unless ($smbConf->RewriteConfig) {
    $self->fatalError($config, 'f00016');
    return;
  }

#  unless (sudo("$nbin/restartSamba.sh")) {
#    $self->fatalError($config, 'f00017');
#    return;
#  }
  unless (sudo("$nbin/reconfigSamba.sh")) {
    $self->fatalError($config, 'f00034');
    return;
  }

	$self->outputTemplate('fs_chgaccesstype1.tpl', { tabon => 'fileshare' });

}

1;
