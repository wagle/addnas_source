#!/usr/local/bin/perl -I/usr/www/lib
# above doesn't work with env

package wagle::reannotate_samba_shares;

use strict;
use warnings;

# @ISA=qw(Exporter);
# @EXPORT = qw(doConsole ftpMakeSchema ftpInsertUser ftpDeleteUser ftpUpsertUserToFULL ftpUpsertUserToREAD ftpUpsertUserToNONE);
# use Exporter;

use IPC::Filter qw(filter);

my $SQL = '/usr/bin/sqlite3';
my $DBASE = '/var/oxsemi/proftpd.sqlite3';

# sub dumpQuery {
#   my ($output, $exitcode) = @_;
#   return "output=$output, exitcode=$exitcode";
# }

# sub doConsole {
#   my $msg = shift;
#   my ($output, $exitcode) = filter($msg, "tee /dev/console");
#   return ($output, $exitcode);
# }

sub doQuery {
  my $query = shift;
  my ($output, $errout, $exitcode) = filter($query, "$SQL $DBASE");
  open(my $con, "> /dev/console");
  print $con "query:\n", $query;
  print $con "output:\n", $output;
  print $con "errout:\n", $errout;
  print $con "exitcode:\n", $exitcode;
  close $con;
  return ($output, $errout, $exitcode);
}

sub ftpMakeSchema () {
  my $query = <<EOF;
 	BEGIN TRANSACTION;
	DROP TABLE IF EXISTS ftpacl;
	CREATE TABLE ftpacl (
		mpnt TEXT,
		path TEXT NOT NULL,
		user TEXT NOT NULL,
		hidden TEXT NOT NULL,
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

sub ftpInsertUser ($) {
  my ($user) = @_;
  my $query = <<EOF;
	BEGIN TRANSACTION;
	INSERT INTO ftpacl
		( mpnt, path , user    , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	 VALUES ( NULL, "/"  , "$user" , "no"  , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}

sub ftpDeleteUser ($) {
  my ($user) = @_;
  my $query = <<EOF;
	DELETE FROM ftpacl WHERE user = "$user";
EOF
  return doQuery($query);
}

sub ftpUpsertUserToFULL ($$$) {
  my ($user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
		 ( mpnt   , path     , user   , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "no"  , "allow" , "allow"  , "allow"   , "allow"   , "allow"   , "allow" ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}

sub ftpUpsertUserToREAD ($$$) {
  my ($user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , path     , user  , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "no"  , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}

sub ftpUpsertUserToNONE ($$$) {
  my ($user, $mpnt, $share) = @_;
  my $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "/$share" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , path     , user   , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "yes" , "deny"  , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,   "deny", "deny"       )
	;
	COMMIT;
EOF
  return doQuery($query);
}

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
  exit 1;
}
exit 0;

1;
