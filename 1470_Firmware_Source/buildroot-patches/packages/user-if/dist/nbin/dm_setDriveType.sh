#!/bin/sh
#
# Program: dm_setDriveType.sh
# Purpose: Sets the drive type of the md4 volume
# Author : $Author: Bruce $
# Version: $Revision: $
# Date   : $Date: $
#
# Partitions
# md1 -> rootfs
# md2 -> swap
# md3 -> /var
# md4 -> /shares/internal
#

# Process
# -------
# Stop Samba
# Stop NFS
# Check mountpoint is not busy
# Remove all shares
# run the format
# Start NFS
# Start Samba

# LEVEL is either raid0 for single large volume or 1 for raid1
LEVEL=$1
MD=$2
SDA=$3
SDB=$4

. /usr/www/nbin/commonfuncs

#echo dm_setDriveType $LEVEL $MD $SDA $SDB >&2

touch /tmp/dm_progress
umount /shares/internal

# stop RAID monitoring
[ -x /etc/init.d/raid_monitoring.sh ] && /etc/init.d/raid_monitoring.sh stop
/sbin/mdadm --manage --stop $MD

# delete the now out-of-date /etc/mdadm.conf
rm /etc/mdadm.conf

# re-org and format drives
/sbin/mdadm --create -l $LEVEL --assume-clean --run -n 2 $MD $SDA $SDB &&
/bin/sleep 1s &&
/sbin/mkfs.xfs -f -l lazy-count=1 $MD

# regen the /etc/mdadm.conf file
echo "DEVICE partitions" > /etc/mdadm.conf
/sbin/mdadm --examine --scan --config=partitions >> /etc/mdadm.conf

# mount internal
mount /shares/internal

# set readahead on the RAID volume
blockdev --setra 4096 $MD

# Set www-data as owner and propagate the SUID/GUID state and set correct permissions
chown www-data:www-data /shares/internal
chmod ug+s /shares/internal

# Re-start monitoring
[ -x /etc/init.d/raid_monitoring.sh ] && /etc/init.d/raid_monitoring.sh start
exit 0
