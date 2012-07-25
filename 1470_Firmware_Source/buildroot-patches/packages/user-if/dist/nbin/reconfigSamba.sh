#!/bin/sh
#
#	get Samba daemon(s) to re-read their config files
#

. /usr/www/nbin/commonfuncs

/etc/init.d/samba.sh reconfig
