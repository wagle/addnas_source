#
#	File Share - Returns users and associated permissions for a specified share name
#   (used by the AJAX calls from the web front end)
#
#	Ian Steel
#	September 2006
#
package nas::fs_getSharePerms;

use Exporter;
@ISA=qw(nasCore);

use strict;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

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

  while (<SPW>) {
    $_ =~ /^([^:]+):([\d]+):.+$/;
    my ($uname, $uid) = ($1, $2);
    unless (($uname eq 'root') || ($uname =~ /^sh\d+$/) || ($uname eq 'guest')) {
      $allUsers->{$uname} = $uid;
    }
  }
  close(SPW);

  my $sharesInc = undef;
  if ( -z nasCommon->shares_inc ) { # empty file so create a new config
    $sharesInc = new Config::IniFiles();
    unless ($sharesInc) {
      $self->fatalError($config, 'f00012');
      return undef;
    }
    $sharesInc->SetFileName(nasCommon->shares_inc);
  } else {
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
  foreach my $u (split(/ /, $sharesInc->val($sharename, 'write list'))) {
    if (exists $name2uid->{$u}) {
      push @$users, { uid => $name2uid->{$u}, 
                      name => $u eq $shareGuest ? 'Public' : $u, 
                      perm => 'f' };
      delete($allUsers->{$u});
    }
  }

  # Determine all read-only users
  #
  foreach my $u (split(/ /, $sharesInc->val($sharename, 'read list'))) {
    if (exists $name2uid->{$u}) {
      push @$users, { uid => $name2uid->{$u}, 
                      name => $u eq $shareGuest ? 'Public' : $u, 
                      perm => 'r' };
      delete($allUsers->{$u});
    }
  }

  # all users which remain in allUsers are 'none' access
  #
  foreach my $u (keys %$allUsers) {
      push @$users, { uid => $allUsers->{$u},   
                      name => $u eq $shareGuest ? 'Public' : $u, 
                      perm => 'n' };
  }

  my @usersSorted = sort { $a->{name} cmp $b->{name} } @$users;
  

	$self->outputSubTemplate('fs_getSharePerms.tpl', 
        {   users => \@usersSorted
        } );

}

1;
