#!/bin/sh
#
# network_control
#
# To be called whilst the sysetm is in operation to stop/start networking
# and take account of all dependences
#

. /etc/default-settings
. /var/oxsemi/network-settings

RESOLV_CONF="/etc/resolv.conf"
NTP_CONF="/etc/ntp.conf"
SCRIPTS_PATH=/etc/init.d
STATUS_FILES_PATH=/var/run
UDHCPC_PID_FILE=$STATUS_FILES_PATH/udhcpc.eth0.pid
NETWORK_STARTED_FILE=$STATUS_FILES_PATH/network_started
CRONTAB_PATH=/etc/crontabs

start() {
	# If hostname not configured, use the default
	if [ -z "$hostname" ]
	then
		hostname=$default_hostname
	fi

	# Set the hostname
	/bin/hostname $hostname

	# If network mode not configured, use the default
	if [ -z "$network_mode" ]
	then
		network_mode=$default_network_mode
	fi

	# Bring eth0 up and give the hardware a chance to settle
	ip addr flush eth0
	ip link set dev eth0 up
	sleep 4

	# Bring up eth0
	if [ x$network_mode = x"dhcp" ]
	then
		# Use DHCP
		/sbin/udhcpc -n -p $UDHCPC_PID_FILE -i eth0 -H $hostname
	else
		$SCRIPTS_PATH/cron-daemon.sh stop

		# Use static address
		ip address add $static_ip/$static_msk brd + dev eth0

		# Add a static gateway if defined
		if [ -n "$static_gw" ]
		then
			/sbin/route add default gw $static_gw
		fi

		# Setup static DNS server addresses
		echo -n > $RESOLV_CONF
		if [ -n "$static_dns1" ]
		then
			echo nameserver $static_dns1 >> $RESOLV_CONF
		fi
		if [ -n "$static_dns2" ]
		then
			echo nameserver $static_dns2 >> $RESOLV_CONF
		fi
		if [ -n "$static_dns3" ]
		then
			echo nameserver $static_dns3 >> $RESOLV_CONF
		fi

		# Setup static NTP server address
		if [ -n "$static_ntp" ]
		then
			sed "s/server.*\$/server $static_ntp iburst/" < $NTP_CONF > tmp$$
			mv -f tmp$$ $NTP_CONF
		else
			sed "s/server.*\$/server/" < $NTP_CONF > tmp$$
			mv -f tmp$$ $NTP_CONF
		fi

		# Update configuration information used by network dependent services
		$SCRIPTS_PATH/update_network_config.sh $static_ip

		# Start servers dependent on networking
		$SCRIPTS_PATH/network_servers.sh start

		# Start services started after network dependent servers
		$SCRIPTS_PATH/post_network_start.sh start

		# Use the crontab without DHCP polling
		cp $CRONTAB_PATH/root-std $CRONTAB_PATH/root
		$SCRIPTS_PATH/cron-daemon.sh start

		if [ x$revert_to_dhcp = x"yes" ]
		then
			$SCRIPTS_PATH/revert_to_dhcp.sh
		fi

		# Create file indicating that networking has been started
		touch $NETWORK_STARTED_FILE
	fi
}

stop() {
	# Stop servers dependent on networking
	$SCRIPTS_PATH/network_servers.sh stop

	# Stop zcip
	killall zcip > /dev/null 2>&1

	# Stop udhcpc
	if [ -e "$UDHCPC_PID_FILE" ]
	then
		kill -TERM `cat $UDHCPC_PID_FILE` 2>/dev/null
	fi

	# Bring down eth0
	ip link set dev eth0 down
	ip addr flush eth0

	# Remove file indicating that networking has been started
	if [ -e "$NETWORK_STARTED_FILE" ]
	then
		rm $NETWORK_STARTED_FILE
	fi
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
		rm -f $UDHCPC_PID_FILE
		;;
	*)
		echo $"Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

