#!/bin/sh
#
# Start or Stop the filesharing processes.
#
# Usage: shareControl.sh start|stop|check_internal|check_external
#	stop - stops shares and checks the partition is not in use.
#	start - starts the share daemons.
#	check_internal - Checks that the internal shares are not in use
#	check_external - Checks that the internal shares are not in use
# Returns
# 0 - OK
# 100 - shares/internal busy according to lsof
# 101 - shares/internal busy according to samba
# 200 - shares/external busy according to lsof
# 201 - shares/external busy according to samba

OP=$1
DEV=$2

echo "$0: OP=$OP DEV=$DEV" > /dev/console

if [ -z "$OP" ]; then
	OP=start
fi

#echo sharesControl.sh $OP $PART >&2
if [ $OP = 'start' ]; then
#	/etc/init.d/nfs.sh start
	/etc/init.d/samba.sh start
fi

if [ $OP = 'stop' ]; then
#	/etc/init.d/nfs.sh stop
	/etc/init.d/samba.sh stop
fi

if [ $OP = 'check_internal' ]; then
	# Check nothing is using the shares/internal
	if [ -n "`lsof |grep /shares/internal`" ]; then
		exit 100
    fi
	if [ -n "`/usr/local/samba/bin/smbstatus -s /etc/smb.conf|grep 'shares/internal'`" ]; then
		exit 101
	fi
    exit 0
fi

if [ $OP = 'check_external' ]; then
	# Check nothing is using the shares/external
	patterns="$(grep "^$DEV" /proc/mounts | cut -f 2 -d " " | sed "s/^/-e /")"
	if [ -n "`lsof | grep $patterns`" ]; then
		echo "$0: lsof found something" > /dev/console
		exit 200
	fi
	if [ -n "`/usr/local/samba/bin/smbstatus -s /etc/smb.conf | grep $patterns`" ]; then
		echo "$0: smbstatus found something" > /dev/console
		exit 201
	fi
	echo "$0: all clear" > /dev/console
    	exit 0
fi

exit 0
