#!/bin/bash
#
#	Downloads the latest firmware and its MD5 file
#
#	Indicates progress by creating 'status' files.
#

. /usr/www/nbin/commonfuncs

#clean () { 
#	rm -f /home/uImage
#	rm -f /tmp/rootfs.arm.ubi 
#}  

#touch /home/fw.tar.gz
chmod 777 /home/fw.tar.gz
tar -xvf /home/fw.tar.gz

# delete to ****  this if no tar and MD5 being used 
#touch /tmp/active_upgrade; 
#if $NAS_NBIN/wget.sh '/var/upgrade/latestfw.md5' "$URL.md5" ;
#then 
#	touch /var/upgrade/md5downloaded
#else
#	clean
#	touch /var/upgrade/missing-md5
#fi
# ****

# uncomment the following line to use a self extracting archive
# if $NAS_NBIN/wget.sh '/var/upgrade/latestfw.sh' "$URL" ;
# uncomment this line to use a tar file and MD5 pair.
#if [ -e /var/upgrade/md5downloaded ] && $NAS_NBIN/wget.sh '/var/upgrade/latestfw.sh' "$URL" ;
#then
#	touch /var/upgrade/fwdownloaded
#	chmod +x /var/upgrade/latestfw.sh
#	logger -p 7 "download $URL completed"

# delete to **** to use a self extracting archive for update
#	MD5_MASTER=`cat /var/upgrade/latestfw.md5`
#	MD5_LOCAL=`md5sum /var/upgrade/latestfw.sh`
#	MD5A=`expr substr "$MD5_MASTER" 1 32` 
#	MD5B=`expr substr "$MD5_LOCAL" 1 32`
#	if [ $MD5A != $MD5B ]
#	then 
#		clean
#		touch /var/upgrade/download-corrupt
#		logger -p 4 "downloaded md5 sums not matching"
#	else
#		touch /var/upgrade/md5pass
#		tar -xf /var/upgrade/latestfw.sh -C /var/upgrade
#		chmod +x /var/upgrade/upgrade*
#	fi
# ****

#else
#	logger -p 4 "download $URL failed"
#	clean
#fi



