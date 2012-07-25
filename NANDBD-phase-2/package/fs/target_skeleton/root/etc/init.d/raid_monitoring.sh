#!/bin/sh
#
# Start the e-mail based RAID status reporting
#
pidfile=/var/run/mdadm.pid
languagefile=/var/oxsemi/nas.ini
SSMTP=/var/etc/ssmtp/ssmtp.conf

# creates an e-mail host
setupssmtpconf() {

    # get the hostname and domain from the /etc/hosts file (third field of
    # the line containing the hostname.
    unset emailhostname
    awk \{if\('$'2==\"`hostname`\"\)\{if\('$'3!=\"\"\)\{print\ \$3\}\}\} /etc/hosts >/tmp/domain
    if [ -e /tmp/domain ]
    then
        emailhostname=`cat /tmp/domain`
        rm /tmp/domain
    fi

    # massage the ssmtp config file
    if [ -n "$emailhostname" ]
    then
        TEMP=/tmp/ssmtp.conf
        sed -e "s/hostname=.*\$/hostname=$emailhostname/g" <$SSMTP >$TEMP
        if [ -e $TEMP ]
        then
            mv -f $TEMP $SSMTP
            # the web ui may want to edit this file
            chown www-data:www-data $SSMTP
            chmod 664 $SSMTP
        fi
    fi
}

# choose a raid messaging script based on our language
chooseraidscript() {
    if [ -e $languagefile ]
    then
        # get a language code from and select the appropriate script
        case `sed -n -e"s/language[ ^t]*=[ ^t]*//p" <$languagefile` in
        #fr )
        #    raidscript=RAID-message-sender-en.sh
        #    ;;
        en | *)
            # default to english
            raidscript=/etc/RAID-message-sender-en.sh
            ;;
        esac
    else
        # default to english
        raidscript=/etc/RAID-message-sender-en.sh
    fi
}

#
start() {
    echo "Starting RAID status reporting..."

    # check and fix mdadm.conf
    if [ ! -e /etc/mdadm.conf ]
    then
        echo "DEVICE partitions" > /etc/mdadm.conf
        /sbin/mdadm --examine --scan --config=partitions >>/etc/mdadm.conf
    fi

    setupssmtpconf

    # /sbin/mdadm --monitor --daemonize --pid-file=$pidfile --scan --alert /path-to-program-to-run-on-alert --delay=300`
}

#
stop() {
    echo "Stopping RAID status reporting..."

    # kill the mdadm monitor
    if [ -e $pidfile ]
    then
		killall mdadm > /dev/null 2>&1
		rm $pidfile
    fi
}

restart() {
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
	restart|reload)
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

