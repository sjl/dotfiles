#!/usr/bin/env bash

echo "reloading..."

osascript  &>/dev/null <<EOF
tell application "Safari"
	do JavaScript "window.location.reload()" in front document
end tell
EOF

