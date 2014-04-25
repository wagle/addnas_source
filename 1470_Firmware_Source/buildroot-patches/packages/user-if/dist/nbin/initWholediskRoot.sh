#!/bin/sh
#
# Initialize the wholedisk share directory root for Samba

MPNT=$1

chown www-data.www-data "/shares/$MPNT"
chmod 0770 "/shares/$MPNT"
