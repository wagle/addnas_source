#!/bin/sh
#
# Removes a Shared directory
#
# Ian Steel
# September 2006
#
. /usr/www/nbin/commonfuncs

SHDIR=$*

CWD=`pwd`
cd $SHARES_HOME

# As a safety measure, make sure that we have changed dir ok
#
if [ `pwd` == "$CWD" ]
then
  return
fi

if [ -d "$SHDIR" ]
then
   rm -rf "$SHDIR" 2>/dev/null
fi
