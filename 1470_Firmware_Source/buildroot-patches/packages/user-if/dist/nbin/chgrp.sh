#!/bin/sh
#
# Sets group on the specified file.
#
#

PERMS=$1
FNAME=$2

chgrp $PERMS $FNAME
