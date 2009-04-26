alias ls='ls -Goh '
alias less='less -R '
alias webf-mysql-tunnel='ssh -NL 3306:sjl.webfactional.com:3306 webf'
alias hl='less -R'
alias pm='python manage.py '
alias tunnel_webf_mysql='ssh -NL 3306/web45.webfaction.com/3306 webf'

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="/usr/local/bin:${PATH}:/opt/local/bin"
export WORKON_HOME="${HOME}/lib/virtualenvs"

# Extra shell extensions like j and tab completion for Mercurial -------------
source ~/lib/j/j.sh
source ~/lib/hg/hg-tab-completion
source ~/lib/virtualenvwrapper_bashrc

# Prompt stuff ---------------------------------------------------------------

hg_dirty() {
    hg status --no-color 2> /dev/null \
    | awk '$1 == "?" { print "?" } $1 != "?" { print "!" }' \
    | sort | uniq | head -c1
}

hg_in_repo() {
    [[ `hg branch 2> /dev/null` ]] && echo 'on '
}

hg_branch() {
    hg branch 2> /dev/null
}

COLOR_DEFAULT="[37;40m"
COLOR_PINK="[35;40m"
COLOR_GREEN="[32;40m"
COLOR_ORANGE="[33;40m"

export PS1='\n\[\e${COLOR_PINK}\]\u \
\[\e${COLOR_DEFAULT}\]at \[\e${COLOR_ORANGE}\]\h \
\[\e${COLOR_DEFAULT}\]in \[\e${COLOR_GREEN}\]\w \
\[\e${COLOR_DEFAULT}\]$(hg_in_repo)\
\[\e${COLOR_PINK}\]$(hg_branch)\[\e${COLOR_GREEN}\]$(hg_dirty) \
\[\e${COLOR_DEFAULT}\]\n$ '

