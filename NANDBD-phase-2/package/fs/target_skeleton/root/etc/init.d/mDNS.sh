#!/bin/sh
#

mDNSconfig=/etc/mDNSResponderPosix
mDNSpidfile=/var/run/mDNSResponder.pid

start() {
	if [ ! -e "$mDNSpidfile" ]
	then
		echo "Starting mDNS"
		/usr/sbin/mDNSResponderPosix -f $mDNSconfig -b
	fi
}

stop() {
	if [ -e "$mDNSpidfile" ]
	then
		echo "Stoping mDNS"
		kill -TERM `cat $mDNSpidfile` 2>/dev/null
		rm $mDNSpidfile
	fi
}

restart() {
    stop
    start
}

cleanup() {
	rm -f $mDNSpidfile
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

