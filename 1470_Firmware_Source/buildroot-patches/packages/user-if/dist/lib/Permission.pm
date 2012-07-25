#!/usr/bin/env perl
# Class   : Permission.pm
# Purpose : Access for ethernet stats. 
# Author  : B.James
# Date    : $Date: $
# Version : $Revision :$
#

=pod

=head1 NAME

Permission - Access Permission information

=head1 SYNOPSIS

# Check a file exists with correct permissions.
my $p = new Permission( 'file_to_test','0644','root','web-data' );
my @errors = $p->check();
$p->fix( @errors );

# Check a path exists with correct permissions.
Permission->new( 'path/to/check/','0755','root','web-data' )->ensure();

=head1 DESCRIPTION

This class provides an interface to various OS commands such as
ifconfig and netstat. It is used to gather information and present it
as an OO accessor interface.

=over

=item new( $file, $permissions, $owner, $group )

Create a new Permission object.

=item check()

Check permissions for the item in this object.
Returns: @errors - A list of errors with this item defined as:
	PERMS	The permissions are incorrect for the item
	OWNER	The ownership is incorrect.
	GROUP	The group is incorrect

=item fix( @errors )

For each of the supplied error codes as defined above, fix the named errors.
Returns a 1 on success.

=item ensure()

This performs a check() and fix() in one method.
If any errors still persist, they are returned as an array in the same format as check()

=back

=cut

package Permission;
use strict;
use warnings;

# Class variables

our $NBIN;

# Class methods

sub new {
	my $class=shift;
	my $this={};
	bless $this, $class;

	$this->{filename} = shift || die( "You really must specify a filename for Permission" );
	$this->{perms} = eval(shift) || die( "Permissions required" );
	$this->{owner} = shift || die( "Owner required" );
	$this->{group} = shift || die( "Group required" );

	return $this;
}

sub path {
	my $class=shift;
	$NBIN=shift;
}

# Instance methods

sub ensure {
	# Ensures the file has the correct permissions and exists.
	# If there are problems, these are attempted to be resolved. 
	# If problems persist, they are reported in an error array
	my $this=shift;

	my @errors = $this->check();
	if (@errors) {
		$this->fix( @errors );
		@errors =  $this->check();
	}

	return @errors;
}

sub check {
	# Check permissions for the specified file.
	# Returns an array of error names or
	# an empty array if all checks succeded.
	my $this=shift;
	my @errors;
	if (! -e $this->{filename}) {
		# File does not exist
		push( @errors, 'NOTEXIST' ) 	
	} else {
		# At least the file exists. Check its perms
		# If it is a directory, make sure it ends with /
		$this->{filename}.='/' if ((-d $this->{filename}) && (!$this->{filename}=~/\/$/));
		my ($grgid) = (getgrnam( $this->{group} ))[2];
		my ($pwuid) = (getpwnam( $this->{owner} ))[2];
		my ($mode,$owner,$group) = (stat( $this->{filename} ))[2,4,5];
		$mode = $mode & 07777;
		push( @errors, 'PERMS' ) 	if ( $mode != $this->{perms} );
		push( @errors, 'OWNER' ) 	if ( $owner != $pwuid );
		push( @errors, 'GROUP' ) 	if ( $group != $grgid );
	}
	return @errors;
}

sub fix {
	# Fix permissions for the specified file.
	my $this=shift;
	my @errors=@_;
	my $perms = $this->{perms} || return;
	my $owner = $this->{owner} || return;
	my $group = $this->{group} || return;

	foreach my $error (@errors) {
		for ( $error ) {
			/NOTEXIST/ && do {
				if ($this->{filename}=~/\/$/) {
					# Treat as a path (implicit -p)
					system( "sudo $NBIN/mkdir.sh ".$this->{filename} );
				} else {
					# Treat as a file
					system( "sudo $NBIN/touch.sh ".$this->{filename} );
				}
			};
			/PERMS/ && do {
print STDERR "Permission: sudo $NBIN/chmod.sh ".$this->{perms}." ".$this->{filename}."\n";
#				system( "sudo $NBIN/chmod.sh ".$this->{perms}." ".$this->{filename} );
			};
			/OWNER/ && do {
				system( "sudo $NBIN/chown.sh ".$this->{owner}." ".$this->{filename} );
			};
			/GROUP/ && do {
				system( "sudo $NBIN/chgrp.sh ".$this->{group}." ".$this->{filename} );
			};
		}
	}
	return 1;
}

1;
