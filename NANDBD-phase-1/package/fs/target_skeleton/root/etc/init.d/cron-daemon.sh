#!/bin/sh

start() {
	if !(ps -A | grep -q 'crond$') ; then
		echo "Starting crond"
		/usr/sbin/crond -c /etc/crontabs
	fi
}

stop() {
	echo "Stopping crond"
	killall crond > /dev/null 2>&1

	# Wait until process has really finished
	while ps -A | grep -q i'crond$' ; do
		echo "."
	done
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
