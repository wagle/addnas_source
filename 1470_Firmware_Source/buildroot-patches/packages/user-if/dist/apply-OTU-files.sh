#!/bin/bash 
# J J Larkworthy 30 May 2007
#
# Script to automate the application of the OTU upgrade archive.

ARCHIVE=${1:?"OTU archive file not set properly in apply script"}


tar -xzf $ARCHIVE -C /
mkdir /var/pending
/etc/init.d/lighttpd.sh restart

