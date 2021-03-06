#!/bin/sh
#
#	Removes a unix and Samba user
#
#	$1 - userid (from passwd and samba password files)
#
#	Does NOT create a home dir for the user
#

UNAME=$1

. /usr/www/nbin/commonfuncs

if [ -n "$UNAME" ]
then
	$SMB_HOME/bin/pdbedit -x ${UNAME} -s ${SMB_CONF}
	deluser ${UNAME}
	rm /home/$UNAME
fi
exit 0
