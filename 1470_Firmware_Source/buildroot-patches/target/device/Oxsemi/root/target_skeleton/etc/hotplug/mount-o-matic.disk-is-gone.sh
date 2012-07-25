#!/bin/sh

# disk is gone, kill everyone using it

DISK=$1
PARTITION=$2
DEVICE=$3

KAU=/etc/hotplug/kick-all-users.sh

echo umount -l /dev/$PARTITION > /dev/console 2>&1
umount -l /dev/$PARTITION > /dev/console 2>&1
echo EXITCODE $? > /dev/console 2>&1

# being nice seems to cause kernel oops
#if $KAU -HUP $DEVICE ; then
#	sleep 1
#	if $KAU -TERM $DEVICE ; then
#		sleep 1
		if $KAU -9 $DEVICE ; then
			sleep 2
			if $KAU -9 $DEVICE ; then
				echo "UNKILLABLE PROCESSES ON DISK $DISK PARTITION $PARTITION DEVICE $DEVICE" > /dev/console
				while true ; do
					reboot
					sleep 60
				done
			fi
		fi
#	fi
#fi

sleep 1
echo umount /dev/$PARTITION > /dev/console 2>&1
umount /dev/$PARTITION > /dev/console 2>&1
echo EXITCODE $? > /dev/console 2>&1
sleep 1
echo umount /dev/$PARTITION > /dev/console 2>&1
umount /dev/$PARTITION > /dev/console 2>&1
echo EXITCODE $? > /dev/console 2>&1

exit 0
