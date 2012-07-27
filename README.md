See the README in https://github.com/wagle/addnas for a master index of repos.

This repo contains the source code for the linux distribution for the ADDNAS.

1470_Firmware_Source contains the source code for the root file system.
NANDBD-phase-1 contains the source code for the first phase of the upgrader.
NANDBD-phase-2 contains the source code for the second phase of the upgrader.

The usual procedure on the cross-compiling build machine (see master index as above for how to create a build machine):

```bash
cd addnas_source
cd NANDBD-phase-2
time make > make.out 2>&1
cd ../1470_Firmware_Source
cp -a ../NANDBD-phase-2/build_arm/linux-kernel .
time ./build.sh 7821TSI
```