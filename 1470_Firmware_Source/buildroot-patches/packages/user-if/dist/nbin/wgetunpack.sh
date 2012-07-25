#!/bin/sh
#
#	Wrapper to 'wget'.
#
#	Takes 2 params: url - url of document to fetch
#			target - The filename which the document is fetched to
#
#
# Ian Steel
# November 2006
#
. /usr/www/nbin/commonfuncs

TGT=$1
URL=$2

cd /var/upgrade
rm -f $TGT
# translate plus in URL to ampersand
echo $URL | sed -e 's/+/\&/' >/var/upgrade/xx
echo "wget -O $TGT $URL"
wget -q -O $TGT `cat /var/upgrade/xx`

chmod 777 /home/fw.tar.gz
#tar -xvf $NAS_NBIN/fw.tar.gz
tar -xvf /home/fw.tar.gz -C /home/
