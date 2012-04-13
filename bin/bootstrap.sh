#!/bin/bash

set -e

# THIS IS A WORK IN PROGRESS
# BE CAREFUL, DAMMIT

mkdir -p lib/hg
mkdir -p lib/python
mkdir -p lib/virtualenvs
mkdir -p ~/bin
mkdir -p ~/src

# hg clone 'http://selenic.com/repo/hg#stable' ~/lib/hg/hg-stable
# cd ~/lib/hg/hg-stable
# make local
# cd
# export PATH="$HOME/lib/hg/hg-stable:$PATH"

test -d ~/lib/dotfiles || hg clone http://bitbucket.org/sjl/dotfiles ~/lib/dotfiles
test -d ~/lib/oh-my-zsh || git clone git://github.com/sjl/oh-my-zsh ~/lib/oh-my-zsh

function ensure_link {
    test -L "$HOME/$2" || ln -s "$HOME/$1" "$HOME/$2"
}

ensure_link "lib/dotfiles/tmux/tmux.conf" ".tmux.conf"
ensure_link "lib/dotfiles/vim"            ".vim"
ensure_link "lib/dotfiles/vim/vimrc"      ".vimrc"
ensure_link "lib/dotfiles/hgrc"           ".hgrc"
ensure_link "lib/dotfiles/gitconfig"      ".gitconfig"
ensure_link "lib/dotfiles/ackrc"          ".ackrc"
ensure_link "lib/dotfiles/zsh"            "lib/oh-my-zsh/custom"
ensure_link "lib/dotfiles/zshrc"          ".zshrc"

git clone "git://github.com/jelmer/dulwich.git" "$HOME/lib/dulwich"
ensure_link "lib/dulwich" "lib/hg/hg-stable/dulwich"
