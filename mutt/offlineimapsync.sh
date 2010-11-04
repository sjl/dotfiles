#!/bin/sh

PID=`cat ~/.offlineimap/pid`
ps aux | grep "[ ]$PID" && kill $PID

/usr/local/bin/offlineimap -o -u Noninteractive.Quiet &>/dev/null &

exit 0
