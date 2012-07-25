#!/bin/sh
#
# Runs ethtool to find network status
#
. /usr/www/nbin/commonfuncs

DEV=$1

/usr/sbin/ethtool $DEV
