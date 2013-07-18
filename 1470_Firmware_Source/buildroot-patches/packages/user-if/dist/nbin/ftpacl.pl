#!/usr/local/bin/perl -I/usr/www/lib
# above doesn't work with env

use strict;
use warnings;

# @ISA=qw(Exporter);
# @EXPORT = qw(doConsole ftpMakeSchema ftpInsertUser ftpDeleteUser ftpUpsertUserToFULL ftpUpsertUserToREAD ftpUpsertUserToNONE);
# use Exporter;

use nasCommon;
use IPC::Filter qw(filter);

my $SQL = '/usr/bin/sqlite3';
my $DBASE = '/var/oxsemi/proftpd.sqlite3';
my $ALIASES = '/var/oxsemi/proftpd.vrootaliases';
my $HIDDENS = '/var/oxsemi/proftpd.hiddens';
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
# sub dumpQuery {
#   my ($output, $exitcode) = @_;
#   return "output=$output, exitcode=$exitcode";
# }
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
# sub doConsole {
#   my $msg = shift;
#   my ($output, $exitcode) = filter($msg, "tee /dev/console");
#   return ($output, $exitcode);
# }
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub doQuery {
  my $query = shift;
  my ($output, $errout, $exitcode) = filter($query, "$SQL $DBASE");
  open(my $con, "> /dev/console");
  print $con "query:\n", $query;
  print $con "output:\n", $output;
  print $con "errout:\n", $errout;
  print $con "exitcode:\n", $exitcode, "\n";
  close $con;
  exit 1 if $exitcode != 0;
  chomp($output);
  return (split(/\n/,$output));
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpMakeSchema () {
  my $query = <<EOF;
 	BEGIN TRANSACTION;
	DROP TABLE IF EXISTS ftpacl;
	CREATE TABLE ftpacl (
		mpnt TEXT,
		path TEXT NOT NULL,
		user TEXT NOT NULL,
		hidden TEXT NOT NULL,
		overall TEXT NOT NULL,
		read_acl TEXT NOT NULL,
		write_acl TEXT NOT NULL,
		delete_acl TEXT NOT NULL,
		create_acl TEXT NOT NULL,
		modify_acl TEXT NOT NULL,
		move_acl TEXT NOT NULL,
		view_acl TEXT NOT NULL,
		navigate_acl TEXT NOT NULL,
		UNIQUE(mpnt, path, user)
		);
	CREATE INDEX ftpacl_mpnt_idx ON ftpacl (mpnt);
	CREATE INDEX ftpacl_path_idx ON ftpacl (path);
	CREATE INDEX ftpacl_user_idx ON ftpacl (user);
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpInsertUser ($) {
  my ($user) = @_;
  my $query = <<EOF;
	BEGIN TRANSACTION;
	INSERT INTO ftpacl
		( mpnt, path , user    , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	 VALUES ( NULL, "/"  , "$user" , "no"  , "read" , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpDeleteUser ($) {
  my ($user) = @_;
  my $query = <<EOF;
	DELETE FROM ftpacl WHERE user = "$user";
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToFULL ($$$) {
  my ($user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
		 ( mpnt   , path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "no"  , "f"    , "allow" , "allow"  , "allow"   , "allow"   , "allow"   , "allow" ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToREAD ($$$) {
  my ($user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , path     , user  , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "no" , "r"    , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToNONE ($$$) {
  my ($user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "yes" , "n"    , "deny"  , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,   "deny", "deny"       )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpRemoveShare ($$) {
  my ($mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share";
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpShowAccessToShare ($) {
  my ($share) = @_;
  my $query .= <<EOF;
	SELECT user, overall FROM ftpacl WHERE path = "/$share" ;
EOF
  my @output = doQuery($query);
  for my $line (@output) {
    print $line, "\n";
  }
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub FTPACL_SHARE_QUERY() {
  my $query = <<EOF;
    select distinct mpnt,path from ftpacl where mpnt is not NULL;
EOF
  return $query;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub FTPACL_HIDDEN_SHARE_QUERY() {
  my $query = <<EOF;
      select distinct mpnt,path,user from ftpacl where mpnt is not NULL and hidden = "yes";
EOF
  return $query;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ALIASES_TOP_TEMPLATE($$) {
  my ($mpnt, $share) = @_;
  my $template .= <<EOF;
VRootAlias $mpnt/$share /$share
EOF
  return $template;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub HIDDENS_HEAD_TEMPLATE() {
  my $template .= <<EOF;
<Directory />
EOF
  return $template;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub HIDDENS_BODY_TEMPLATE($$) {
  my ($sharelist, $user) = @_;
  my $template = <<EOF;
  HideFiles "($sharelist)" user $user
EOF
  return $template;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub HIDDENS_TAIL_TEMPLATE() {
  my $template .= <<EOF;
  <Limit ALL>
    IgnoreHidden on
  </Limit>
</Directory>
EOF
  return $template;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
# rebuild ftp aliases config file
# rebuild ftp hiddens config file
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpRebuildConfigs () {
  my $aliases = "";
  foreach (doQuery(FTPACL_SHARE_QUERY())) {
    my ($mpnt, $share) = split(/\|/);
    $share =~ s,^/,,;  # strip leading "/"
    $aliases .= ALIASES_TOP_TEMPLATE($mpnt, $share);
  }
  my $hiddens = "";
  my @output = doQuery(FTPACL_HIDDEN_SHARE_QUERY());
  if (scalar @output != 0) {
    $hiddens .= HIDDENS_HEAD_TEMPLATE();
    my %user2hidden;
    foreach (@output) {
      my ($mpnt, $share, $user) = split(/\|/);
      $share =~ s,^/,,;  # strip leading "/"
      if (exists $user2hidden{$user}) {
	$user2hidden{$user} .= "|$share"
      } else {
	$user2hidden{$user} = "$share"
      }
    }
    for my $user (keys %user2hidden) {
      $hiddens .= HIDDENS_BODY_TEMPLATE($user2hidden{$user}, $user);
    }
    $hiddens .= HIDDENS_TAIL_TEMPLATE();
  }
  open(my $file1, "> $ALIASES");
  print $file1 $aliases;
  close $file1;
  open(my $file2, "> $HIDDENS");
  print $file2 $hiddens;
  close $file2;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
# populate new (post-upgrade) ftp acl database from /var/private/smbpasswd and /var/oxsemi/shares.inc
# -- different error handling regime, so I couldn't DontRepeatYourself
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpRepopulateDatabase () {
  ###
  ### Load a list of all known users (Samba passwd file)
  ###
  my $allUsers = {};
  return unless (sudo("$nbin/chmod.sh 0644 " . nasCommon->smbpasswd ));
  return unless (open(SPW, "<" . nasCommon->smbpasswd));
  while (<SPW>) {
    $_ =~ /^([^:]+):([\d]+):.+$/;
    my ($uname, $uid) = ($1, $2);
    unless (($uname eq 'root') || ($uname =~ /^sh\d+$/) || ($uname eq 'guest')) {
      ftpInsertUser($uname);
      $allUsers->{$uname} = $uid;
    }
  }
  close(SPW);

  ###
  ### open smb share include file, and walk thrugh shares
  ###
  my $sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
  return unless $sharesInc;

  foreach my $sharename ($sharesInc->Sections()) {
    chomp $sharename;
    my $mpnt = $sharesInc->val($sharename,'path');
    $mpnt =~ s,/$sharename$,,;

    foreach my $uname (keys %$allUsers) {
      ftpUpsertUserToNONE($uname, $mpnt, $sharename);
    }
  }

  ftpRebuildConfigs();
  return unless (sudo("$nbin/rereadFTPconfig.sh"));
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
if (@ARGV == 1 && $ARGV[0] eq "init") {
  ftpMakeSchema();
} elsif (@ARGV == 2 && $ARGV[0] eq "add") {
  ftpInsertUser($ARGV[1]);
} elsif (@ARGV == 2 && $ARGV[0] eq "del") {
  ftpDeleteUser($ARGV[1]);
} elsif (@ARGV == 4 && $ARGV[0] eq "full") {
  ftpUpsertUserToFULL($ARGV[1], $ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "read") {
  ftpUpsertUserToREAD($ARGV[1], $ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "none") {
  ftpUpsertUserToNONE($ARGV[1] ,$ARGV[2], $ARGV[3]);
} elsif (@ARGV == 1 && $ARGV[0] eq "rebuild") {
  ftpRebuildConfigs();
} elsif (@ARGV == 1 && $ARGV[0] eq "repopulate") {
  ftpRepopulateDatabase();
} elsif (@ARGV == 3 && $ARGV[0] eq "remove_share") {
  ftpRemoveShare($ARGV[1] ,$ARGV[2]);
} elsif (@ARGV == 2 && $ARGV[0] eq "show") {
  ftpShowAccessToShare($ARGV[1]);
} else {
  open(my $con, "> /dev/console");
  print $con "usage:\n";
  print STDERR "usage:\n";
  for my $av (@ARGV) {
    print $con "  ", $av, "\n";
    print STDERR "  ", $av, "\n";
  }
  close $con;
  print STDERR "ftpacl init\n";
  print STDERR "ftpacl add <user>\n";
  print STDERR "ftpacl del <user>\n";
  print STDERR "ftpacl full <user> <mpnt> <share>\n";
  print STDERR "ftpacl read <user> <mpnt> <share>\n";
  print STDERR "ftpacl none <user> <mpnt> <share>\n";
  print STDERR "ftpacl show <share>\n";
  exit 1;
}
exit 0;
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
