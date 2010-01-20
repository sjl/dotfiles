#!/usr/bin/env zsh

alias t='~/src/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt'
alias m='~/src/t/t.py --task-dir="~/Dropbox/tasks" --list=music.txt'
alias g='~/src/t/t.py --task-dir="~/Dropbox/tasks" --list=groceries.txt'
alias k='~/src/t/t.py --task-dir="~/Dropbox/tasks" --list=books.txt'
alias p='~/src/t/t.py --task-dir="~/Dropbox/tasks" --list=pack.txt'
alias b='~/src/t/t.py --list=bugs'

alias pa='~/src/t/t.py --task-dir="~/Dropbox/tasks" --list=pack-archive'
function packfor() {
    cp "$HOME/Dropbox/tasks/pack-archive" "$HOME/Dropbox/tasks/pack.txt"
    touch "$HOME/Dropbox/tasks/.pack.txt.done"
}
