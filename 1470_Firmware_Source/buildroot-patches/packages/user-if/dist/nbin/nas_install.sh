#!/bin/sh
#
#	Installs the specified file as 'target' name
#

NEWFILE=$1
TARGET=$2
PERMS=${3:-"644"}

. /usr/www/nbin/commonfuncs

install -o 0 -g 0 -m $PERMS $NEWFILE $TARGET
rm -f $NEWFILE

# Make a patch file
#
# bruce - removed because Brian is handling this
#save_changes $TARGET
