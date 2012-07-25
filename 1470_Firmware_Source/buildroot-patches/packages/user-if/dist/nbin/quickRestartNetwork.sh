#!/bin/sh
#
# Restart the network, re-reading the config files.
/etc/init.d/network_control.sh restart > /var/log/network.stdout 2> /var/log/network.stderr
exit 0

