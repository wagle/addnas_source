#
#    File Share - Change the security on a share
#
#    Ian Steel
#    September 2006
#
package nas::fs_updsecurity;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;
use Service::Shares;
use IO::File;

sub main($$$) {

    my ($self, $cgi, $config) = @_;

    {
        if ($cgi->param('nextstage') == 1) {
            $self->stage1($cgi, $config);
            last;
        }
        
        if ($cgi->param('nextstage') == 2) {
            $self->stage2($cgi, $config);
            last;
        }
        
        # List the shares 
        #
        my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
        unless ($smbConf) 
        {
            $self->fatalError($config, 'f00022');
            return;
        }
    
        my $accessType = $smbConf->val('global', 'security');
    
        # IMPORTANT !!!!!
        #
        # Access Type is to be HARDCODED to 'user' for the time being
        #
        my $accessType = 'user';
    
        $self->outputTemplate(
            'fs_updsecurity.tpl', 
            {
                tabon       => 'fileshare',
                accessType  => $accessType,
                shares      => $self->getShares($config)
            } );
      }
}

sub stage1($$$) {
    my ($self, $cgi, $config) = @_;

    my $vars = { tabon => 'fileshare' };
    
    my $sharename = $cgi->param('sharename');
    
    # Load a list of all known users (Samba passwd file)
    #
    unless (sudo("$nbin/chmod.sh 0644 " . nasCommon->smbpasswd )) {
        $self->fatalError($config, 'f00020');
        return;
    }
    
    unless (open(SPW, "<" . nasCommon->smbpasswd ) ) {
        $self->fatalError($config, 'f00005');
        return;
    }
    
    my $allUsers = {};
    
    while (<SPW>) 
    {
        $_ =~ /^([^:]+):([\d]+):.+$/;
        my ($uname, $uid) = ($1, $2);
        unless (($uname eq 'root') || ($uname =~ /^sh\d+$/) || ($uname eq 'guest')) 
        {
              $allUsers->{$uname} = $uid;
        }
    }
    close(SPW);
    
    my $sharesInc = undef;
    if ( -z nasCommon->shares_inc ) 
    { 
        # empty file so create a new config
        $sharesInc = new Config::IniFiles();
        unless ($sharesInc) 
        {
            $self->fatalError($config, 'f00012');
            return undef;
        }
        $sharesInc->SetFileName(nasCommon->shares_inc);
    } 
    else 
    {
        $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
        unless ($sharesInc) {
            $self->fatalError($config, 'f00012');
            return undef;
        }
    }
    
    my $users = [];
    
    my $name2uid;
    unless ($name2uid = mapNameToUid()) {
        $self->fatalError($config, 'f00004');
        return;
    }
    
    # add the default public user to all users list.
    my $guestUID = $name2uid->{$shareGuest};
    $allUsers->{$shareGuest} =  $guestUID;
    
    # Determine all full-access users
    #
    foreach my $u (split(/ /, $sharesInc->val($sharename, 'write list')))
    {
        if (exists $name2uid->{$u}) 
        {
            push @$users, { uid => $name2uid->{$u}, 
                      name => $u eq $shareGuest ? getMessage($config, 'm11020') : $u, 
                      perm => 'f' };
            delete($allUsers->{$u});
        }
    }
    
    # Determine all read-only users
    #
    foreach my $u (split(/ /, $sharesInc->val($sharename, 'read list'))) {
    if (exists $name2uid->{$u}) {
      push @$users, { uid => $name2uid->{$u}, 
                      name => $u eq $shareGuest ? getMessage($config, 'm11020') : $u, 
                      perm => 'r' };
      delete($allUsers->{$u});
    }
    }
    
    # all users which remain in allUsers are 'none' access
    #
    foreach my $u (keys %$allUsers) {
      push @$users, { uid => $allUsers->{$u},   
                      name => $u eq $shareGuest ? getMessage($config, 'm11020') : $u, 
                      perm => 'n' };
    }

###    my @usersSorted = sort { $a->{name} cmp $b->{name} } @$users;
	my @usersSorted = sort { 
                if ($a->{name} eq getMessage($config, 'm11020')) {
                        -1;
                } elsif ($b->{name} eq getMessage($config, 'm11020')) {
                        1;
                } else {
                        $a->{name} cmp $b->{name};
                }
        } @$users;
###  
    $vars->{users}    = \@usersSorted;
    $vars->{frm}->{sharename}  = $cgi->param('sharename');
    $vars->{frm}->{accessType} = $cgi->param('accessType');

    $self->outputTemplate( 'fs_updsecurity2.tpl', $vars ); 
    
}





