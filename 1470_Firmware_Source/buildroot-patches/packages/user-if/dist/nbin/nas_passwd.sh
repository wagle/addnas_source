#!/bin/sh
#
#	Changes the unix password for the given user
#
#	$1 - Username
#	$2 - Password
#
UNAME=$1
PWORD=$2

( echo "$PWORD"
	sleep 3
	echo "$PWORD" ) | passwd $UNAME

# Allow time for the passwd database change to take effect
sleep 1
