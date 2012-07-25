#!/bin/sh

quit()
{
    echo $1
    exit 1
}

[ -z $1 ] && quit "Usage: $0 install-dir"

installdir=$1

if [ -z $2 ]; then
NAS_VERSION=820
echo "Assuming target platform is 820"
else
NAS_VERSION=$2
fi

# where we expect to find the files
stage1File=stage1/stage1.wrapped
ubootFile=vendor/u-boot/u-boot.wrapped
kernelFile=linux-kernel/arch/arm/boot/uImage
rootfsbzip=buildroot-$NAS_VERSION/binaries/OX$NAS_VERSION/rootfs.arm.ext2.bz2

# check the files are present
[ -r "$stage1File" ] || quit "$stage1File isn't readable"
[ -r "$ubootFile"  ] || quit "$ubootFile isn't readable"
[ -r "$kernelFile" ] || quit "$kernelFile isn't readable"
[ -r "$rootfsbzip" ] || quit "$rootfsbzip isn't readable"

# copy the files to the install directory
cp $stage1File $installdir/
cp $ubootFile $installdir/
cp config/install* $installdir/
cp $kernelFile $installdir/
cp $rootfsbzip $installdir/
