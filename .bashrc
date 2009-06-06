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

DEFAULT="[37;40m"
PINK="[35;40m"
GREEN="[32;40m"
ORANGE="[33;40m"

hg_dirty() {
    hg status --no-color 2> /dev/null \
    | awk '$1 == "?" { unknown = 1 } 
           $1 != "?" { changed = 1 }
           END {
             if (changed) printf "!"
             else if (unknown) printf "?" 
           }'
}

hg_branch() {
    hg branch 2> /dev/null | \
        awk '{ printf "\033[37;0m on \033[35;40m" $1 }'
    hg bookmarks 2> /dev/null | \
        awk '/\*/ { printf "\033[37;0m at \033[33;40m" $2 }'
}

export PS1='\n\e${PINK}\u \
\e${DEFAULT}at \e${ORANGE}\h \
\e${DEFAULT}in \e${GREEN}\w\
$(hg_branch)\e${GREEN}$(hg_dirty)\
\e${DEFAULT}\n$ '

