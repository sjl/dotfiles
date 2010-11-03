#!/bin/sh


kill `cat ~/.offlineimap/pid`

/usr/local/bin/offlineimap -q -o -u Noninteractive.Quiet &>/dev/null &

exit 0
