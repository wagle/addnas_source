#!/bin/sh

# admin wants to unplug disk, try to umount it

DISK=$1
PARTITION=$2
DEVICE=$3

umount /dev/$PARTITION 2>&1 > /dev/console
exit $?
