#!/bin/sh

STRIPCMD_STRIP_ALL="$1 --strip-all"
STRIPCMD_STRIP_DEBUG="$1 --strip-debug"
PREFIX=$2

for FILE in `find ${PREFIX} -type f`; do
	TARGET=`file ${FILE} | grep stripped`
	if test -z "${TARGET}"; then
		continue
	fi
	BIN=`echo ${TARGET} | grep executable`
	if test -n "${BIN}"; then
		#echo "Striping executable: ${FILE}"
		$STRIPCMD_STRIP_ALL ${FILE} > /dev/null 2>&1
	else
		#echo "Striping lib: ${FILE}"
		$STRIPCMD_STRIP_DEBUG ${FILE} > /dev/null 2>&1
	fi
done
