#!/bin/sh
#
# Start ProFTPD
#

start() {
	echo "Starting ProFTPD"
	/usr/sbin/proftpd 
}

stop() {
	echo "Stopping ProFTPD"
	killall proftpd > /dev/null 2>&1
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
	get_port)
		grep "^Port" /etc/proftpd.conf | sed -r "s/^Port[ \t]+([0123456789]+)$/\1/"
		;;
	set_port)
		sed -i -r "s/^(Port[ \t]+)[0123456789]+$/\1$2/" /etc/proftpd.conf
		restart
		;;
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

