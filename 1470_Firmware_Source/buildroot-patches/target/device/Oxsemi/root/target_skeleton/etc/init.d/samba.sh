#!/bin/sh
#
# Start Samba
#
LOGS=/var/log
NMBD_LOG=$LOGS/log.nmbd
REBUILD="su www-data -c /etc/init.d/rebuild_share_access_tables.pl"

start() {
	echo "Starting Samba"
	$REBUILD
	if [ -f $NMBD_LOG ];
	then
		mv $NMBD_LOG ${NMBD_LOG}.old
	fi
	/usr/local/samba/sbin/nmbd -D -s/etc/smb.conf -l${LOGS} -d0
	/usr/local/samba/sbin/smbd -D -s/etc/smb.conf -l${LOGS} -d0
}

stop() {
	echo "Stopping Samba"
	killall nmbd > /dev/null 2>&1
	killall smbd > /dev/null 2>&1
}
restart() {
	stop
	start
}
reconfig() {
        $REBUILD
        killall -HUP smbd
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	cleanup)
		;;
	reconfig)
		reconfig
		;;
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

