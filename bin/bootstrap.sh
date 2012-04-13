#!/bin/bash

# THIS IS A WORK IN PROGRESS
# BE CAREFUL, DAMMIT

# Don't forget the SSH keys.
# Setuptools needs to be installed.

mkdir -p lib/hg
mkdir -p lib/python
mkdir -p lib/virtualenvs
mkdir -p ~/bin
mkdir -p ~/src

hg clone 'http://selenic.com/repo/hg#stable' ~/lib/hg/hg-stable
cd ~/lib/hg/hg-stable
make local
cd
export PATH="$HOME/lib/hg/hg-stable:$PATH"

hg clone http://bitbucket.org/sjl/dotfiles ~/lib/dotfiles
git clone git://github.com/sjl/oh-my-zsh ~/lib/oh-my-zsh
git clone git://github.com/sjl/z-zsh ~/lib/z

hg clone http://bitbucket.org/ianb/pip/ ~/lib/python/pip
cd ~/lib/python/pip
sudo python setup.py install
cd

sudo pip install virtualenv

hg clone http://bitbucket.org/dhellmann/virtualenvwrapper ~/lib/python/virtualenvwrapper
cd ~/lib/python/virtualenvwrapper
sudo python setup.py install
cd

ln -s "$HOME/lib/dotfiles/zsh" "$HOME/lib/oh-my-zsh/custom"

ln -s "$HOME/lib/dotfiles/.ackrc" "$HOME/.ackrc"
ln -s "$HOME/lib/dotfiles/.gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/lib/dotfiles/.hgrc" "$HOME/.hgrc"
ln -s "$HOME/lib/dotfiles/vim" "$HOME/.vim"
ln -s "$HOME/lib/dotfiles/vim/.vimrc" "$HOME/.vimrc"
ln -s "$HOME/lib/dotfiles/.screenrc" "$HOME/.screenrc"

rm ~/.zshrc
rm ~/.bashrc
rm ~/.bash_profile
ln -s "$HOME/lib/dotfiles/.zshrc" "$HOME/.zshrc"

hg clone bb://sjl/hg-prompt/ "$HOME/lib/hg/hg-prompt"
hg clone bb://sjl/hg-paste/ "$HOME/lib/hg/hg-paste"
hg clone bb://sjl/hg-review/ "$HOME/src/hg/hg-review"
hg clone bb://ccaughie/hgcollapse/ "$HOME/lib/hg/hgcollapse"
hg clone bb://durin42/histedit/ "$HOME/lib/hg/histedit"
hg clone bb://durin42/hg-git/ "$HOME/lib/hg/hg-git"
hg clone bb://Bill_Barry/hgattic "$HOME/lib/hg/hgattic"
hg clone bb://edgimar/crecord "$HOME/lib/hg/crecord"

git clone git://github.com/jelmer/dulwich.git "$HOME/lib/dulwich"
ln -s "$HOME/lib/dulwich/dulwich" "$HOME/lib/hg/hg-stable/dulwich"
