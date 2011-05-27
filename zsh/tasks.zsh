#!/usr/bin/env zsh

alias t='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt'
alias w='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=work.txt'
alias p='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=pack.txt'
alias b='~/lib/t/t.py --list=bugs'

alias pa='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=pack-archive'
function packfor() {
    cp "$HOME/Dropbox/tasks/pack-archive" "$HOME/Dropbox/tasks/pack.txt"
    touch "$HOME/Dropbox/tasks/.pack.txt.done"
}
