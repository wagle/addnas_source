#!/bin/sh

HN=$(hostname)
WG=$(grep "^workgroup=" /etc/smb.conf | cut -d = -f 2-)
TS=$(grep ^server /etc/ntp.conf | cut -d " " -f 2)
SD=$(grep "^network_mode=" /var/oxsemi/network-settings | cut -d = -f 2-)
IP=$(ip -f inet address show eth0 | tail -1 | sed -r "s/^[ ]+inet ([^ ]+).+$/\1/")
GW=$(ip route | grep "^default via " | cut -d " " -f 3)
HA=$(ip link show eth0 | tail -1 | sed -r "s/^[ ]+link\/ether ([^ ]+).+$/\1/")
NS=$(grep ^nameserver /etc/resolv.conf | cut -d " " -f 2)

echo HN $HN
echo WG $WG
echo TS $TS
echo SD $SD
echo IP $IP
echo GW $GW
echo HA $HA
echo NS $NS
