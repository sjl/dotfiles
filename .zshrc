export ZSH=$HOME/lib/oh-my-zsh
export ZSH_THEME="prose"
export DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

# Custom options -------------------------------------------------------------
unsetopt promptcr

# Useful aliases -------------------------------------------------------------
alias ls='ls -Goh'
alias less='less -R'
alias hl='less -R'
alias pm='python manage.py'
alias oo='open .'
alias j='z'
alias flakes="find . -name '*.py' -print0 | xargs -0 pyflakes"
alias fab='fab -i ~/.ssh/stevelosh'
alias tweets-stevelosh='~/src/grabtweets/grabtweets.py -p ~/Documents/tweets/stevelosh'
alias meme="curl -q --silent meme.boxofjunk.ws/moar.txt?lines=1"
alias deact='deactivate'
alias serve_this='python -m SimpleHTTPServer'
alias oldgcc='export CC=/usr/bin/gcc-4.0'
alias smtpconsole='python -m smtpd -n -c DebuggingServer localhost:1025'

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="/usr/local/bin:/usr/local/sbin:$HOME/lib/fmscripts:$HOME/bin:$PATH"
export PATH="$HOME/.gem/ruby/1.8/bin:${PATH}"
export PATH="/opt/subversion/bin:${PATH}"
export WORKON_HOME="${HOME}/lib/virtualenvs"
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export JPY="${HOME}/lib/j2/j.py"
export PYTHONSTARTUP="$HOME/.pythonrc.py"
export COMMAND_MODE=unix2003
export R_LIBS="$HOME/lib/r"
export BAT_CHARGE="$HOME/bin/batcharge.py"

# Mercurial variables --------------------------------------------------------
export PATH="$HOME/lib/hg/hg-stable:$PATH"
export PYTHONPATH="$HOME/lib/hg/hg-stable:$PYTHONPATH"

# Extra shell extensions like z and tab completion for Mercurial -------------
source ~/lib/z/z.sh
source ~/lib/python/virtualenvwrapper/virtualenvwrapper_bashrc

# Gorilla --------------------------------------------------------------------
export PATH="/Users/sjl/src/gorilla/bin:$PATH"
export PYTHONPATH="/Users/sjl/src/gorilla/lib:$PYTHONPATH"

# Pre-Prompt Command ---------------------------------------------------------
function precmd () {
    z --add "$(pwd -P)"
    title zsh "$(pwd)"
}
