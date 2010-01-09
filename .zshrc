export ZSH=$HOME/lib/oh-my-zsh
export ZSH_THEME="prose"
export DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

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

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="/usr/local/bin:~/lib/fmscripts:~/bin:${PATH}"
export WORKON_HOME="${HOME}/lib/virtualenvs"
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export JPY="${HOME}/lib/j2/j.py"
export PYTHONSTARTUP="$HOME/.pythonrc.py"
export COMMAND_MODE=unix2003
export R_LIBS="$HOME/lib/r"

# Extra shell extensions like z and tab completion for Mercurial -------------
source ~/lib/z/z.sh
source ~/lib/python/virtualenvwrapper/virtualenvwrapper_bashrc

# Useful functions -----------------------------------------------------------

function wo() {
    [ -f './.venv' ] && workon `cat ./.venv`
}

# Gorilla --------------------------------------------------------------------

export PATH="/Users/sjl/src/gorilla/bin:$PATH"
export PYTHONPATH="/Users/sjl/src/gorilla/lib:$PYTHONPATH"
