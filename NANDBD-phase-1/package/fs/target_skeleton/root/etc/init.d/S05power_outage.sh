#!/bin/sh
#
#
# Checks the cmdline arguments to see if there has been a power outage
# and writes the power_outage file

POWER_OUTAGE_FILE="/var/lib/power_outage"

# find the power outage status
pmode=`cat /proc/cmdline`
pmode=`expr "$pmode" : '.*poweroutage=\([^ ]*\)'`

if [ "${pmode}" = "yes" ]; then
	# update the power_outage file to reflect the power outage
	if [ -e $POWER_OUTAGE_FILE ]                  
        then                                       
        	#delete any old file present                    
        	rm -r $POWER_OUTAGE_FILE                 
	fi                                         
        #Set data into file                        
        echo "1" > $POWER_OUTAGE_FILE                
        sync
fi
