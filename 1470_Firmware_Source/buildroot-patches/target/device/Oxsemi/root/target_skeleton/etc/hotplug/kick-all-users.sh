#!/bin/sh

##
# list_partition_users <major> <minor>
##
list_partition_users () {
	TARGET_MAJOR=$1
	TARGET_MINOR=$2
	NEWLINE=$'\n'
	lsof -FcD0 | while read -d "" ; do    ### zero delimited strings
		CONTENT=${REPLY//$NEWLINE}    ### get rid of extraneous newlines
		case $CONTENT in
		p*)
			PID=${CONTENT:1}
			;;
		c*)
			CMD=${CONTENT:1}
			;;
		D*)
			DEV=00000000${CONTENT:3}  ### strip off leading 0x and zero fill
			DEV=${DEV: -8}            ### eight hex digits
			MAJOR=$((16#${DEV:0:6}))  ### in base 10
			MINOR=$((16#${DEV: -2}))  ### in base 10
			if [ $MAJOR -eq $TARGET_MAJOR -a $MINOR -eq $TARGET_MINOR ] ; then
				echo "KICK-ALL-USERS: found PID $PID running CMD $CMD" > /dev/console
				echo $PID
			fi
			;;
		*)
			echo "KICK-ALL-USERS: MARTIAN:$REPLY:$CONTENT" | od -c > /dev/console
			;;
		esac
	done
}
##
#  do_kick <disk> <signal>
##
do_kick () {
        signal="$1"
	device="$2"
	major="$(echo $device | sed 's/:.*$//')"
	minor="$(echo $device | sed 's/^.*://')"
	pidlist=$(list_partition_users "$major" "$minor" | sort | uniq)
        echo "KICK-ALL-USERS: kill $signal $pidlist" > /dev/console
	if [ -n "$pidlist" ] ; then
	        kill "$signal" $pidlist
		return 0
	else
		return 1
	fi
}
##################
## main program ##
##################
usage () {
        echo "$0 <signal> <device>"
        exit 99
}

[ $# -eq 2 ] || usage
do_kick "$1" "$2" ; exit $?
