alias ls='ls -Goh '
alias less='less -R '
alias hl='less -R'
alias pm='python manage.py '
alias tunnel_webf_mysql='ssh -NL 3306/web45.webfaction.com/3306 webf'
alias mq='hg -R $(hg root)/.hg/patches'

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set visible-stats on'

shopt -s cdspell

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="/usr/local/bin:${PATH}:/opt/local/bin"
export WORKON_HOME="${HOME}/lib/virtualenvs"
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export JPY="${HOME}/lib/j2/j.py"

# Extra shell extensions like j and tab completion for Mercurial -------------
source ~/lib/j2/j.sh
source ~/lib/hg/bash_completion
source ~/lib/virtualenvwrapper_bashrc

# Useful functions -----------------------------------------------------------

pull_everything() {
    for repo in $( ls -1 ); do
        [ -d $repo ] && [ -d $repo/.hg ] && hg -R $repo pull -u
        echo
    done
}

wo() {
    [ -f './.venv' ] && workon `cat ./.venv`
}

# Prompt stuff ---------------------------------------------------------------

D=$'\e[37;40m'
PINK=$'\e[35;40m'
GREEN=$'\e[32;40m'
ORANGE=$'\e[33;40m'

hg_ps1() {
    hg prompt "{${D} on ${PINK}{branch}}{${D} at ${ORANGE}{bookmark}}{${GREEN}{status}}{${GREEN}{update}}" 2> /dev/null
}

export PS1='\n${PINK}\u ${D}at ${ORANGE}\h ${D}in ${GREEN}\w$(hg_ps1)\
${D}\n$ '
