#!/usr/bin/env bash

# This file contains aliases and functions that duplicate some fish
# functionality, because Vim will use bash as its external command shell.

function a() {
    if [ -f '.agignorevcs' ]; then
        ag -U $*
    else
        ag $*
    fi
}
