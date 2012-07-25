#!/bin/sh
#

start() {
	# If inetd is not running
	RUNNING=`ps -AH | grep " inetd$"`
	if [ -z "$RUNNING" ]
	then
		echo "Starting inetd"
		/usr/sbin/inetd
	fi
}

stop() {
	# If inetd is running
	RUNNING=`ps -AH | grep " inetd$"`
	if [ -n "$RUNNING" ]
	then
		echo "Stopping inetd"
		killall inetd
	fi
}

restart() {
    stop
    start
}

cleanup() {
	rm -f $PIDFILE
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
		cleanup
		;;
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

