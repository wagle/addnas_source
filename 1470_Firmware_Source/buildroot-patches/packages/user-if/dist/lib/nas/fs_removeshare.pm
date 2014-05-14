#
#	File Share - Removes an existing share and all its files!
#
#	Ian Steel
#	September 2006
#
package nas::fs_removeshare;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

use Data::Dumper;

sub main($$$) {
  my ($self, $cgi, $config) = @_;
  {
    if ($cgi->param('nextstage') == 1) {
      $self->stage1($cgi, $config);
      last;
    }
    #
    # List the shares 
    #
    $self->outputTemplate(
			  'fs_removeshare.tpl', 
			  {
			   tabon  => 'fileshare',
			   shares => [ grep( $_->{name} !~ /^public$/i,  @{ $self->getShares($config) } )  ]
			  } );
  }
}

#
#	Ensure username and password are fit for purpose
#
sub stage1($$$) {

  my ($self, $cgi, $config) = @_;

  my $vars = { tabon => 'fileshare' };
  my $error = 0;
  my $path;
  my $delete_folder_on_disk;

  my $sharename = $cgi->param('sharename');
  my $confirm = $cgi->param('confirm');

  copyFormVars($cgi, $vars);

### open (my $con, "> /dev/console");
### print $con "SUBMIT1! ", "" ne $vars->{frm}->{submit1}, " : ", $vars->{frm}->{sharename}, "\n";
### print $con "SUBMIT2! ", "" ne $vars->{frm}->{submit2}, " : ", $vars->{frm}->{folder}, "\n";
### close $con;

  if ($vars->{frm}->{submit1} ne "") {
    $delete_folder_on_disk = 1;
  } elsif ($vars->{frm}->{submit2} ne "") {
    $delete_folder_on_disk = 0;
  } else {
    nasCommon::setErrorMessage( $vars, $config, 'sharename', 'e13003' );
    $error = 1;
  }

  if ((! $error) && ($sharename eq '')) {
    nasCommon::setErrorMessage( $vars, $config, 'sharename', 'e13002' );
    $error = 1;
  }

  if ((! $error) && ($confirm ne getMessage($config, 'm13005'))) {
    nasCommon::setErrorMessage( $vars, $config, 'confirm', 'e13001' );
    $error = 1;
  }

  if ($error) {
    copyFormVars($cgi, $vars);
    $vars->{shares} = $self->getShares($config);
    $self->outputTemplate('fs_removeshare.tpl', $vars);
    return;
  }

  # Set the CIFS permissions on the shares
  #
  my $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
    
  if ($sharesInc->SectionExists($sharename)) {

    $path = $sharesInc->val($sharename, 'path');
    my $mpnt = $path;
    $mpnt =~ s,/$sharename$,,;

    $sharesInc->DeleteSection($sharename);
        
    unless ($sharesInc->RewriteConfig) {
      $self->fatalError($config, 'f00013');
      return;
    }
    unless (sudo("$nbin/reconfigSamba.sh")) {
      $self->fatalError($config, 'f00034');
      return;
    }

    ludo("$nbin/ftpacl.pl remove_share \"$sharename\"");
    unless (ludo("$nbin/ftpacl.pl rebuild_configs")) {
      $self->fatalError($config, 'f00039');
      return;
    }
    unless (sudo("$nbin/rereadFTPconfig.sh")) {
      $self->fatalError($config, 'f00040');
      return;
    }
  }

  # Remove the unix share directory - but only for internal shares, not external!
  #    if ($path =~ /^$sharesHome\/internal\/.+/) {
  # Take away the top dir prefix. Let the rmShareDir script sort out the full path
  #
  if ($delete_folder_on_disk) {
    my $dirName = $path;
    $dirName =~ s/^$sharesHome\///;
    unless (sudo("$nbin/rmShareDir.sh $dirName")) {
      $self->fatalError($config, 'f00021');
      return;
    }
  }
  #    }

  print $cgi->redirect('/auth/fileshare.pl');

}

1;
