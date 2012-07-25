#!/bin/sh
#
# Create a directory (with parents!)
#
. /usr/www/nbin/commonfuncs

SUSER=$1
SPATH=$2

mkdir -p $SPATH
chown -R $SUSER $SPATH

if [ -L /home/$SUSER ]; then
	rm /home/$SUSER
fi

ln -s $SPATH /home/$SUSER
chown $SUSER /home/$SUSER
