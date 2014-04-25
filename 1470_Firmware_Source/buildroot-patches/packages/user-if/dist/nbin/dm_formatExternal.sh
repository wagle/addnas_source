#!/bin/sh
#
# Program: dm_formatExternal.sh
# Purpose: Formats the supplied external device
# Author : $Author: Bruce $
# Version: $Revision: $
# Date   : $Date: $
#

# A device name like sdc                                                           
DEVICE=$1                                                                          
FTYPE=$2                                                                                   
DLABELT=$3

. /usr/www/nbin/commonfuncs                                                            

# Strip off any preceding /dev/
DEVICE=`echo $DEVICE|sed -e's,/dev/,,'`

if [ ! -b "/dev/$DEVICE" ] ; then                                                  
        echo "WARNING: $DEVICE is not a block device."                               
        exit 2                                                                     
fi                                                                                 

touch /tmp/dm_progress
                                                                                   
# Unmount the device using the disk-just-got-unplugged policy 
/var/run/block/$DEVICE disk-is-gone

# Fdisk the device into one large partition                                        
# Blow away sector 0... (seat of your pants style!)                                
#dd if=/dev/zero of=/dev/$DEVICE bs=512 count=1                                     
#fdisk "/dev/$DEVICE" <<FDISK_SCRIPT                                                
#n                                                                                  
#p                                                                                  
#1                                                                                  
#1                                                                                  
#                                                                                   
#w                                                                                  
#FDISK_SCRIPT
#echo $DEVICE $FTYPE $DLABELT > /root/formatdebug

/sbin/parted /dev/$DEVICE --script mklabel $DLABELT #1>>/root/formatdebug 2>>/root/formatdebug
/sbin/parted /dev/$DEVICE --script -- mkpart primary 0 -1 #1>>/root/formatdebug 2>>/root/formatdebug

# Format the device                                                                
if [ "$FTYPE" = "xfs" ] ; then
	/sbin/mkfs.xfs -f /dev/${DEVICE}1 > /dev/console 2>&1 ###1>>/root/formatdebug 2>>/root/formatdebug
	/bin/xfs_admin -U generate /dev/${DEVICE}1 > /dev/console 2>&1
fi
if [ "$FTYPE" = "ext3" ] ; then
	/sbin/mkfs.ext3 /dev/${DEVICE}1 ###1>>/root/formatdebug 2>>/root/formatdebug
fi
                                                                                   
# call the hotplug script to remount the device                                    
cd /etc/hotplug; ./mount-external-drive $DEVICE                                    

rm /tmp/dm_progress
