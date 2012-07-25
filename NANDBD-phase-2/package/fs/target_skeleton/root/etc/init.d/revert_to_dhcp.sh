NETWORK_SETTINGS=/var/oxsemi/network-settings

echo "Changing network to use DHPC on next boot"

sed -i -e "s:revert_to_dhcp=yes$:revert_to_dhcp=no: " $NETWORK_SETTINGS

sed -i -e "s:network_mode=.*$:network_mode=dhcp: " $NETWORK_SETTINGS
