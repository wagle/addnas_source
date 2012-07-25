#!/bin/sh
#
# Start or Stop the inetd daemon
#
# Usage: inetdControl.sh start|stop
#	stop  - stops inetd daemom
#	start - starts inetd daemon
#
# Returns:
# 0 - OK

OP=$1

if [ -z "$OP" ]; then
	OP=start
fi

if [ $OP = 'start' ]; then
	/etc/init.d/inetd.sh start
fi

if [ $OP = 'stop' ]; then
	/etc/init.d/inetd.sh stop
fi

exit 0
