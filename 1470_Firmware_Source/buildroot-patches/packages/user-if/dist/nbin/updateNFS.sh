#!/bin/sh
#
# This calls exportfs to tell NFSD and chums that the exports file has changed
#
#

exportfs -rv >/dev/console 2>&1

