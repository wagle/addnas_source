
package nas::fileshare;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

  # List the existing shares
  #
  unless (sudo("$nbin/chmod.sh 0666 " .  nasCommon->smb_conf )) {
    $self->fatalError($config, 'f00020');
    return;
  }

  my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
  unless ($smbConf) {
    $self->fatalError($config, 'f00022');
    return;
  }

  my $accessType = $smbConf->val('global', 'security');

  if ($smbConf->val('global', 'security') eq 'user') {
    $accessType = 'user';
  } else {
    $accessType = 'pw';
  }

  # IMPORTANT !!!!!
  #
  # Access Type is to be HARDCODED to 'user' for the time being
  #
  my $accessType = 'user';

	$self->outputTemplate('fileshare.tpl', { tabon => 'fileshare',
                                           accessType => $accessType,
                                           shares => $self->getShares($config) } );

}

1;
