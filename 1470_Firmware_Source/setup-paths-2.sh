#!/bin/sh
# run by typing "source ./setup-paths.sh"

if [ -z $1 ]; then
NAS_VERSION=820
echo "Assuming target platform is 820"
else
NAS_VERSION=$1
fi

# Work out where the script is and set the build area
BUILD_AREA=`pwd`
export BUILD_AREA

# From the build area, set the path to install modules in
INSTALL_MOD_PATH="$BUILD_AREA"/buildroot-$NAS_VERSION/project_build_arm/OX$NAS_VERSION/root/
export INSTALL_MOD_PATH

# set the path to include install scripts and tools generated in the build process
PATH="$PATH":\
"$BUILD_AREA"/config/:\
"$BUILD_AREA"/vendor/u-boot/tools/:\
"$BUILD_AREA"/buildroot-$NAS_VERSION/build_arm/staging_dir/usr/bin
export PATH
