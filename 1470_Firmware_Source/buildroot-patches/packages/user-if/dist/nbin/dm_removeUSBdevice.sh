#!/bin/sh
#
# Program: dm_removeUSBdevice.sh
# Purpose: Unmounts and removes a USB device
# Author : $Author: Bruce $
# Version: $Revision: $
# Date   : $Date: $
#

# A device name like sdc                                                           
DEVICE=$1                                                                          
                                                                                   
. /usr/www/nbin/commonfuncs                                                            

# Strip off any preceding /dev/
DEVICE=`echo $DEVICE|sed -e's/\/dev\///'`

#echo dm_removeUSBdevice $DEVICE >&2                                                 
                                                                                   
if [ ! -b "/dev/$DEVICE" ] ; then                                                  
        echo "WARNING: $DEVICE is not a block device."                               
        exit 100                                                                     
fi                                                                                 

touch /tmp/dm_progress
                                                                                   
# Unmount the device using umount normally
/var/run/block/$DEVICE try-to-umount

rm /tmp/dm_progress

# Check the device was unmounted completely
if grep -q "$DEVICE" /proc/mounts
then
	exit 101;
else
	/etc/init.d/samba.sh reconfig
	exit 0;
fi
                                                                                   
