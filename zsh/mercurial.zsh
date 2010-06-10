#!/usr/bin/env zsh

alias calctime="sed -e 's/{t: *\([0-9]*\)*.*/\1/' | python -c 'import sys; print sum(map(int, sys.stdin.readlines())) / 60.0, \"hours\"'"
alias hgt='hg log -vd "`date -j \"+%Y-%m-%d\"`" -u steve | grep "{t:" | calctime'

function pull_everything() {
    for repo in $( ls -1 ); do
        if [[ -d $repo && -d $repo/.hg ]]; then
            echo "Pulling" $repo
            hg -R $repo pull -u
            echo
        fi
    done
}
