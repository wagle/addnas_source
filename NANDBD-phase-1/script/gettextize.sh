#!/bin/sh

if [ $# -lt 3 ]; then
	echo "Usage:$0 Base Project Lang"
	exit 1
fi

SCRIPT_DIR=`dirname $0`
BASE=$1
PROJECT=$2
LANG_PACK=$3

PATH="$PATH:$BASE"
export PATH

PY=`ls $BASE/cgi-bin/*.py`
CGI=`ls $BASE/cgi-bin/*.cgi`
FCGI=`ls $BASE/cgi-bin/*.fcgi`

#pygettext.py -a -d domain -o pot_file sources
chmod +x $SCRIPT_DIR/pygettext.py
$SCRIPT_DIR/pygettext.py -a -d $PROJECT -o $BASE/po/$PROJECT.pot $PY $CGI $FCGI

for l in $LANG_PACK; do
	msgmerge -U --backup=off $BASE/po/$l/$PROJECT.po $BASE/po/$PROJECT.pot
done

