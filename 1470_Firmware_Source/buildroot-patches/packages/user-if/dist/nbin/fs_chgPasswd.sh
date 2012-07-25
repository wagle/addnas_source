#!/bin/sh
#
#	Changes the password for a Samba and unix user
#
#	$1 - Username
#	$2 - Password
#
#	Does NOT create a home dir for the user
#

UNAME=$1
PWORD=$2

. /usr/www/nbin/commonfuncs

nas_passwd.sh $UNAME $PWORD

# $SMB_HOME/bin/pdbedit -a ${UNAME} -s ${SMB_CONF} -t << EOF
# ${PWORD}
# ${PWORD}
# EOF

#save_passwd_changes
#
#( echo -e "${PWORD}"
#	sleep 3;
#	echo -e "${PWORD}"	) | $SMB_HOME/bin/smbpasswd -c $SMB_CONF -L -s ${UNAME}

$SMB_HOME/bin/smbpasswd -c $SMB_CONF -L -s ${UNAME} << EOF
${PWORD}
${PWORD}
EOF

## Ensure user www-data can still read the samba password file
##
#save_samba_passwd_changes

