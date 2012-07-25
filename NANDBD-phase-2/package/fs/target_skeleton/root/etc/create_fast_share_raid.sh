#!/bin/sh

export FAST_SHARE="/shares/internal/fast"

quit()
{
    echo $1
    exit 1
}

# Do not run if the share directory already exists
[ -d "$FAST_SHARE" ] && quit "Fast share already exists"

# Add directory for the default fast share
mkdir "$FAST_SHARE"
chown 33:33 "$FAST_SHARE"
chmod 700 "$FAST_SHARE"

# Modify smb.conf for fast mode support
echo "[global]" >> /etc/smb.conf
echo "peek command type=yes" >> /etc/smb.conf

# Add share definition for fast support
echo "[fast]" >> /var/oxsemi/shares.inc
echo "path=""$FAST_SHARE" >> /var/oxsemi/shares.inc
echo "force user=www-data" >> /var/oxsemi/shares.inc
echo "valid users=www-data" >> /var/oxsemi/shares.inc
echo "write list=www-data" >> /var/oxsemi/shares.inc
echo "guest ok=Yes" >> /var/oxsemi/shares.inc
echo "preallocate=Yes" >> /var/oxsemi/shares.inc
echo "incoherent=yes" >> /var/oxsemi/shares.inc
echo "direct writes=2" >> /var/oxsemi/shares.inc