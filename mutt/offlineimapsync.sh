#!/bin/sh

kill `cat ~/.offlineimap/pid`

/usr/local/bin/offlineimap -o -u Noninteractive.Quiet &>/dev/null &

exit 0
