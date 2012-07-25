#!/bin/sh
#
# Checks for open files on shares under specified directory
#

if [ -n "`lsof | grep REG.*$1`" ]; then
	exit 1
fi

exit 0

