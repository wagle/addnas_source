#/bin/sh
if awk /md4/ /proc/mdstat | grep -i md4 > /dev/null 2>&1
then
        exit 0;
fi
exit 1;
