#!/bin/sh

quit()
{
    echo $1
    exit 1
}

# Do run if the share directory already exists
[ -d /shares/fast ] && quit "Fast share already exists"

# Add mount for fast partition
mkdir /shares/fast
echo "/dev/sda4	/shares/fast	xfs	defaults,nobarrier,noatime,nodiratime,logbufs=8 0	2" >> /etc/fstab
mount /shares/fast
chown 33:33 /shares/fast
chmod 700 /shares/fast

# Modify smb.conf for fast mode support
echo "[global]" >> /etc/smb.conf
echo "peek command type=yes" >> /etc/smb.conf

# Add share definition for fast support
echo "[fast]" >> /var/oxsemi/shares.inc
echo "path=/shares/fast" >> /var/oxsemi/shares.inc
echo "force user=www-data" >> /var/oxsemi/shares.inc
echo "valid users=www-data" >> /var/oxsemi/shares.inc
echo "write list=www-data" >> /var/oxsemi/shares.inc
echo "guest ok=Yes" >> /var/oxsemi/shares.inc
echo "preallocate=Yes" >> /var/oxsemi/shares.inc
echo "incoherent=yes" >> /var/oxsemi/shares.inc
echo "direct writes=2" >> /var/oxsemi/shares.inc