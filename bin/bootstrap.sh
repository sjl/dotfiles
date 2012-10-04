#!/bin/bash
# THIS IS A WORK IN PROGRESS
# BE CAREFUL, DAMMIT

set -e

echo "prerequisites: python git pip dulwich tmux weechat offlineimap mutt hg ack zsh vim"

function ensure_link {
    test -L "$HOME/$2" || ln -s "$HOME/$1" "$HOME/$2"
}

mkdir -p ~/.config/fish
mkdir -p ~/lib/hg
mkdir -p ~/lib/virtualenvs
mkdir -p ~/bin
mkdir -p ~/src

ensure_link "lib/dotfiles/hgrc" ".hgrc"

test -d ~/.hg-git/    || hg clone "bb://durin42/hg-git/" "$HOME/.hg-git"
test -d ~/lib/dulwich || git clone "git://github.com/jelmer/dulwich.git" "$HOME/lib/dulwich"

ensure_link "lib/dulwich/dulwich" "lib/hg/hg/dulwich"

test -d ~/lib/dotfiles || hg clone http://bitbucket.org/sjl/dotfiles ~/lib/dotfiles

ensure_link "lib/dotfiles/tmux/tmux.conf"      ".tmux.conf"
ensure_link "lib/dotfiles/vim"                 ".vim"
ensure_link "lib/dotfiles/vim/vimrc"           ".vimrc"
ensure_link "lib/dotfiles/gitconfig"           ".gitconfig"
ensure_link "lib/dotfiles/ackrc"               ".ackrc"
ensure_link "lib/dotfiles/weechat"             ".weechat"
ensure_link "lib/dotfiles/urlview"             ".urlview"
ensure_link "lib/dotfiles/pentadactylrc"       ".pentadactylrc"
ensure_link "lib/dotfiles/offlineimaprc"       ".offlineimaprc"
ensure_link "lib/dotfiles/mutt"                ".mutt"
ensure_link "lib/dotfiles/dotjs"               ".js"
ensure_link "lib/dotfiles/dotcss"              ".css"
ensure_link "lib/dotfiles/hgignore"            ".hgignore"
ensure_link "lib/dotfiles/ffignore"            ".ffignore"
ensure_link "lib/dotfiles/ctags"               ".ctags"
ensure_link "lib/dotfiles/grc"                 ".grc"
ensure_link "lib/dotfiles/mutt/notmuch-config" ".notmuch-config"
ensure_link "lib/dotfiles/bash_profile"        ".bash_profile"
ensure_link "lib/dotfiles/inputrc"             ".inputrc"
ensure_link "lib/dotfiles/fish/config.fish"    ".config/fish/config.fish"

echo completed
