#! /bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
NAME=lighttpd
DAEMON=/usr/sbin/$NAME
OPTS="-f /etc/lighttpd/lighttpd.conf"
LOGS=/var/log/lighttpd
ACCESS_LOG=$LOGS/access.log
ERROR_LOG=$LOGS/error.log

test -x $DAEMON || exit 0

# Include lighttpd defaults if available
if [ -f /etc/default/lighttpd ];
then
	. /etc/default/lighttpd
fi

set -e

cleanup() {
	rm -f /var/run/$NAME.pid
}

start() {
	echo "Starting $NAME"
	if [ -f $ACCESS_LOG ];
	then
		mv ${ACCESS_LOG} ${ACCESS_LOG}.old
	fi
	if [ -f $ERROR_LOG ];
	then
		mv ${ERROR_LOG} ${ERROR_LOG}.old
	fi
	start-stop-daemon --start --quiet --pidfile /var/run/$NAME.pid --exec $DAEMON -- $OPTS
}

stop() {
	echo "Stopping $NAME"
	if start-stop-daemon --stop --quiet --pidfile /var/run/$NAME.pid --exec $DAEMON;
	then
		# Wait a little before deleting PID file in case the occasion unlink
		# failure messages from lighttpd are due to a race in lighttpd shutting
		# down and this script deleting the PIC file
		sleep 1
		cleanup
	fi
}

reload() {
	echo "Reloading $NAME configuration files"
	start-stop-daemon --stop --signal 1 --quiet --pidfile /var/run/$NAME.pid --exec $DAEMON
}

restart() {
    stop
	# Original lighttpd script had sleep here - maybe due to lighttpd not really
	# having completely shutdown when start-stop-daemon returns
	sleep 1
    start
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	reload)
		reload
		;;
	restart)
		restart
		;;
	cleanup)
		cleanup
		;;
	*)
		N=/etc/init.d/$NAME
		echo "Usage: $N {start|stop|restart|reload}" >&2
		exit 1
		;;
esac

exit 0

