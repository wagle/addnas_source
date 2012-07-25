#!/bin/sh
#
# Start Samba
#
LOGS=/var/log
NMBD_LOG=$LOGS/log.nmbd

start() {
	echo "Starting Samba"
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
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

