#!/bin/sh
#
# Sets the date on the device
#
# Ian Steel
# September 2006
#
. /usr/www/nbin/commonfuncs

DD=$1
MM=$2
YYYY=$3

NOW_FILE="/var/lib/now"

# Get the current time as this is needed as part of the new date/time string
#
HHmm=`date +%H%M`
echo "HHmm: $HHmm"

echo "date '$MM$DD$HHmm$YYYY'"
date "$MM$DD$HHmm$YYYY"

date +%m%d%H%M%Y.%S > $NOW_FILE
