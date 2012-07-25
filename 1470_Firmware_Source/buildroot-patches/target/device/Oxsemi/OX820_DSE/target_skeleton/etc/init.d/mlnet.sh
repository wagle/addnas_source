#!/bin/sh

export MLDONKEY_DIR=`/bin/cat /var/oxsemi/mlpath`
export MLDONKEY_CHROOT=`/bin/cat /var/oxsemi/mlpath`
export SUBNETBCAST=`/sbin/ifconfig |grep 'Bcast:' |cut -d: -f3 |awk '{print $1}'`

start()
{
if [ -d "$MLDONKEY_DIR" ]; then
	/bin/echo "Setting permissions..."
	/bin/chmod -R 644 $MLDONKEY_DIR/*
	/bin/echo "Starting program"
	if [ -f "$MLDONKEY_DIR/firstrundone" ]; then
	    	(/usr/bin/sudo /sbin/mlnet.static -run_as_useruid 0 -pid / -allowed_ips "127.0.0.1 $SUBNETBCAST" 1>/dev/null 2>/dev/null &)
	else
		/bin/mkdir $MLDONKEY_DIR/etc
		/bin/cp /etc/resolv.conf $MLDONKEY_DIR/etc/resolv.conf
		/bin/mkdir $MLDONKEY_DIR/dev
		/bin/mknod $MLDONKEY_DIR/dev/null c 1 3
		/bin/mknod $MLDONKEY_DIR/dev/urandom c 1 9
	    	(/usr/bin/sudo /sbin/mlnet.static -run_as_useruid 0 -pid / -allowed_ips "127.0.0.1 $SUBNETBCAST" 1>/dev/null 2>/dev/null &)
		/bin/touch $MLDONKEY_DIR/firstrundone
	fi
else
	/bin/echo "Directory does not exist!"
fi
/bin/sleep 10
}
stop()
{
	/bin/kill -15 `/bin/cat $MLDONKEY_DIR/mlnet.static.pid`
	/bin/sleep 5
}
cleanup()
{
	/bin/rm /var/run/mlnet.static.pid
}
resetpw()
{
	/bin/rm $MLDONKEY_DIR/users.ini
}
case "$1" in
	start)
		/bin/echo -n "Starting mldonkey: "
		start
		/bin/echo "DONE!"
		;;
	stop)
		/bin/echo -n "Stopping mldonkey: "
		stop
		/bin/echo "DONE!"
		;;
	restart)
		/bin/echo -n "Restarting mldonkey: "
		stop
		start
		/bin/echo "DONE!"
		;;
	force)
		/bin/echo -n "Forcing start of mldonkey: "
		cleanup
		start
		/bin/echo "DONE!"
		;;
	cleanup)
		cleanup
		;;
	resetpw)
		stop
		resetpw
		start
		;;
	*)
		/bin/echo "usage: /etc/init.d/mlnet.sh {start|stop|restart|force}"
		exit 1
		;;
esac
exit $?