sub stage2($$$) {

    my ($self, $cgi, $config) = @_;
    
    my $vars  = { tabon => 'fileshare' };
    my $error = 0;
    
    my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
    unless ($smbConf) {
        $self->fatalError($config, 'f00022');
        return;
    }
    
    my $accessType = $smbConf->val('global', 'security');
    
    # IMPORTANT !!!!!
    #
    # Access Type is to be HARDCODED to 'user' for the time being
    #
    my $accessType = 'user';
    
    my $sharename = $cgi->param('sharename');
    my $pword1    = $cgi->param('pword1');
    my $pword2    = $cgi->param('pword2');            
    my $ecode;
    
    if ($accessType ne 'user') 
    {
        my $ecode = nasCommon::getPasswordError( $pword1, $pword2 );
        if ( $ecode )
        {
            nasCommon::setErrorMessage( $vars, $config, 'pword1', $ecode );
            $error = 1;
        }
    }
    
    if ($error) 
    {
        copyFormVars($cgi, $vars);
        $vars->{shares} = $self->getShares($config);
        $self->outputTemplate('fs_updsecurity.tpl', $vars);
        return;
    }
    
    my $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
    if (!$sharesInc->SectionExists($sharename)) 
    {
        $self->fatalError($config, 'f00024');
        return;
    }
    
    if ($accessType eq 'user') 
    {    
        my $uid2name;
        unless ($uid2name = mapUidToName()) 
        {
            $self->fatalError($config, 'f00004');
            return;
        }
    
        # for the share, pick up each user/perm variable and add to appropriate perms list.
        # Update the Samba share config
        #
        my @allPubUsers = ();
        my @allUsers    = ();
        my @fullUsers   = ();
        my @roUsers     = ();
        
        my $publicAccess = 'n';
        
        foreach my $p ($cgi->param()) 
        {
            if ($p =~ /^u_(\d+)_perm$/) 
            {
                my $uid = $1;
                my $uname = $uid2name->{$uid};
                
                unless ($uname) 
                {
                    $self->fatalError($config, 'f00018');
                    return;
                }
                
                if ($uname eq $shareGuest) 
                {
                    # Note public access level requested
                    #
                    $publicAccess = $cgi->param($p);
                } 
                else 
                {
                    push @allPubUsers, $uname;
                    push @allUsers, $uname unless ($cgi->param($p) eq 'n');
                    push @fullUsers, $uname if ($cgi->param($p) eq 'f');
                    push @roUsers, $uname if ($cgi->param($p) eq 'r');
                }
            }
        }
        
        #
        if ($publicAccess ne 'n') 
        {
            $sharesInc->newval($sharename, 'guest ok', 'Yes');
            @allUsers = @allPubUsers;
            push @allUsers, $shareGuest;
            
            if ($publicAccess eq 'r') 
            {
                # Read only users are all those valid users who are NOT to have specific full access,
                #   plus www-data (guest)
                #
                @roUsers = grep { my $ret = 1;
                          foreach my $u (@fullUsers) {
                            if ($u eq $_) {
                              $ret = 0;
                            }
                          }
                          $ret;
                        } @allPubUsers;
                push @roUsers, $shareGuest;    
            }
        
            if ($publicAccess eq 'f') 
            {
                # Full users are all the valid users plus www-data (guest). The logic here is that
                # if you have granted Public write access, there is no way to give someone specifically
                # readonly access as all they have to do is connect as someone else.
                #
                @fullUsers = @allUsers;
                @roUsers = ();
            }
        } 
        else 
        {
            # Remove any existing guest access
            #
            $sharesInc->delval($sharename, 'guest ok');

	    # Ensure there's still a user listed, but without a pwd so that Samba
	    # does not default to granting access to anyone.
            push @allUsers, $shareGuest;
        }
        
        if (@allUsers) 
        {
            $sharesInc->newval($sharename, 'valid users', join(' ', @allUsers)) if (@allUsers);
        } 
        else 
        {
            $sharesInc->delval($sharename, 'valid users');
        }
        
        if (@fullUsers) 
        {
            $sharesInc->newval($sharename, 'write list', join(' ', @fullUsers)) if (@fullUsers);
        } 
        else 
        {
            $sharesInc->delval($sharename, 'write list');
        }
        
        if (@roUsers) 
        {
            $sharesInc->newval($sharename, 'read list', join(' ', @roUsers)) if (@roUsers);
        } 
        else 
        {
            $sharesInc->delval($sharename, 'read list');
        }
        
        unless ($sharesInc->RewriteConfig) 
        {
            $self->fatalError($config, 'f00013');
            return;
        }
        
#        unless (sudo("$nbin/restartSamba.sh")) 
#        {
#            $self->fatalError($config, 'f00017');
#            return;
#        }
        unless (sudo("$nbin/reconfigSamba.sh")) {
            $self->fatalError($config, 'f00034');
            return;
        }
    } 
    else 
    {
        if ($pword1 ne '') 
        {        
            # For password protection we need to either assign a new username; or find the currently
            # assigned username for the share and change that users password.
            #
            my $username = $sharesInc->val($sharename, 'username');
            if ($username) 
            {    
                # Just change the password for the existing user
                #
                unless (sudo("$nbin/fs_chgPasswd.sh $username '$pword1'")) 
                {
                    $self->fatalError($config, 'f00014');
                    return;
                }
            }
            else 
            {
        
                # Generate a new username and assign password
                #
                $username = 'sh' . `date +%s`;
                chomp $username;
                
                unless (sudo("$nbin/fs_addUser.sh $username '$pword1'")) 
                {
                    $self->fatalError($config, 'f00014');
                    return;
                }
                
                $sharesInc->newval($sharename, 'username', $username);
                $sharesInc->newval($sharename, 'valid users', $username);
                $sharesInc->newval($sharename, 'public', 'no');
                
                # Save the Samba config and restart Samba
                #
                unless ($sharesInc->RewriteConfig) 
                {
                    $self->fatalError($config, 'f00013');
                    return;
                }
        
#                unless (sudo("$nbin/restartSamba.sh")) 
#                {
#                    $self->fatalError($config, 'f00017');
#                    return;
#                }
                unless (sudo("$nbin/reconfigSamba.sh")) {
                    $self->fatalError($config, 'f00034');
                    return;
                }

    
            }
        } 
        else 
        {
            # Make this share publically accessible
            #
            
            # If there is a user already assigned to this share (for private access) - delete the
            # user.
            #
            my $username = $sharesInc->val($sharename, 'username');
            if ($username) 
            {
                my $name2uid = mapNameToUid();
                my $uid = $name2uid->{$username};
            
                # Just change the password for the existing user
                #
                if ($uid) 
                {
                    unless (sudo("$nbin/fs_delUser.sh $username")) 
                    {
                        $self->fatalError($config, 'f00025');
                        return;
                    }
                }
            }
            
            $sharesInc->delval($sharename, 'username');
            $sharesInc->delval($sharename, 'valid users');
            $sharesInc->newval($sharename, 'public', 'yes');
            
            # Save the Samba config and restart Samba
            #
            unless ($sharesInc->RewriteConfig)
            {
                $self->fatalError($config, 'f00013');
                return;
            }

#            unless (sudo("$nbin/restartSamba.sh")) 
#            {
#                $self->fatalError($config, 'f00017');
#                return;
#            }
            unless (sudo("$nbin/reconfigSamba.sh")) {
                $self->fatalError($config, 'f00034');
                return;
            }
        }
    }
    
    #print $cgi->redirect('/auth/fileshare.pl');
    my $vars = { tabon => 'fileshare' };
    $vars->{frm}->{sharename} = $cgi->param('sharename');
    $self->outputTemplate( 'fs_updsecurity3.tpl', $vars ); 

}
1;
