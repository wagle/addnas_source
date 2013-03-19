#!/bin/sh
#
#	Adds a user to unix, sets the password, adds them to Samba and also sets the password
#
#	$1 - Username
#	$2 - Password
#
#	Does NOT create a home dir for the user
#

UNAME="$1"
PWORD="$2"
HOMED="$3"

. /usr/www/nbin/commonfuncs

if [ $UNAME = "www-data" ] ; then
	$SMB_HOME/bin/pdbedit -a -u "$UNAME" -c "[N ]"  -s ${SMB_CONF}  -t  <<EOF
${PWORD}
${PWORD}
EOF
	exit 0
fi

if [ -n "$HOMED" ] ; then
	mkdir "$HOMED"
	ln -s "$HOMED" /home/$UNAME
fi

adduser -D -H "$UNAME"
nas_passwd.sh "$UNAME" "$PWORD"

if [ -n "$HOMED" ] ; then
	chown -R "$UNAME" "$HOMED"
	### don't chmod at this time
fi

$SMB_HOME/bin/pdbedit -a "$UNAME" -s ${SMB_CONF} -t << EOF
${PWORD}
${PWORD}
EOF

# $NAS_NBIN/restartSamba.sh
exit 0
