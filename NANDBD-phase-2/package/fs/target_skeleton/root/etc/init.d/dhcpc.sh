#!/bin/sh

# Read in the system settings
. /etc/default-settings
. /var/oxsemi/network-settings

STATUS_FILES_PATH=/var/run
UDHCPC_PID_FILE=$STATUS_FILES_PATH/udhcpc.eth0.pid

# If network mode not configured, use the default
if [ -z "$network_mode" ]
then
	network_mode=$default_network_mode
fi

# If not static network mode
if [ x$network_mode = x"dhcp" ]
then
	# If DHCP client daemon is not running
	if !(ps -AH | grep -q udhcpc)
	then
		# Run DHCP client to attempt to obtain an IP address
		udhcpc -n -p $UDHCPC_PID_FILE -i eth0 -H $hostname
	fi
fi

