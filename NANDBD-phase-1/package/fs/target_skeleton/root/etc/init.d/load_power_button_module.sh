#/bin/sh
invert_leds=0
if /etc/init.d/test_is_1nc.sh
then
        invert_leds=1;
fi
/sbin/modprobe power_button invert_leds=$invert_leds

