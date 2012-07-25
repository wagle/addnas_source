#!/bin/sh

MD1=/dev/md1
MD2=/dev/md2
MD3=/dev/md3
MD4=/dev/md4

stage1File=stage1.wrapped
ubootFile=u-boot.wrapped
kernelFile=uImage
rootfsbzip=rootfs.arm.ext2.bz2
rootfs=rootfs.arm.ext2
customerfsbzip=rootfs.arm.tar.bz2

upgradeKernel=uImage.1
upgradeRootfs=uUpgradeRootfs

quit()
{
    echo $1
    exit 1
}

sanityCheck()
{
    # check program arguments have been provided
    [ -z $1 ] || [ -z $2 ] || [ -z $3 ] && quit "usage: $0 disk-a disk-b version-string"

    # check for the commands we need
    which dd          >/dev/null || quit "Need dd        in the path" 
    which parted      >/dev/null || quit "Need parted    in the path" 
    which mdadm       >/dev/null || quit "Need mdadm     in the path" 
    which mkfs.ext3   >/dev/null || quit "Need mkfs.ext3 in the path" 
    which mkfs.xfs    >/dev/null || quit "Need mkfs.xfs  in the path" 
    which mkswap      >/dev/null || quit "Need mkswap    in the path" 
    which bunzip2     >/dev/null || quit "Need bunzip2   in the path" 
    which mount       >/dev/null || quit "Need mount     in the path" 
    which umount      >/dev/null || quit "Need umount    in the path" 
    which cp          >/dev/null || quit "Need cp        in the path"

    # check the parameters are block devices
    [ -e $1 ] || quit "disk device $1 does not exist"
    [ -b $1 ] || quit "disk device $1 is not a block device"
    [ -w $1 ] || quit "disk device $1 is not writable (run as root)"

    # check the devices aren't mounted this isn't fool proof as it won't
    # spot if /dev/root is one of disks
    grep $1 /proc/mounts && quit "disk device $1 is already in use"

    [ -e $2 ] || quit "disk device $2 does not exist"
    [ -b $2 ] || quit "disk device $2 is not a block device"
    [ -w $2 ] || quit "disk device $2 is not writable (run as root)"

    # check the devices aren't mounted this isn't fool proof as it won't
    # spot if /dev/root is one of disks
    grep $2 /proc/mounts && quit "disk device $2 is already in use"

    # check for the files to install
    [ -r "$stage1File" ] || quit "$stage1File isn\'t readable"
    [ -r "$ubootFile"  ] || quit "$ubootFile isn\'t readable"
    [ -r "$kernelFile" ] || quit "$kernelFile isn\'t readable"
    [ -r "$rootfsbzip" ] || [ -r "$customerfsbzip" ] || quit "root filesystem image isn't readable"

    # check the RAID device nodes exist and aren't in use
    grep $MD1 /proc/mdstat && quit "RAID device $MD1 is already in use"
    grep $MD2 /proc/mdstat && quit "RAID device $MD2 is already in use"
    grep $MD3 /proc/mdstat && quit "RAID device $MD3 is already in use"
    grep $MD4 /proc/mdstat && quit "RAID device $MD4 is already in use"
}

create_partitions()
{
    local disk=$1

    dd if=/dev/zero of=$1 bs=1M count=32

    parted $disk mklabel gpt
    parted $disk mkpart primary 65536s 4259839s
    parted $disk set 1 raid on
    parted $disk mkpart primary 4259840s 5308415s
    parted $disk set 2 raid on
    parted $disk mkpart primary 5308416s 9502719s
    parted $disk set 3 raid on
    parted $disk mkpart primary 9502720s 100%
    parted $disk set 4 raid on
    parted $disk print

    wait
}

