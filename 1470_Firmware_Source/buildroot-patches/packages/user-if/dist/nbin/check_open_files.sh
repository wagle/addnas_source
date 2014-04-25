#!/bin/sh
#
# Checks for open files on shares under specified directory
#

if [ -n "`lsof | grep REG.*$1`" ]; then
	exit 1   ### WARNING!  current perl sudo() and ludo() treat 1 as success
fi

exit 0

