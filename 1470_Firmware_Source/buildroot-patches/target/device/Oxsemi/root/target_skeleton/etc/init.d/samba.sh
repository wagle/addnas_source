#!/bin/sh
#
# Start Samba
#
LOGS=/var/log
NMBD_LOG=$LOGS/log.nmbd
REANNOTATE="su www-data -c /etc/init.d/reannotate_samba_shares.pl"

start() {
	echo "Starting Samba"
	$REANNOTATE
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
        $REANNOTATE
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
	reread_config)
		reconfig
		;;
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

