package nasFTP;

@ISA=qw(Exporter);
@EXPORT = qw(doConsole ftpMakeSchema ftpInsertUser ftpDeleteUser ftpUpsertUserToFULL ftpUpsertUserToREAD ftpUpsertUserToNONE);

use Exporter;
use IPC2::Filter qw(filter);

my $SQL = '/usr/bin/sqlite3';
my $DBASE = '/var/oxsemi/proftpd.sqlite3';

sub doConsole {
  my $msg = shift;
  my ($output, $exitcode) = filter($msg, "tee /dev/console");
  return ($output, $exitcode);
}

sub doQuery {
  my $query = shift;
  my ($output, $exitcode) = filter($query, "$SQL $DBASE");
  return ($output, $exitcode);
}

sub ftpMakeSchema {
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

sub ftpInsertUser ($\@\@) {
  my ($user, $mpntref, $shareref) = @_;
  my @mpnt = @$mpntref;    ### copy it
  my @share = @$shareref;  ### copy it
  $query = <<EOF;
	BEGIN TRANSACTION;
	INSERT INTO ftpacl
		( mpnt, path , user    , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	 VALUES ( NULL, "/"  , "$user" , "no"  , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
EOF
  foreach my $mpnt (@mpnt) {
    my $share = shift(@share);
    $query .= <<EOF;
	INSERT INTO ftpacl
	         ( mpnt   , path     , user   , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "yes" , "deny"  , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,   "deny", "deny"       )
	;
EOF
  }
  $query .= <<EOF;
	COMMIT;
EOF
  return doQuery($query);
}

sub ftpDeleteUser ($) {
  my ($user) = @_;
  $query = <<EOF;
	DELETE FROM ftpacl WHERE user = "$user";
EOF
  return doQuery($query);
}

sub ftpUpsertUserToFULL {
  my ($user, $mpnt, $share) = @_;
  doConsole("ftpUpsertUserToFULL");
  $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "$path" and user = "$user";
	INSERT INTO ftpacl
		 ( mpnt   , path     , user   , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "no"  , "allow" , "allow"  , "allow"   , "allow"   , "allow"   , "allow" ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}

sub ftpUpsertUserToREAD {
  my ($user, $mpnt, $share) = @_;
  doConsole("ftpUpsertUserToREAD");
  $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "$path" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , path     , user  , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "no"  , "allow" , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,  "allow", "allow"      )
	;
	COMMIT;
EOF
  return doQuery($query);
}

sub ftpUpsertUserToNONE {
  my ($user, $mpnt, $share) = @_;
  doConsole("ftpUpsertUserToNONE");
  $query .= <<EOF;
	BEGIN TRANSACTION;
	DELETE FROM ftpacl WHERE mpnt = "$mpnt" and path = "$path" and user = "$user";
	INSERT INTO ftpacl
	         ( mpnt   , path     , user   , hidden, read_acl, write_acl, delete_acl, create_acl, modify_acl, move_acl, view_acl, navigate_acl )
	  VALUES ( "$mpnt", "/$share", "$user", "yes" , "deny"  , "deny"   , "deny"    , "deny"    , "deny"    , "deny"  ,   "deny", "deny"       )
	;
	COMMIT;
EOF
  return doQuery($query);
}

sub dumpQuery {
  my ($output, $exitcode) = @_;
  return "output=$output, exitcode=$exitcode";
}

# my @mpnt = (1,2,3);
# my @share = (4,5,6);
# print "addNewUser:\n",dumpQuery(insertUser("bob", @mpnt, @share)), "\n";
# print "mpnt:       ", join(",", @mpnt), "\n";
# print "share:      ", join(",", @share), "\n";

1;
