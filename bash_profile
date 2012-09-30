#!/usr/bin/env bash

shopt -s expand_aliases


# This file contains aliases and functions that duplicate some fish
# functionality, because Vim will use bash as its external command shell.

function a() {
    if [ -f '.agignorevcs' ]; then
        ag -U $*
    else
        ag $*
    fi
}

export PATH=~/bin:~/lib/dotfiles/bin:/usr/local/share/python:$PATH
