#!/bin/sh
#
# network_servers.sh
#
# Script to start/stop all network dependent services
#

SCRIPTS_PATH=/etc/init.d
STATUS_FILES_PATH=/var/run
NETWORK_SERVERS_STARTED_FILE=$STATUS_FILES_PATH/network_servers_started

start() {
	if [ ! -e "$NETWORK_SERVERS_STARTED_FILE" ]
	then
		$SCRIPTS_PATH/ntp.sh start
		$SCRIPTS_PATH/inetd.sh start
		$SCRIPTS_PATH/mDNS.sh start
		$SCRIPTS_PATH/samba.sh start
		$SCRIPTS_PATH/raid_monitoring.sh start
		$SCRIPTS_PATH/lighttpd.sh start
		touch $NETWORK_SERVERS_STARTED_FILE
	fi
}

stop() {
	if [ -e "$NETWORK_SERVERS_STARTED_FILE" ]
	then
		$SCRIPTS_PATH/lighttpd.sh stop
		$SCRIPTS_PATH/raid_monitoring.sh stop
		$SCRIPTS_PATH/samba.sh stop
		$SCRIPTS_PATH/mDNS.sh stop
		$SCRIPTS_PATH/inetd.sh stop
		$SCRIPTS_PATH/ntp.sh stop
		rm $NETWORK_SERVERS_STARTED_FILE
	fi
}

restart() {
	stop
	start
}

cleanup() {
	rm -f $NETWORK_SERVERS_STARTED_FILE
	$SCRIPTS_PATH/lighttpd.sh cleanup
	$SCRIPTS_PATH/ntp.sh cleanup
	$SCRIPTS_PATH/inetd.sh cleanup
	$SCRIPTS_PATH/mDNS.sh cleanup
	$SCRIPTS_PATH/samba.sh cleanup
	$SCRIPTS_PATH/raid_monitoring.sh cleanup
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

