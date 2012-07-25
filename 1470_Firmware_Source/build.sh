#!/bin/bash

if [[ $# -ne 1 ]]
then
	echo "Usage: build <device>"
	echo "where device is one of 7820, 7821, 7825"
	exit
fi

case $1 in
	7820 )
		kernel_config=ox820_testbrd_smp_TxSRAM_defconfig
		;;
	7821 )
		kernel_config=ox7821_testbrd_smp_TxSRAM_defconfig
		;;
	7825 )
		kernel_config=ox825_testbrd_smp_defconfig
		;;
	7821TSI )
		kernel_config=ox7821_defconfig
		;;
	* )
		echo "Unknown device specified"
		exit
		;;
esac

device=$1



##########################################################
## 7XXX SDK Build Script
##
## To build individual items, eg just stage1, follow
## instruction in the Building NAS 782x software guide
##
##########################################################

echo "Building the $device SDK"
echo "This might take several hours to complete, depending on client PC"

#########################################################
## Initial config, include output to logfile not stdout
#########################################################
logfile=$(pwd)/build.log
rm -f $logfile

function function_error()
{
	echo "Build failed - check logfile build.log to identify error"
	exit
}

# Work out where the script is and set the build area
BUILD_AREA=`pwd`
export BUILD_AREA

# From the build area, set the path to install modules in
INSTALL_MOD_PATH="$BUILD_AREA"/buildroot-$device/project_build_arm/OX820/root/
export INSTALL_MOD_PATH

# set the path to include install scripts and tools generated in the build process
PATH=/opt/arm-2009q3/bin:\
"$PATH":\
"$BUILD_AREA"/config/:\
"$BUILD_AREA"/vendor/u-boot/tools/:\
"$BUILD_AREA"/buildroot-$NAS_VERSION/build_arm/staging_dir/usr/bin
export PATH

#########################################################
## Building Buildroot
#########################################################
echo "Building Buildroot"

if [[ ! -d buildroot-$device ]]
then
	tar xf buildroot-20080620-nosvnfiles.tar.bz2
	mv buildroot buildroot-$device
fi

if [[ ! -f buildroot-$device/.done_patches ]]
then
	./buildroot-patches/snapshot.patch ./buildroot-patches buildroot-$device >> $logfile 2>&1
	touch buildroot-$device/.done_patches
fi

cp -f buildroot-patches/ubifsroot.mk buildroot-$device/target/ubifs/ubifsroot.mk
cp -f buildroot-patches/ntfs-3g.mk buildroot-$device/package/ntfs-3g/ntfs-3g.mk

cd buildroot-$device

cp target/device/Oxsemi/OX820_DSE/buildroot.defconfig .defconfig

make defconfig >> $logfile 2>&1
make >> $logfile 2>&1
if [[ $? -ne 0 ]]
then
	function_error
fi


#########################################################
## Building Build-tools
#########################################################
echo "Building boot-tools"

cd $BUILD_AREA/boot-tools
make >> $logfile 2>&1
if [[ $? -ne 0 ]]
then
	function_error
fi
#########################################################
## Building Stage1
## this builds for 750MHz
#########################################################
echo "Building stage1"

cd $BUILD_AREA/stage1
PLL_FIXED_INDEX=10 make >> $logfile 2>&1
if [[ $? -ne 0 ]]
then
	function_error
fi

#########################################################
## Building UBOOT
#########################################################
echo "Building U-Boot"

cd $BUILD_AREA/vendor/u-boot
make ox820_config >> $logfile 2>&1
make >> $logfile 2>&1
if [[ $? -ne 0 ]]
then
	function_error
fi
rm -f u-boot.wrapped 
$BUILD_AREA/stage1/tools/packager u-boot.bin u-boot.wrapped

#########################################################
## Building kernel
## THIS WILL TAKE SOME TIME !!!
#########################################################
echo "Building kernel"

cd $BUILD_AREA/linux-kernel
make $kernel_config
make uImage modules modules_install >> $logfile  2>&1
if [[ $? -ne 0 ]]
then
	function_error
fi

#########################################################
## Incorporate kernel modules into roof file system
#########################################################
echo "incoprorate kernel modules into root_fs"

cd $BUILD_AREA
mkdir -p $INSTALL_MOD_PATH/usr/lib/hotplug/firmware/ >/dev/null 2>&1
cp -f gmac_copro_firmware $INSTALL_MOD_PATH/usr/lib/hotplug/firmware/

cd $BUILD_AREA/buildroot-$device
make >> $logfile  2>&1
if [[ $? -ne 0 ]]
then
	function_error
fi

 
#########################################################
## Copy files to install_782x directory
#########################################################
echo "copy files to install_782x directory"

cd $BUILD_AREA
if [[ ! -d install_$device ]]
then
	rm -fr install_$device
fi

installdir=install_$device
[[ -d $installdir ]] || mkdir $installdir

# where we expect to find the files
stage1File=stage1/stage1.wrapped
ubootFile=vendor/u-boot/u-boot.wrapped
kernelFile=linux-kernel/arch/arm/boot/uImage
###rootfsbzip=buildroot-$device/binaries/OX820/rootfs.arm.ext2.bz2
rootfsUbifs=buildroot-$device/binaries/OX820/rootfs.arm.ubifs


# copy the files to the install directory
cp $stage1File $installdir/
cp $ubootFile $installdir/
cp config/install* $installdir/
cp $kernelFile $installdir/
###cp $rootfsbzip $installdir/
cp $rootfsUbifs $installdir/

cd install_$device/
ubinize -m 2KiB -p 128KiB -s 512 -o rootfs.arm.ubi $BUILD_AREA/ubi.cfg
###cp rootfs.arm.ubi ~/proj/upgrader/opt/upgrader/phase-1-chroot/var/images/

echo "BUILD has completed SUCCESSFULLY - now need to program your HDD"
echo "The binaries are in install_$device"
