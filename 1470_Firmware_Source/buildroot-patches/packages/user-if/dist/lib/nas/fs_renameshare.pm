#
#	File Share - Renames an existing share
#
#	Ian Steel
#	September 2006
#
package nas::fs_renameshare;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	if ($cgi->param('nextstage') == 1) {
		# Rename the share
		$self->stage1($cgi, $config);
		return;
	}

	# Display the initial page
	$self->outputTemplate('fs_renameshare.tpl', { tabon => 'fileshare',
            shares => [ grep( $_->{name} !~ /^public$/i,  @{ $self->getShares($config) } )  ]
	} );
}

sub stage1() {
	my ($self, $cgi, $config) = @_;

	# Check we can successfuly open smb conf file
	my $smbConf = new Config::IniFiles(-file => nasCommon->shares_inc);
	unless ($smbConf) {
		$self->fatalError($config, 'f00013');
		return;
	}

	# Select the filesharing tab for display
	my $vars = { tabon => 'fileshare' };

	# Copy the form data into our local storage
	copyFormVars($cgi, $vars);

	# Copy list of shares into our local storage
	$vars->{shares} = $self->getShares($config);

        # Convert the new share name to uppercase UTF-8
        my $utf8new_sharename = uc Encode::decode("utf8", $vars->{frm}->{new_sharename});

	# Check that the new share name is valid and not a duplicate
	my $error = nasCommon::validateSharename($utf8new_sharename, $vars->{shares});
	if ($error) {
		nasCommon::setErrorMessage($vars, $config, 'new_sharename', $error);
		$self->outputTemplate('fs_renameshare.tpl', $vars);
		return;
	}

	# Make sure new share does not already exist in the smb.conf file
	if ($smbConf->SectionExists($utf8new_sharename)) {
		nasCommon::setErrorMessage($vars, $config, 'new_sharename', 'e12003');
		$self->outputTemplate('fs_renameshare.tpl', $vars);
		return;
	}

	# Process the share names in internal format from now on
        my $sharename = $vars->{frm}->{sharename};
        my $new_sharename = Encode::encode("utf8", $utf8new_sharename);

	# Only do this if the share is shared by cifs
	if ($smbConf->SectionExists($sharename)) {
		# Add the new share
		$smbConf->AddSection($new_sharename);

		# Duplicate the existing samba entry, but alter the path and name
		foreach my $p ($smbConf->Parameters($sharename)) {
			if ($p eq 'path') {
				my $path = $smbConf->val($sharename, $p);
				my $changedpath = $path;
				$changedpath =~ s/$sharename/$new_sharename/g;
				if ($path =~ /$sharesHome\/internal\/.+$/) {
					# An internal share so we must rename the diretory to keep in line with share name
					$smbConf->newval($new_sharename, 'path', $changedpath);
				} else {
					# As this is an external share, do NOT change the name of the underlying directory
					$smbConf->newval($new_sharename, 'path', $changedpath);
					my ($errcode,$errmessage) = checkForFilenameCaseBraindamage($changedpath);
					if ( $errcode ) {
						$self->fatalError($config, $errcode, $errmessage);
						return;
					}
				}
				# Rename the directory on the disk
				unless (sudo("$nbin/renameShare.sh $path $changedpath")) {
					$self->fatalError($config, 'f00021');
					return;
				}
			} else {
				# Copy all the other parameters over
				$smbConf->newval($new_sharename, $p, $smbConf->val($sharename, $p));
			}
		}

		# Delete the old share
		$smbConf->DeleteSection($sharename);

		ludo("$nbin/ftpacl.pl rename_share \"$sharename\" \"$new_sharename\"");

		unless ($smbConf->RewriteConfig) {
			$self->fatalError($config, 'f00013');
			return;
		}
		unless (sudo("$nbin/reconfigSamba.sh")) {
			$self->fatalError($config, 'f00034');
			return;
		}
		unless (ludo("$nbin/ftpacl.pl rebuild_configs")) {
		  	$self->fatalError($config, 'f00039');
		  	return;
		}
		unless (sudo("$nbin/rereadFTPconfig.sh")) {
		  	$self->fatalError($config, 'f00040');
		  	return;
		}

	} else {
		$self->fatalError($config, "Existing share $sharename not found in smb.conf");
		return;
	}

	print $cgi->redirect('/auth/fileshare.pl');
}

1;
