#!/bin/bash -x
# J J Larkworthy 30th May 2007
# This script serves to contain the optiona applied to tar when creating an archive fot the
# One Time Upgrade for converting a system from Phase 1 series of builds to the Phase 2
# push upgrade system.
#
# The OTU-file-list contains a list of files needed for the upgrade to allow a mio_upgrade.pl
# url to be enabled in the web server user interface. 
#
# This and the OTU-file-list should be copied to the buildroot/build_arm_nofpu/root sub-directory
# and executed there as './create-OTU-tar.sh the file list is relative to the 
# buildroot/build_arm_nofpu/root directory.
#
# This script is included in the top level directory for the user IF. The major changes are to
# patch the user interface to allow the addition of the mio_upgrade.pl into the user interface.
# The other files included in the created archive are in support of this added function.
#

tar --create --owner=0 --group=0 --file=OTU-archive.tar.gz --gzip --files-from=OTU-file-list

