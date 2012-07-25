#!/bin/sh
#
# Runs mdadm 
#
. /usr/www/nbin/commonfuncs

OPT1=$1
OPT2=$2
DEV=$3

/sbin/mdadm $OPT1 $OPT2 $DEV
