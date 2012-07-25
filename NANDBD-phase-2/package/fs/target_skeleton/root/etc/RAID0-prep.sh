#!/bin/sh
if [ -e /var/lib/RAID0-prep ]
then
	echo "Preparing user data partition for RAID0 operation"
	rm /var/lib/RAID0-prep
	umount /dev/md4
	mdadm --stop /dev/md4
	/sbin/mdadm --create /dev/md4 --auto=md --raid-devices=2 --level=raid0 --run /dev/sda4 /dev/sdb4
	mkfs.xfs -f -l lazy-count=1 /dev/md4
	mount /shares/internal
fi
