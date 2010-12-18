export ZSH=$HOME/lib/oh-my-zsh
export ZSH_THEME="prose"
export DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

# Custom options -------------------------------------------------------------
unsetopt promptcr

# Useful aliases -------------------------------------------------------------
alias j='z'
alias fab='fab -i ~/.ssh/stevelosh'
alias oldgcc='export CC=/usr/bin/gcc-4.0'
alias tm='tmux -u2'
alias c='clear'

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="$HOME/.gem/ruby/1.8/bin:${PATH}"
export PATH="/usr/local/bin:/usr/local/sbin:$HOME/lib/fmscripts:$HOME/bin:$PATH"
export PATH="/opt/subversion/bin:${PATH}"
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export COMMAND_MODE=unix2003
export R_LIBS="$HOME/lib/r"
export BAT_CHARGE="$HOME/bin/batcharge.py"
export RUBYOPT=rubygems
export CLASSPATH=$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar

# Python variables -----------------------------------------------------------
export PIP_DOWNLOAD_CACHE="$HOME/.pip/cache"
export PYTHONSTARTUP="$HOME/.pythonrc.py"
export WORKON_HOME="${HOME}/lib/virtualenvs"
export PATH="${PATH}:/usr/local/Cellar/PyPi/3.6/bin"
export PATH="${PATH}:/usr/local/Cellar/python/2.7.1/bin"
export PATH="${PATH}:/usr/local/Cellar/python/2.7/bin"
export PATH="${PATH}:/usr/local/Cellar/python/2.6.5/bin"
export PATH="${PATH}:/usr/local/Cellar/python/2.6.4/bin"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.6/site-packages"

# Mercurial variables --------------------------------------------------------
export PATH="$HOME/lib/hg/hg-stable:$PATH"
export PYTHONPATH="$HOME/lib/hg/hg-stable:$PYTHONPATH"

# Extra shell extensions like z and tab completion for Mercurial -------------
source ~/lib/z/z.sh
export VEW_PATH="$HOME/lib/python/virtualenvwrapper/virtualenvwrapper.sh"
if [[ -s $HOME/.screeninator/scripts/screeninator ]] ; then source $HOME/.screeninator/scripts/screeninator ; fi

# See ------------------------------------------------------------------------
export PYTHONPATH="$HOME/lib/python/see:$PYTHONPATH"

# Pre-Prompt Command ---------------------------------------------------------
function precmd () {
    z --add "$(pwd -P)"
}

# BCVI -----------------------------------------------------------------------
test -n "$(which bcvi)" && eval "$(bcvi --unpack-term)"
test -n "${BCVI_CONF}"  && alias vi="bcvi"
test -n "${BCVI_CONF}"  && alias suvi="EDITOR='bcvi -c viwait' sudoedit"
test -n "${BCVI_CONF}"  && alias bcp="bcvi -c scpd"

# MacPorts
export PATH="$PATH:/opt/local/bin"

# Local Settings -------------------------------------------------------------
if [[ -s $HOME/.zshrc_local ]] ; then source $HOME/.zshrc_local ; fi
