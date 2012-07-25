#!/bin/sh
#
# post_network_start.sh
#
# Script to start/stop all services that need to start after all the network
# dependent services
#

SCRIPTS_PATH=/etc/init.d
STATUS_FILES_PATH=/var/run
POST_NETWORK_STARTED_FILE=$STATUS_FILES_PATH/post_network_started

start() {
	if [ ! -e "$POST_NETWORK_STARTED_FILE" ]
	then
		touch $POST_NETWORK_STARTED_FILE
	fi
}

stop() {
	if [ -e "$POST_NETWORK_STARTED_FILE" ]
	then
		rm $POST_NETWORK_STARTED_FILE
	fi
}

restart() {
	stop
	start
}

cleanup() {
	rm -f $POST_NETWORK_STARTED_FILE
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

