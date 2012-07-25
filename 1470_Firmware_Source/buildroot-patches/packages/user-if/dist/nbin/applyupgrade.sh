#!/bin/sh
#
#
#
#
#
. /usr/www/nbin/commonfuncs

TGT=$1
URL=$2
DRIVEROOT=$3

echo "APPLYUPGRADE: wget -O $TGT $URL" > /dev/console
wget -O $TGT $URL

chmod 777 $TGT 
rm -Rf $DRIVEROOT/dev
rm -Rf $DRIVEROOT/opt/upgrader

# do it twice to try to force write to disk
echo "APPLYUPGRADE: untar once" > /dev/console
tar -xvf $TGT -C $DRIVEROOT/
echo "APPLYUPGRADE: untar twice" > /dev/console
tar -xvf $TGT -C $DRIVEROOT/
echo "APPLYUPGRADE: triple sync" > /dev/console
sync
sync
sync

rm -f $DRIVEROOT/$TGT
echo "APPLYUPGRADE: start upgrader" > /dev/console
$DRIVEROOT/opt/upgrader/sbin/upgrader.sh
exitcode=$?
echo "APPLYUPGRADE: upgrader failed with exitcode $exitcode" > /dev/console
exit $exitcode
