#!/bin/bash

# THIS IS A WORK IN PROGRESS
# BE CAREFUL, DAMMIT

# Don't forget the SSH keys.

mkdir -p lib/hg
mkdir -p lib/python
mkdir -p lib/virtualenvs
mkdir bin
mkdir src

echo '#!/usr/bin/env python' > bin/batcharge.py
echo 'pass' >> bin/batcharge.py
chmod u+x bin/batcharge.py

wget 'http://mercurial.selenic.com/release/mercurial-1.5.tar.gz'
tar xzf mercurial-1.5.tar.gz
cd mercurial-1.5
make local

./hg clone 'http://selenic.com/repo/hg#stable' ~/lib/hg/hg-stable
cd ~/lib/hg/hg-stable
make local
cd
export PATH="$PATH:$HOME/lib/hg/hg-stable"
rm -rf mercurial-1.5 mercurial-1.5.tar.gz

hg clone http://bitbucket.org/sjl/dotfiles ~/lib/dotfiles
git clone git://github.com/sjl/oh-my-zsh ~/lib/oh-my-zsh
git clone git://github.com/sjl/z-zsh ~/lib/z

hg clone http://bitbucket.org/dhellmann/virtualenvwrapper ~/lib/python/virtualenvwrapper
cd ~/lib/python/virtualenvwrapper
sudo python setup.py develop
cd

hg clone http://bitbucket.org/agr/rope ~/lib/python/rope
cd ~/lib/python/rope
sudo python setup.py develop
cd

rm -rf ~lib/oh-my-zsh/custom
ln -s "$HOME/lib/dotfiles/zsh $HOME/lib/oh-my-zsh/custom"

ln -s "$HOME/lib/dotfiles/.ackrc $HOME/.ackrc"
ln -s "$HOME/lib/dotfiles/.gitconfig $HOME/.gitconfig"
ln -s "$HOME/lib/dotfiles/.hgrc $HOME/.hgrc"
ln -s "$HOME/lib/dotfiles/vim/.vim $HOME/.vim"
ln -s "$HOME/lib/dotfiles/vim/.vimrc $HOME/.vimrc"

rm ~/.zshrc
ln -s "$HOME/lib/dotfiles/.zshrc $HOME/.zshrc"

hg clone bb://sjl/hg-prompt/ "$HOME/lib/hg/hg-prompt"
hg clone bb://sjl/hg-paste/ "$HOME/lib/hg/hg-paste"
hg clone bb://sjl/hg-review/ "$HOME/lib/hg/hg-review"
hg clone bb://ccaughie/hgcollapse/ "$HOME/lib/hg/hgcollapse"
hg clone bb://tksoh/hgshelve/ "$HOME/lib/hg/hgshelve"
hg clone bb://durin42/histedit/ "$HOME/lib/hg/histedit"
hg clone bb://durin42/hg-git/ "$HOME/lib/hg/hg-git"

git clone git://github.com/jelmer/dulwich.git "$HOME/lib/dulwich"
ln -s "$HOME/lib/dulwich/dulwich $HOME/lib/hg/hg-stable/dulwich"
