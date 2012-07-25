#!/bin/sh
#
# Renames a directory
#
# Ian Steel
# September 2006
#
. /usr/www/nbin/commonfuncs

OLDDIR=$1
NEWDIR=$2

mv $OLDDIR $NEWDIR
