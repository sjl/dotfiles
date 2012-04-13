#!/bin/bash
# THIS IS A WORK IN PROGRESS
# BE CAREFUL, DAMMIT

set -e

function ensure_link {
    test -L "$HOME/$2" || ln -s "$HOME/$1" "$HOME/$2"
}

mkdir -p ~/lib/hg
mkdir -p ~/lib/virtualenvs
mkdir -p ~/bin
mkdir -p ~/src

test -d ~/.hg-git/        || clone "bb://durin42/hg-git/" "$HOME/.hg-git"
test -d ~/.hg-git/dulwich || git clone "git://github.com/jelmer/dulwich.git" "$HOME/lib/dulwich"
ensure_link "lib/dulwich" "lib/hg/hg-stable/dulwich"

test -d ~/lib/dotfiles || hg clone http://bitbucket.org/sjl/dotfiles ~/lib/dotfiles
test -d ~/lib/oh-my-zsh || git clone git://github.com/sjl/oh-my-zsh ~/lib/oh-my-zsh

ensure_link "lib/dotfiles/tmux/tmux.conf" ".tmux.conf"
ensure_link "lib/dotfiles/vim"            ".vim"
ensure_link "lib/dotfiles/vim/vimrc"      ".vimrc"
ensure_link "lib/dotfiles/hgrc"           ".hgrc"
ensure_link "lib/dotfiles/gitconfig"      ".gitconfig"
ensure_link "lib/dotfiles/ackrc"          ".ackrc"
ensure_link "lib/dotfiles/zsh"            "lib/oh-my-zsh/custom"
ensure_link "lib/dotfiles/zshrc"          ".zshrc"

hg clone "bb://sjl/hg-prompt/"       "$HOME/lib/dotfiles/mercurial/hg-prompt"
hg clone "bb://ccaughie/hgcollapse/" "$HOME/lib/dotfiles/mercurial/hgcollapse"
hg clone "bb://durin42/histedit/"    "$HOME/lib/dotfiles/mercurial/histedit"


