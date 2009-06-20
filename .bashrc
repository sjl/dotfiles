alias ls='ls -Goh '
alias less='less -R '
alias hl='less -R'
alias pm='python manage.py '
alias tunnel_webf_mysql='ssh -NL 3306/web45.webfaction.com/3306 webf'

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="/usr/local/bin:${PATH}:/opt/local/bin"
export WORKON_HOME="${HOME}/lib/virtualenvs"

# Extra shell extensions like j and tab completion for Mercurial -------------
source ~/lib/j/j.sh
source ~/lib/hg/bash_completion
source ~/lib/virtualenvwrapper_bashrc

# Prompt stuff ---------------------------------------------------------------

D=$'\e[37;40m'
PINK=$'\e[35;40m'
GREEN=$'\e[32;40m'
ORANGE=$'\e[33;40m'

hg_ps1() {
    hg prompt "{${D} on ${PINK}{branch}}{${D} at ${ORANGE}{bookmark}}{${GREEN}{status}}" 2> /dev/null
}

export PS1='\n${PINK}\u ${D}at ${ORANGE}\h ${D}in ${GREEN}\w$(hg_ps1)\
${D}\n$ '