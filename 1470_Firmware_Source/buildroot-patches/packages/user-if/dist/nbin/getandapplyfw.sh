#!/bin/bash
#
#	Downloads the latest firmware and then applies it.
#
#	Indicates progress by creating 'status' files.
#

. /usr/www/nbin/commonfuncs

URL=$1

	{ { touch /tmp/active_upgrade; \
        $NAS_NBIN/wget.sh '/var/upgrade/latestfw.sh' "$URL" && \
	touch /var/upgrade/fwdownloaded && \
	chmod +x /var/upgrade/latestfw.sh && \
	/var/upgrade/latestfw.sh && \
	/var/upgrade/upgrade1.sh && \
	touch /var/upgrade/fwinstalled ; } || \
	{ rm -f /var/upgrade/* ; \
	  rm -f /tmp/active_upgrade ; }  } &

