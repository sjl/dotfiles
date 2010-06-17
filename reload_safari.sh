#!/usr/bin/env bash

sleep 1
echo "reloading..."

osascript  &>/dev/null <<EOF
tell application "Safari"
	do JavaScript "window.location.reload()" in front document
end tell
EOF

