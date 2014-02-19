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
		avail TEXT,
                wdisk TEXT,
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
sub ftpConvert_pre_v89_Schema_to_v89 () {
  my $query = <<EOF;
	PRAGMA foreign_keys=OFF;
	BEGIN TRANSACTION;
	DROP TABLE ftpacl2;
	CREATE TABLE ftpacl2 (
			mpnt TEXT,
			wdisk TEXT,
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
				UNIQUE(path, user)
		);
	INSERT INTO "ftpacl2" (mpnt,path,user,hidden,overall,read_acl,write_acl,delete_acl,create_acl,modify_acl,move_acl,view_acl,navigate_acl)
	  SELECT * FROM ftpacl;
	UPDATE ftpacl2 SET wdisk = 'no' WHERE mpnt is not NULL and wdisk is NULL;
	CREATE INDEX ftpacl_mpnt_idx ON ftpacl2 (mpnt);
	CREATE INDEX ftpacl_path_idx ON ftpacl2 (path);
	CREATE INDEX ftpacl_user_idx ON ftpacl2 (user);
	DROP TABLE ftpacl;
	ALTER TABLE ftpacl2 RENAME TO ftpacl;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpConvert_v89_Schema_to_v91 () {
  my $query = <<EOF;
	PRAGMA foreign_keys=OFF;
	BEGIN TRANSACTION;
	DROP TABLE ftpacl2;
	CREATE TABLE ftpacl2 (
			mpnt TEXT,
			avail TEXT,
			wdisk TEXT,
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
				UNIQUE(path, user)
		);
	INSERT INTO "ftpacl2" (mpnt,wdisk,path,user,hidden,overall,read_acl,write_acl,delete_acl,create_acl,modify_acl,move_acl,view_acl,navigate_acl)
	  SELECT * FROM ftpacl;
	UPDATE ftpacl2 SET avail = 'yes' WHERE mpnt is not NULL and avail is NULL;
	CREATE INDEX ftpacl_mpnt_idx ON ftpacl2 (mpnt);
	CREATE INDEX ftpacl_path_idx ON ftpacl2 (path);
	CREATE INDEX ftpacl_user_idx ON ftpacl2 (user);
	DROP TABLE ftpacl;
	ALTER TABLE ftpacl2 RENAME TO ftpacl;
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
		( mpnt, avail, wdisk, path , user    , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	 VALUES ( NULL, NULL ,  NULL, "/"  , $user" , "no"  , "read" , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
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
sub ftpUpsertUserToFULL ($$$$) {
  my ($wdisk, $user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
		 ( mpnt   , avail, wdisk   , path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "yes", "$wdisk", "/$share", "$user", "no"  , "f"    , "allow" , "allow"  , "allow"   , "allow"   , "allow"   , "allow" ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToREAD ($$$$) {
  my ($wdisk, $user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , avail, wdisk   , path     , user  , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "yes", "$wdisk", "/$share", "$user", "no" , "r"    , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToNONE ($$$$) {
  my ($wdisk, $user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , avail, wdisk   , path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "yes", "$wdisk", "/$share", "$user", "yes" , "n"    , "deny"  , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,   "deny", "deny"       )
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
    select distinct mpnt, wdisk, path from ftpacl where mpnt is not NULL;
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
sub ALIASES_TOP_WDISK_TEMPLATE($$) {
  my ($mpnt, $share) = @_;
  my $template .= <<EOF;
VRootAlias $mpnt /$share
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
    my ($mpnt, $wdisk, $share) = split(/\|/);
    $share =~ s,^/,,;  # strip leading "/"
    if ($wdisk eq 'yes') {
      $aliases .= ALIASES_TOP_WDISK_TEMPLATE($mpnt, $share);
    } else {
      $aliases .= ALIASES_TOP_TEMPLATE($mpnt, $share);
    }
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
    my $sharewholedisk = !($mpnt =~ m,/$sharename$,);
    $mpnt =~ s,/$sharename$,,;

    foreach my $uname (keys %$allUsers) {
      ftpUpsertUserToNONE($sharewholedisk, $uname, $mpnt, $sharename);
    }
  }

  ftpRebuildConfigs();
  return unless (sudo("$nbin/rereadFTPconfig.sh"));
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
if (@ARGV == 1 && $ARGV[0] eq "init") {
  ftpMakeSchema();
} elsif (@ARGV == 1 && $ARGV[0] eq "upgrade_to_v89") {
  ftpConvert_pre_v89_Schema_to_v89();
} elsif (@ARGV == 1 && $ARGV[0] eq "upgrade_from_v89_to_v91") {
  ftpConvert_v89_Schema_to_v91();
} elsif (@ARGV == 2 && $ARGV[0] eq "add") {
  ftpInsertUser($ARGV[1]);
} elsif (@ARGV == 2 && $ARGV[0] eq "del") {
  ftpDeleteUser($ARGV[1]);
} elsif (@ARGV == 4 && $ARGV[0] eq "full") {
  ftpUpsertUserToFULL('no', $ARGV[1], $ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "read") {
  ftpUpsertUserToREAD('no', $ARGV[1], $ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "none") {
  ftpUpsertUserToNONE('no', $ARGV[1] ,$ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "wd_full") {
  ftpUpsertUserToFULL('yes', $ARGV[1], $ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "wd_read") {
  ftpUpsertUserToREAD('yes', $ARGV[1], $ARGV[2], $ARGV[3]);
} elsif (@ARGV == 4 && $ARGV[0] eq "wd_none") {
  ftpUpsertUserToNONE('yes', $ARGV[1] ,$ARGV[2], $ARGV[3]);
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
