#!/bin/sh
#
# Program: dm_formatInternal.sh
# Purpose: Formats the newly installed internal drive 
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


# DEV = /dev/sda
# OLD = /dev/sdb
# MD = /dev/md
# TYPE=raid0 | raid1

DEV=$1
OLD=$2
MD=$3 
TYPE=$4

PERL=/usr/local/bin/perl

. /usr/www/nbin/commonfuncs

#echo dm_formatInternal $DEV $OLD $MD $TYPE >/dev/console 2>&1


#############################################################################
# subs

# tests if the raid device (param 1) is working OK, if not, it will
# add the replacement drive (param 2)
RAIDTestAndAdd() {
    local MD=$1
    local DEV=$2
    # test found to always fail
    #/sbin/mdadm --detail --test $MD
    #[ $? != 0 ] &&
    /sbin/mdadm --manage $MD --add $DEV
}

create_partitions()
{
    local disk=$1

    dd if=/dev/zero of=$1 bs=1M count=32

    /sbin/parted $disk mklabel gpt
    /sbin/parted $disk mkpart primary 65536s 4259839s
    /sbin/parted $disk set 1 raid on
    /sbin/parted $disk mkpart primary 4259840s 5308415s
    /sbin/parted $disk set 2 raid on
    /sbin/parted $disk mkpart primary 5308416s 9502719s
    /sbin/parted $disk set 3 raid on
    /sbin/parted $disk mkpart primary 9502720s 100%
    /sbin/parted $disk set 4 raid on

    wait
}

write_bootrom_directions()
{
    local disk=$1

    $PERL <<EOF | dd of="$disk" bs=512
        print "\x00" x 0x1a4;
        print "\x00\x5f\x01\x00";
        print "\x00\xdf\x00\x00";
        print "\x00\x80\x00\x00";
        print "\x00" x (0x1b0 -0x1a4 -12 );
        print "\x22\x80\x00\x00";
        print "\x22\x00\x00\x00";
        print "\x00\x80\x00\x00";
EOF
}

#############################################################################
# main

if [ ! -b "$DEV" ] ; then
        echo "WARNING: $DEV is not a block device."
        exit 1
fi
if [ ! -b "$MD" ] ; then
        echo "WARNING: $MD is not a block device."
        exit 1
fi
if [ ! -b "$OLD" ] ; then
        echo "WARNING: $OLD is not a block device."
        exit 1
fi

# if a TYPE isn't set, then exit
[ $TYPE == "raid0" ] || [ $TYPE == "raid1" ] || exit  


touch /tmp/dm_progress
umount /shares/internal

# Create GPT partition table on new disk
create_partitions $DEV

# Write bootrom loading directions into MSDOS MBR unused fields on new disk
write_bootrom_directions $DEV

# Copy hidden sectors data (loaders, kernel, etc.) to new disk
dd if=$OLD of=$DEV bs=512 skip=34 seek=34 count=65502

# Add the new drive to the raid setup, checking to make sure it isn't OK first
RAIDTestAndAdd ${MD}1 ${DEV}1
RAIDTestAndAdd ${MD}2 ${DEV}2
RAIDTestAndAdd ${MD}3 ${DEV}3

# if the raid device was raid0 then a drive failure can cause it to dissappear
# if it is missing, recreate it
/sbin/mdadm --detail --test ${MD}4
if [ $? == 4 ]; then
    # Use sda4 and sdb4 explicitly as building RAID-0 devices for HW RAID needs
    # the drives in the correct order.
    /sbin/mdadm --create ${MD}4 --run -n2 -l $TYPE /dev/sda4 /dev/sdb4 --assume-clean
    echo "formatting" > /tmp/dm_progress
    /sbin/mkfs.xfs -f -l lazy-count=1 ${MD}4
else
    RAIDTestAndAdd ${MD}4 ${DEV}4
fi

# mount internal
mount /shares/internal

# set readahead on raid volume
blockdev --setra 4096 ${MD}4

# Set www-data as owner and propagate the SUID/GUID state and set correct permissions
chown www-data:www-data /shares/internal
chmod ug+s /shares/internal

exit 0
