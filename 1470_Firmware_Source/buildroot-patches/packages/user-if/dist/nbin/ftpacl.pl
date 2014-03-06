#!/usr/local/bin/perl -I/usr/www/lib
# above doesn't work with env

use strict;
use warnings;

# @ISA = qw(Exporter);
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
	DROP TABLE IF EXISTS partitioninfo;
	CREATE TABLE partitioninfo (
		mpnt TEXT NOT NULL,
		avail TEXT NOT NULL,
		UNIQUE(mpnt)
		);
	CREATE INDEX partitioninfo_mpnt_idx ON partitioninfo (mpnt);
	DROP TABLE IF EXISTS wdisklist;
	CREATE TABLE wdisklist (
		mpnt TEXT UNIQUE NOT NULL,
		path TEXT UNIQUE NOT NULL
		);
	CREATE INDEX wdisklist_mpnt_idx ON wdisklist (mpnt);
	CREATE INDEX wdisklist_path_idx ON wdisklist (path);
	DROP TABLE IF EXISTS sharelist;
	CREATE TABLE sharelist (
		mpnt TEXT NOT NULL,
		path TEXT UNIQUE NOT NULL,
		UNIQUE(mpnt,path)
		);
	CREATE INDEX sharelist_mpnt_idx ON sharelist (mpnt);
	CREATE INDEX sharelist_path_idx ON sharelist (path);
	DROP TABLE IF EXISTS ftpacl;
	CREATE TABLE ftpacl (
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
	CREATE INDEX ftpacl_path_idx ON ftpacl (path);
	CREATE INDEX ftpacl_user_idx ON ftpacl (user);
	CREATE TRIGGER wdisk_uniqueness_1 BEFORE INSERT ON wdisklist FOR EACH ROW
		BEGIN
			SELECT CASE
				WHEN ((SELECT mpnt FROM sharelist WHERE sharelist.mpnt == new.mpnt) IS NOT NULL)
				THEN RAISE(ABORT, 'Cant add whole disk share regime to shared folders.')
			END;
		END; 
	CREATE TRIGGER wdisk_uniqueness_2 BEFORE INSERT ON sharelist FOR EACH ROW
		BEGIN
			SELECT CASE
				WHEN ((SELECT mpnt FROM wdisklist WHERE wdisklist.mpnt == new.mpnt) IS NOT NULL)
				THEN RAISE(ABORT, 'Cant add share folder to whole disk share regime.')
			END;
		END; 
	CREATE TRIGGER sharename_uniqueness_1 BEFORE INSERT ON wdisklist FOR EACH ROW
		BEGIN
			SELECT CASE
				WHEN ((SELECT path FROM sharelist WHERE sharelist.path == new.path) IS NOT NULL)
				THEN RAISE(ABORT, 'Cant add duplicate sharename to shared folders.')
			END;
		END; 
	CREATE TRIGGER sharename_uniqueness_2 BEFORE INSERT ON sharelist FOR EACH ROW
		BEGIN
			SELECT CASE
				WHEN ((SELECT path FROM wdisklist WHERE wdisklist.path == new.path) IS NOT NULL)
				THEN RAISE(ABORT, 'Cant add duplicate sharename to wholedisk shares.')
			END;
		END; 
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
sub ftpAddUser ($) {
  my ($user) = @_;
  my $query = <<EOF;
	BEGIN TRANSACTION;
	INSERT INTO ftpacl
		( path , user    , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	 VALUES ( "/"  , "$user" , "no"  , "r"    , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
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
sub ftpUpsertUserToFULL ($$) {
  my ($user, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE path = "/$share" and user = "$user";
	INSERT INTO ftpacl
		 ( path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "/$share", "$user", "no"  , "f"    , "allow" , "allow"  , "allow"   , "allow"   , "allow"   , "allow" ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToREAD ($$) {
  my ($user, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "/$share", "$user", "no"  , "r"    , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpUpsertUserToNONE ($$) {
  my ($user, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( path     , user   , hidden, overall, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "/$share", "$user", "yes" , "n"    , "deny"  , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,   "deny", "deny"       )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpDestroyPartition ($) {
  my ($mpnt) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE path IN (SELECT path FROM sharelist WHERE mpnt = "$mpnt");
	DELETE FROM ftpacl WHERE path IN (SELECT path FROM wdisklist WHERE mpnt = "$mpnt");
	DELETE FROM sharelist WHERE mpnt = "$mpnt";
	DELETE FROM wdisklist WHERE mpnt = "$mpnt";
	DELETE FROM partitioninfo WHERE mpnt = "$mpnt";
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpEnablePartition ($) {
  my ($mpnt) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM partitioninfo WHERE mpnt = "$mpnt";
	INSERT INTO partitioninfo
		 ( mpnt   , avail )
          VALUES ( "$mpnt", "yes"  )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpDisablePartition ($) {
  my ($mpnt) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	UPDATE partitioninfo SET avail = 'no' WHERE mpnt = "$mpnt";
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpResetAllPartitions () {
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	UPDATE partitioninfo SET avail = 'no';
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpCreateNormalShare ($$) {
  my ($mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	INSERT INTO sharelist
		 ( mpnt   , path      )
          VALUES ( "$mpnt", "/$share" )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpCreateWholeDiskShare ($$) {
  my ($mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	INSERT INTO wdisklist
		 ( mpnt   , path      )
          VALUES ( "$mpnt", "/$share" )
	;
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpShowTypeOfShare ($) {
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
sub ftpRenameShare ($$) {
  my ($old_share_name, $new_share_name) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	UPDATE sharelist SET path = "/$new_share_name" WHERE path = "/$old_share_name";
	UPDATE wdisklist SET path = "/$new_share_name" WHERE path = "/$old_share_name";
	UPDATE ftpacl    SET path = "/$new_share_name" WHERE path = "/$old_share_name";
	COMMIT;
EOF
  return doQuery($query);
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub ftpRemoveShare ($) {
  my ($share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM sharelist WHERE path = "/$share";
	DELETE FROM wdisklist WHERE path = "/$share";
	DELETE FROM ftpacl WHERE path = "/$share";
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
    SELECT distinct partitioninfo.mpnt, wdisk, path
	FROM partitioninfo JOIN pathlist ON partitioninfo.mpnt = pathlist.mpnt;
EOF
  return $query;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub FTPACL_DISABLED_DISK_QUERY() {
  my $query = <<EOF;
	SELECT distinct path
		FROM partitioninfo JOIN pathlist ON partitioninfo.mpnt = pathlist.mpnt
		WHERE avail = "no";
EOF
  return $query;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub FTPACL_HIDDEN_SHARE_QUERY() {
  my $query = <<EOF;
	SELECT distinct partitioninfo.mpnt,ftpacl.path,user 
		FROM partitioninfo JOIN pathlist JOIN ftpacl ON partitioninfo.mpnt = pathlist.mpnt and pathlist.path = ftpacl.path
		WHERE hidden = "yes";
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
sub HIDDENS_BODY_DISABLED_SHARES_TEMPLATE($) {
  my ($sharelist) = @_;
  my $template = <<EOF;
  HideFiles "($sharelist)"
EOF
  return $template;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
sub HIDDENS_BODY_DISABLED_USER_TEMPLATE($$) {
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
  my @disabled_shares_results = doQuery(FTPACL_DISABLED_DISK_QUERY());
  my @hidden_shares_results = doQuery(FTPACL_HIDDEN_SHARE_QUERY());
  if (scalar @disabled_shares_results != 0 || scalar @hidden_shares_results != 0) {
    my %disabled_share;
    $hiddens .= HIDDENS_HEAD_TEMPLATE();
    if (scalar @disabled_shares_results != 0) {
      foreach (@disabled_shares_results) {
	s,^/,,;	# strip leading "/"
	$disabled_share{$_} = 1;  # dont double disable below
      }
      $hiddens .= HIDDENS_BODY_DISABLED_SHARES_TEMPLATE(join(" ", keys %disabled_share));
    }
    if (scalar @hidden_shares_results != 0) {
      my %user2hidden;
      foreach (@hidden_shares_results) {
        my ($mpnt, $path, $user) = split(/\|/);
	my $share = $path;
	$share =~ s,^/,,;	# strip leading "/"
	if (exists $disabled_share{$share}) {
	  ;
	} elsif (exists $user2hidden{$user}) {
	  $user2hidden{$user} .= "|$share"
	} else {
	  $user2hidden{$user} = "$share"
	}
      }
      for my $user (keys %user2hidden) {
        my $share = $user2hidden{$user};
        $hiddens .= HIDDENS_BODY_DISABLED_USER_TEMPLATE($share, $user);
      }
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
      ftpUpsertUserToNONE($uname, $sharename);
    }
  }

  ftpRebuildConfigs();
  return unless (sudo("$nbin/rereadFTPconfig.sh"));
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
if      (@ARGV == 1 && $ARGV[0] eq "init") {				ftpMakeSchema();
} elsif (@ARGV == 1 && $ARGV[0] eq "upgrade_to_v89") {			ftpConvert_pre_v89_Schema_to_v89();
} elsif (@ARGV == 1 && $ARGV[0] eq "upgrade_from_v89_to_v91") {		ftpConvert_v89_Schema_to_v91();
} elsif (@ARGV == 2 && $ARGV[0] eq "add_user") {			ftpAddUser($ARGV[1]);
} elsif (@ARGV == 2 && $ARGV[0] eq "del_user") {			ftpDeleteUser($ARGV[1]);
} elsif (@ARGV == 3 && $ARGV[0] eq "full") {				ftpUpsertUserToFULL($ARGV[1], $ARGV[2]);
} elsif (@ARGV == 3 && $ARGV[0] eq "read") {				ftpUpsertUserToREAD($ARGV[1], $ARGV[2]);
} elsif (@ARGV == 3 && $ARGV[0] eq "none") {				ftpUpsertUserToNONE($ARGV[1] ,$ARGV[2]);
} elsif (@ARGV == 1 && $ARGV[0] eq "rebuild_configs") {			ftpRebuildConfigs();
} elsif (@ARGV == 1 && $ARGV[0] eq "repopulate") {			ftpRepopulateDatabase();
} elsif (@ARGV == 3 && $ARGV[0] eq "create_normal_share") {		ftpCreateNormalShare($ARGV[1], $ARGV[2]);
} elsif (@ARGV == 3 && $ARGV[0] eq "create_wholedisk_share") {		ftpCreateWholeDiskShare($ARGV[1], $ARGV[2]);
} elsif (@ARGV == 3 && $ARGV[0] eq "rename_share") {			ftpRenameShare($ARGV[1], $ARGV[2]);
} elsif (@ARGV == 2 && $ARGV[0] eq "remove_share") {			ftpRemoveShare($ARGV[1]);
} elsif (@ARGV == 2 && $ARGV[0] eq "destroy_partition") {		ftpDestroyPartition($ARGV[1]);
} elsif (@ARGV == 2 && $ARGV[0] eq "enable_partition") {		ftpEnablePartition($ARGV[1]);
} elsif (@ARGV == 2 && $ARGV[0] eq "disable_partition") {		ftpDisablePartition($ARGV[1]);
} elsif (@ARGV == 1 && $ARGV[0] eq "reset_all_partitions") {		ftpResetAllPartitions();
} elsif (@ARGV == 2 && $ARGV[0] eq "show_share") {			ftpShowAccessToShare($ARGV[1]);
} else {
  open(my $con, "> /dev/console");
  print $con "usage:\n";
  print STDERR "usage:\n";
  for my $av (@ARGV) {
    print $con "  ", $av, "\n";
    print STDERR "  ", $av, "\n";
  }
  close $con;
  print STDERR "$0 init\n";
  print STDERR "$0 upgrade_to_v89\n";
  print STDERR "$0 upgrade_from_v89_to_v91\n";
  print STDERR "$0 add_user <user>\n";
  print STDERR "$0 del_user <user>\n";
  print STDERR "$0 full <user> <share>\n";
  print STDERR "$0 read <user> <share>\n";
  print STDERR "$0 none <user> <share>\n";
  print STDERR "$0 rebuild_configs\n";
  print STDERR "$0 repopulate\n";
  print STDERR "$0 create_normal_share <mpnt> <share>\n";
  print STDERR "$0 create_wholedisk_share <mpnt> <share>\n";
  print STDERR "$0 rename_share <old_share> <new_share>\n";
  print STDERR "$0 remove_share <share>\n";
  print STDERR "$0 destroy_partition <mpnt>\n";
  print STDERR "$0 enable_partition <mpnt>\n";
  print STDERR "$0 disable_partition <mpnt>\n";
  print STDERR "$0 reset_all_partitions\n";
  print STDERR "$0 show_share <share>\n";
  exit 1;
}
exit 0;
#-------------------------------------------------------------------------------------------------------------------------------------------------------#
