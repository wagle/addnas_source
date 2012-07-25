#!/bin/sh

##
# isa_disk <disk>
##
isa_disk () {
	list_of_disks | grep -q "^$1$"
}
##
# list_of_disks
##
list_of_disks () {
	for disk in /sys/block/sd? ; do
		echo $(basename $disk)
	done
}
##
# list_of_partitions <disk>
##
list_of_partitions () {
	for partition in /sys/block/$1/$1? ; do
		echo $(basename $partition)
	done
}
##
# dump_disk_info <disk>
##
dump_disk_info () {
	echo "disk $1"
}
##
# dump_partition_info <disk> <partition>
##
dump_partition_info () {
	echo "  partition $2 is device $(cat /sys/block/$1/$2/dev)"
}
##
#  function_echo <dummy> <pid> <cmd>
##
function_echo () {
	echo "    PID $2 CMD $3" 
}
##
#  function_kill <signal> <pid> <cmd>
##
function_kill () {
	echo "MOUNT-O-MATIC: kill $1 $2" > /dev/console
	kill $1 $2
}
##
# map_partition_users <function> <arg> <disk> <partition>
##
map_partition_users () {
	FUNCTION=$1
	ARG=$2
	TARGET_MAJOR=$3
	TARGET_MINOR=$4
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
				"$FUNCTION" "$ARG" "$PID" "$CMD"
			fi
			;;
		*)
			echo "MARTIAN:$REPLY:$CONTENT" | od -c
			;;
		esac
	done
}
##
#  get_partition_major <disk> <partition>
##
get_partition_major () {
	sed 's/:.*$//' /sys/block/$1/$2/dev 
}
##
#  get_partition_minor <disk> <partition>
##
get_partition_minor () {
        sed 's/^.*://' /sys/block/$1/$2/dev        
}
##
# do_info
##
do_info () {
	for disk in $(list_of_disks) ; do
		dump_disk_info $disk
		for partition in $(list_of_partitions $disk) ; do
			dump_partition_info $disk $partition
			map_partition_users function_echo "" "$(get_partition_major $disk $partition)"  "$(get_partition_minor $disk $partition)"
		done
	done
	return 0
}
##
#  do_status <disk>
##
do_status () {
	disk=$1
	for partition in $(list_of_partitions $disk) ; do
		COUNT=$(map_partition_users function_echo "" "$(get_partition_major $disk $partition)"  "$(get_partition_minor $disk $partition)" | wc -l)
		[ $COUNT -eq 0 ] ; return $?
	done
	return 0
}
##
#  do_close <disk>
##
do_close () {
        disk=$1
        for partition in $(list_of_partitions $disk) ; do
		umount /dev/$partition
        done
	do_status $disk
}
##
#  do_detach <disk>
##
do_detach () {
        disk=$1
        for partition in $(list_of_partitions $disk) ; do
		umount -f /dev/$partition
        done
	do_status $disk
}
##
#  do_kick <disk> <signal>
##
do_kick () {
        disk=$1
	device=$2
	signal=$3
        for partition in $(list_of_partitions $disk) ; do
                dump_partition_info $disk $partition
                map_partition_users function_kill "$signal" "$(get_partition_major $disk $partition)"  "$(get_partition_minor $disk $partition)"
        done
        sleep 3
	do_status $disk
}
##################
## main program ##
##################
usage () {
        echo "mount-o-matic info"
        echo "mount-o-matic status <disk> <device>"
        echo "mount-o-matic close <disk> <device>"
        echo "mount-o-matic detach <disk> <device>"
        echo "mount-o-matic kick <disk> <device> <signal>"
        exit 99
}

[ $# -ge 1 ] || usage
case $1 in
info)
        [ $# -eq 1 ] || usage
	do_info ; exit $?
        ;;
status)
        [ $# -eq 3 ] && isa_disk $2 || usage
	do_status $2 $3 ; exit $?
	;;
close)
        [ $# -eq 3 ] && isa_disk $2 || usage
	do_close $2 $3; exit $?
	;;
detach)
        [ $# -eq 3 ] && isa_disk $2 || usage
	do_detach $2 $3; exit $?
	;;
kick)
        [ $# -eq 4 ] && isa_disk $2 || usage
	do_kick $2 $3 $4; exit $?
	;;
*)
	usage
esac

echo "you shouldn't get here"
exit 98
