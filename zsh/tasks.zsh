#!/usr/bin/env zsh

alias t='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt'
alias m='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=music.txt'
alias g='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=groceries.txt'
alias k='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=books.txt'
alias p='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=pack.txt'
alias d='~/lib/t/t.py --task-dir="~/Desktop" --list=todo.txt --delete-if-empty'
alias b='~/lib/t/t.py --list=bugs'

alias pa='~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=pack-archive'
function packfor() {
    cp "$HOME/Dropbox/tasks/pack-archive" "$HOME/Dropbox/tasks/pack.txt"
    touch "$HOME/Dropbox/tasks/.pack.txt.done"
}
