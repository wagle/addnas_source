#!/bin/sh
#
# update_network_config.sh
#
# Script to update configuration information used by network dependent services
#

ip=$1
domain=$2
current_hostname=`/bin/hostname`
hostsfile=/etc/hosts
mDNSconfig=/etc/mDNSResponderPosix

# Write a new /etc/hosts with the IP adr and domain
echo "127.0.0.1	localhost" > $hostsfile
if [ -n "$domain" ]
then
    echo $ip $current_hostname $current_hostname.$domain >> $hostsfile
else
    echo $ip $current_hostname >> $hostsfile
fi

# Write a new mDNS responder config file
echo "\"$current_hostname user if\"" > $mDNSconfig
echo "_http._tcp. local" >> $mDNSconfig
echo "80" >> $mDNSconfig
echo "$current_hostname file server user interface" >> $mDNSconfig

# Source the current network settings. Be careful as this will define the
# hostname variable, but we should be working with the current_hostname variable
# defined above, as the caller of this script has already set the system
# hostname taking into account default_hostname from /etc/default-settings and
# allowing this to be overridden by hostname from /var/oxsemi/network-settings
. /var/oxsemi/network-settings

# Update the interfaces/server string/workgroup settings in Samba config file
INTERFACES=$( ip -f inet address show | awk -v ORS=" " '$1 == "inet" {print $2}' )
cat <<EOF > /var/oxsemi/smb.header.conf
server string=$current_hostname
interfaces=$INTERFACES
workgroup=$workgroup
EOF

# Ensure correct ownership and permissions on the Samba config file
chown www-data:www-data  /var/oxsemi/smb.header.conf
chmod 664  /var/oxsemi/smb.header.conf

