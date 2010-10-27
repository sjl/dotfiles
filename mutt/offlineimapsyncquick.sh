#!/bin/sh

PID=`/usr/local/bin/pgrep offlineimap`

[[ -n "$PID" ]] && kill $PID

/usr/local/bin/offlineimap -q -o -u Noninteractive.Quiet &>/dev/null &

exit 0
