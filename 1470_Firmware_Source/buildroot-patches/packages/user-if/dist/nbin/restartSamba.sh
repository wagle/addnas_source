#!/bin/sh
#
#	Restarts the Samba daemon(s).
#
# Why not just call the init.d scrpt? Because restarting Samba changes the permissions of the
# private password file and prevents www-data accessing it. This script restarts Samba and also
# changes the permissions to suit us.
#
# 2014/02/19 WAGLE -- switched to reconfig, maybe restarting isn't needed

. /usr/www/nbin/commonfuncs

/etc/init.d/samba.sh restart

chgrp www-data /var/private/smbpasswd
chmod 0640 /var/private/smbpasswd