write_bootrom_directions()
{
    local disk=$1
#
# Boot ROM loading directions:
#
#  Secondary checksum (location + length)
#  Secondary location in sectors
#  Secondary length in sectors (minus half a sector due to boot ROM bug)
#
#  Primary checksum (location + length)
#  Primary location in sectors
#  Primary length in sectors (minus half a sector due to boot ROM bug)
#
    perl <<EOF | dd of="$disk" bs=512
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

write_hidden_sectors()
{
    local disk=$1

    dd if=$stage1File    of="$disk" bs=512 seek=34
    dd if=$ubootFile     of="$disk" bs=512 seek=154
    dd if=$kernelFile    of="$disk" bs=512 seek=1290
    dd if=$upgradeKernel of="$disk" bs=512 seek=8482
    dd if=$upgradeRootfs of="$disk" bs=512 seek=16674
    dd if=$stage1File    of="$disk" bs=512 seek=57088
    dd if=$ubootFile     of="$disk" bs=512 seek=57208
    dd if=$kernelFile    of="$disk" bs=512 seek=58344
}

copyRootFilesystem()
{
    version="$1"
    systemtype="$2"

    workarea="/tmp/NASInstall$$"

    # create a work area if needed
    [ -d "$workarea" ] || mkdir "$workarea"
    [ -d "$workarea/disk" ] || mkdir "$workarea/disk"

    # mount disks
    mount $MD1 "$workarea/disk"
    mkdir "$workarea/disk/var"
    mount $MD3 "$workarea/disk/var"

    # copy
    if [ -e "$customerfsbzip" ]; then
    	echo "Using customer rootfs image"
        tar -C "$workarea/disk" -xf "$customerfsbzip"
    elif [ -e "$rootfsbzip" ]; then
    	echo "Using standard rootfs image"
        [ -d "$workarea/rootfs" ] || mkdir "$workarea/rootfs"
        rootfsimage="$workarea/$rootfs"
        bunzip2 "$rootfsbzip" -c > "$rootfsimage"
        mount -o loop "$rootfsimage" "$workarea/rootfs"
        cp -a "$workarea/rootfs/"* "$workarea/disk"
    else
    	quit "No std or customer rootfs image found"
    fi

    mkdir -p "$workarea/disk/var/lib"
    echo "$version" > "$workarea/disk/var/lib/current-version"

    # Change the system type if an Oxsemi-style rootfs
    if [ -e "$workarea/disk/var/oxsemi/network-settings" ]
    then
        if [ -n "$systemtype" ]
        then
            sed -i -e "s:system_type[ ^t]*=.*\$:system_type=$systemtype:"\
                "$workarea/disk/var/oxsemi/network-settings"
        fi
    fi

    # unmount
    umount "$workarea/disk/var"
    umount "$workarea/disk"
    if [ -e "$rootfsbzip" ]
    then
       umount "$workarea/rootfs"
    fi

    rm -rf "$workarea"
}

start_sys_raid()
{
    local diska=$1
    local diskb=$2

    mdadm --create $MD1 --auto=md --raid-devices=2 --level=raid1 --run --metadata=0.90 --assume-clean "${diska}1" "${diskb}1"
    mdadm --create $MD2 --auto=md --raid-devices=2 --level=raid1 --run --metadata=0.90 --assume-clean "${diska}2" "${diskb}2"
    mdadm --create $MD3 --auto=md --raid-devices=2 --level=raid1 --run --metadata=0.90 --assume-clean "${diska}3" "${diskb}3"
}

format_sys_partitions()
{
    mkfs.ext3   $MD1
    mkswap      $MD2
    mkfs.ext3   $MD3
}

stop_raid()
{
    mdadm --stop --scan
}

start_usr_raid()
{
    local diska=$1
    local diskb=$2

    mdadm --create $MD4 --auto=md --raid-devices=2 --level=raid1 --run --metadata=0.90 --assume-clean "${diska}4" "${diskb}4"
}

format_usr_partitions()
{
    mkfs.xfs -f -l lazy-count=1 $MD4
}

# Create a 1nc system
sanityCheck $1 $2 $3
create_partitions $1
create_partitions $2
sleep 2
write_bootrom_directions $1
write_bootrom_directions $2
write_hidden_sectors $1
write_hidden_sectors $2
stop_raid
start_sys_raid $1 $2
format_sys_partitions
copyRootFilesystem "$3" "2nc"
stop_raid
start_usr_raid $1 $2
format_usr_partitions
sleep 2
stop_raid
