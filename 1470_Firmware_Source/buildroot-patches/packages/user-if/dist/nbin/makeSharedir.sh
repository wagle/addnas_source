#!/bin/sh
#
# Creates the share directory for Samba
#
# Ian Steel
# September 2006
#
. /usr/www/nbin/commonfuncs

# Absorb ALL parameters. This seems to handle spaces in share names ok.
#
DIR=$*

mkdir "/shares/$DIR"

chmod o-rwx "/shares/$DIR"
chown www-data.www-data "/shares/$DIR"
