#!/bin/sh

PROG="/usr/sbin/nandbd"
PREFIX="/var/images"
STAGE1="${PREFIX}/stage1.wrapped"
UBOOT="${PREFIX}/u-boot.wrapped"
KERNEL="${PREFIX}/uImage"
ROOTFS="${PREFIX}/rootfs.arm.ubi"

/sbin/modprobe ox820_nand > /dev/null 2>&1
wait
/usr/sbin/flash_eraseall /dev/mtd1
wait
${PROG} -s $STAGE1 -u $UBOOT -k $KERNEL /dev/mtd1

/usr/sbin/ubiformat -y -s 512 --flash-image=${ROOTFS} /dev/mtd2

sync;sync;sync
