#!/bin/sh
#
# Sets permissions on the specified file.
#

PERMS=$1
FNAME=$2

chmod $PERMS $FNAME
