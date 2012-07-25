#!/bin/sh

quit()
{
    echo $1
    exit 1
}

# check program arguments have been provided
[ -z $1 ] && quit "usage: $0 share-name"

# Do run if the share directory already exists
[ -d /shares/internal/$1 ] && quit "Fast share already exists"

# Create directory on fast partition for the new share
mkdir /shares/internal/$1
chown 33:33 /shares/internal/$1
chmod 700 /shares/internal/$1

# Add share definition for fast support
echo "[$1]" >> /var/oxsemi/shares.inc
echo "path=/shares/internal/$1" >> /var/oxsemi/shares.inc
echo "force user=www-data" >> /var/oxsemi/shares.inc
echo "valid users=www-data" >> /var/oxsemi/shares.inc
echo "write list=www-data" >> /var/oxsemi/shares.inc
echo "guest ok=Yes" >> /var/oxsemi/shares.inc
echo "preallocate=Yes" >> /var/oxsemi/shares.inc
echo "incoherent=yes" >> /var/oxsemi/shares.inc
echo "direct writes=2" >> /var/oxsemi/shares.inc