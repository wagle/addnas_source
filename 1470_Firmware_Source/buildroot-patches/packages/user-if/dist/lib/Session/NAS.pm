#!/usr/bin/env perl
# Class   : Session::NAS
# Purpose : Access NAS Sessions
# Author  : B.James
# Date    : $Date: $
# Version : $Revision :$
#

use strict;
use warnings;

=pod

=head1 DESCRIPTION

Session::NAS - Access NAS Sessions

=head1 SYNOPSIS

# Create a new session with 15 minute expiry time
# Uses the browser cookie if one was found in the request
my $session = new Session::NAS( 'cookie_name','+15M' );

# Get a hash of current live sessions by their cookie value and time
my $session = find Session::NAS( 'cookie_name' );

# Fetch the cookie object (For setting in cgi headers with -cookie =>)
$session->cookie();

# Invalidate the session
$session->invalidate();

# Update the accessed time without changing any data.
$session->touch();

# Access data within the session
$session->data( 'MyTag' );

# Set data within the session
$session->data( 'MyTag', 'MyValue' );

=head1 DESCRIPTION


=cut

package Session::NAS;

use nasCommon;
use Config::Tiny;
use CGI;
use CGI::Cookie;

our $EXPIRYTIME = 300;		# Session expiry time - 5 minutes
our $DEFAULTEXPIRE = '+1d';	# 1 Day
our $DEFAULTNAME= 'plxtech_user';	# Default cookie name;

sub new {
	# Creates a new cookie
	my $class=shift;
	my $this={};
	bless $this, $class;

	my $name = shift || $DEFAULTNAME;
	my $expires = shift;

	# Perform housekeeping

	# Find or create a cookie
	if ( my $cookie=Session::NAS->find( $name, $expires ) ) {
		# Retrieve the existing cookie
		print STDERR "Session::NAS::new: Use existing cookie\n";
		$this=$cookie;
	} else {
		# Create a new cookie
		print STDERR "Session::NAS::new: Create cookie\n";
		$this->{cookie} = new CGI::Cookie(
			-name => $name,
			-value => $this->createCookieValue,
			-expires => $expires || $DEFAULTEXPIRE,
		);
		# Store the session creation time.
		$this->data( 'created',time() );
	}

	return $this;
}

sub find {
	# Finds the browser cookie, or returns undef if none exists.
	my $class=shift;
	my $this={};
	bless $this, $class;

	my $name = shift || $DEFAULTNAME;
	my $expires = shift || $DEFAULTEXPIRE;

	# Perform housekeeping
	$this->housekeep();

	my $cookies = CGI::Cookie->fetch();
	if ( $cookies->{ $name } ) {
		# Retrieve the existing cookie
		$this->{cookie} = $cookies->{ $name };

		print STDERR "Session::NAS::find: Cookie found\n";

		# Set its expiry time
		$this->{cookie}->expires( $expires );
	} else {
		# No cookie found
		print STDERR "Session::NAS::find: No cookie found\n";
		return;
	}

	return $this;
}

sub createCookieValue {
	# Returns a unique(ish) value for the cookie.
	return time();
}

sub sessionName {
	# Returns the name of the session (The cookie value);
	my $this=shift;
	return unless ref( $this->{cookie} );
	return $this->{cookie}->value();
}

sub liveSessions {
	# Returns a list of live sessions from the store
	# based on their accessed time being less than $EXPIRYTIME
	my $class=shift;

	# Open the session store
        my $cfg=Config::Tiny->read( nasCommon->session_store ) || Config::Tiny->new();

	# Get all sections
	my @sections = keys( %{$cfg} );

	# Check the 'accessed' time in each section
	my $live={};
	foreach my $section (@sections) {
		my $accessed = $cfg->{$section}->{accessed};
		if (time() - $accessed <= $EXPIRYTIME) {
			# Session is still alive, so return its name
			$live->{$section}=$accessed;
		}
	}

	# Return live hashref
	return $live;
}


sub housekeep {
	# Removes any sessions that have expired.
	# Returns a list of session names which were removed.
	my $this=shift;

	# Open the session store
        my $cfg=Config::Tiny->read( nasCommon->session_store ) || Config::Tiny->new();

	# Get all sections
	my @sections = keys( %{$cfg} );

	# Check the 'accessed' time in each section
	my @dead;
	foreach my $section (@sections) {
		my $accessed = $cfg->{$section}->{accessed};
		if (time() - $accessed > $EXPIRYTIME) {
			# Session has timed out, so delete it.
			push @dead, $section;
			delete $cfg->{$section};
		}
	}
	return @dead;
}

sub cookie {
	my $this=shift;
	return $this->{cookie};
}



sub invalidate {
	my $this=shift;
	return unless ref( $this->{cookie} );
	$this->{cookie}->expires( 'now' );
}

sub data {
	my $this=shift;
	my $tag =shift || return;
	my $value = shift;

	return unless ref( my $cookie=$this->{cookie} );

	# Open the session store
        my $cfg=Config::Tiny->read( nasCommon->session_store ) || Config::Tiny->new();

	# Get the section (Which is the cookie value)
	my $section = $cookie->value();

	# Store the last time the session was accessed
	$cfg->{$section}->{accessed} = time();

	if (defined $value) {
		$cfg->{$section}->{$tag} = $value;
	}

	$cfg->write( nasCommon->session_store);
	return $cfg->{$section}->{$tag};
}

sub touch {
	my $this=shift;
	return unless ref( my $cookie=$this->{cookie} );

	# Open the session store
        my $cfg=Config::Tiny->read( nasCommon->session_store ) || Config::Tiny->new();

	# Get the section (Which is the cookie value)
	my $section = $cookie->value();

	# Store the last time the session was accessed
	$cfg->{$section}->{accessed} = time();
	$cfg->write( nasCommon->session_store);

	return $cfg->{$section}->{accessed};
}

1;
