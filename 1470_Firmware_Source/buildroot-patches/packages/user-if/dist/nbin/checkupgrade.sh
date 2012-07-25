#!/bin/bash
#
#	Downloads the latest firmware and then applies it.
#
#	Indicates progress by creating 'status' files.
#

. /usr/www/nbin/commonfuncs

clean () { 
	rm -f /var/upgrade/* 
	rm -f /tmp/active_upgrade   
} 


rm -f /var/upgrade/md5fail

if [ -e /var/upgrade/md5pass ] ;
then
	exit 0
fi
#move ALL wdg files to a single file. (should be only one WDG file but use last found)
for infile in /var/upgrade/*.wdg
do
	mv -f $infile /var/upgrade/latestfw.sh
done

chmod +x /var/upgrade/latestfw.sh

#unpack software
/var/upgrade/latestfw.sh || { clean ; logger -p 3 "firmware failed to unpack" ; exit 1 ; }

# merge with existing software if possible. 
if [ -e /var/upgrade/upgrade1-xdelta.sh ] 
then
	/var/upgrade/upgrade1-xdelta.sh || { clean ; logger -p 3 "pre-upgrade script failed" ; exit 1 ; }
fi

#verify downloaded or merged files.
cd /var/upgrade ; 
# need to set exit >1 for perl checking routines.
md5sum -c md5sum.lst > /dev/null 2>&1 || exit 5 
exit 0

