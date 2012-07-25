#!/bin/sh
#
# Sets the time on the device
#
# Ian Steel
# September 2006
#
#. $NAS_NBIN/commonfuncs

hh=$1
mm=$2

NOW_FILE="/var/lib/now"

# Get the current time as this is needed as part of the new date/time string
#
MMDD=`date +%m%d`
echo "MMDD: $MMDD"

echo "date '$MMDD$hh$mm'"
date "$MMDD$hh$mm"

date +%m%d%H%M%Y.%S > $NOW_FILE
