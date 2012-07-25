#!/bin/sh
#
# Start the time protocol daemon ....
#
LOGS=/var/log
NTPD_LOG=$LOGS/ntp.log

pidfile=/var/run/ntpd.pid

rotate_log() {
	if [ -f $NTPD_LOG ];
	then
		mv $NTPD_LOG ${NTPD_LOG}.old
	fi
}

initial_time_adjust() {
	/usr/bin/ntpdate $(awk '/server/ {print $2}' /etc/ntp.conf)
}

start() {
	if [ ! -e "$pidfile" ]
	then
		initial_time_adjust
		rotate_log
		echo "Starting ntpd"
		/usr/sbin/ntpd -p $pidfile
	fi
}

stop() {
	if [ -e "$pidfile" ]
	then
		# Sometimes two NTP processes are started and I do not know why
		# so ensure both are killed off
		echo "Stoping ntpd"
		killall ntpd > /dev/null 2>&1
		rm $pidfile
	fi
}

reload() {
	stop
	start
}

cleanup() {
	rm -f $pidfile
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
	cleanup)
		cleanup
		;;
	*)
		echo $"Usage: $0 {start|stop|reload|cleanup}"
		exit 1
esac

exit $?

