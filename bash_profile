#!/usr/bin/env bash

shopt -s expand_aliases


# This file contains aliases and functions that duplicate some fish
# functionality, because Vim will use bash as its external command shell.

AG_BIN="`which ag`"
function ag() {
    if test -f '.agignore' && grep -q 'pragma: skipvcs' '.agignore'; then
        $AG_BIN --search-files -U $*
    else
        $AG_BIN --search-files $*
    fi
}

export PATH=~/bin:~/lib/dotfiles/bin:/usr/local/share/python:$PATH

alias h='hg'
alias g='git'
alias pbc='pbcopy'
alias pbp='pbpaste'
alias pbpb='pbp | pb'
alias vu='vagrant up'
alias vs='vagrant suspend'
alias o='open'
alias oo='open .'
alias t='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt'

function psg() {
    ps auxww | grep --color=always $* | grep -v grep | collapse | cuts -f 2,11-
}
