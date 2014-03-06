#!/bin/sh
#
# Start ProFTPD
#

start() {
	echo "Starting ProFTPD"
	if [ \! -r /var/oxsemi/proftpd.sqlite3 ] ; then
		sudo -u www-data /usr/www/nbin/ftpacl.pl init
		sudo -u www-data /usr/www/nbin/ftpacl.pl add_user www-data
	fi
	### always rebuild (see /etc/inittab, for example)
	sudo -u www-data /usr/www/nbin/ftpacl.pl rebuild_configs
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

reread_config() {
###	kill -HUP `cat /usr/local/var/proftpd.pid`  # right way
  	killall -HUP proftpd
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
	reread_config)
		reread_config
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

