#/bin/sh
if awk '/system_type/ { print $0 }' /var/oxsemi/network-settings | cut -f 2 -d = | grep -i 1nc > /dev/null 2>&1
then
	exit 0;
fi
exit 1;
