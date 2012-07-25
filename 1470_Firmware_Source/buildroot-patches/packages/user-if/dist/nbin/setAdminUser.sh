#!/bin/sh
#
# Sets the username and password for admin access to the nas web i/f
#
# Ian Steel
# September 2006
#
. /usr/www/nbin/commonfuncs

USERNAME=$1
PWORD=$2

# Generate the md5hash for htdigest password
#
HTD=$(echo -n "$USERNAME:nas admin:$PWORD"|md5sum|cut -f1 -d" ")

echo "$USERNAME:nas admin:$HTD" >>/tmp/$$
nas_install /tmp/$$ /var/private/lighttpd.htdigest.user

exit 0
