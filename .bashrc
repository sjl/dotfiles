alias ls='ls -Goh '
alias less='less -R '
alias hl='less -R'
alias pm='python manage.py '
alias tunnel_webf_mysql='ssh -NL 3306/web45.webfaction.com/3306 webf'
alias mq='hg -R $(hg root)/.hg/patches'
alias oo='open .'
alias flakes="find . -name '*.py' -print0 | xargs -0 pyflakes"
alias fab='fab -i ~/.ssh/stevelosh'

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set visible-stats on'

shopt -s cdspell

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="/usr/local/bin:~/lib/fmscripts:${PATH}"
export WORKON_HOME="${HOME}/lib/virtualenvs"
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export JPY="${HOME}/lib/j2/j.py"
export PYTHONSTARTUP="$HOME/.pythonrc.py"
export COMMAND_MODE=unix2003
export R_LIBS="$HOME/lib/r"

# Extra shell extensions like j and tab completion for Mercurial -------------
source ~/lib/j2/j.sh
source ~/lib/hg/bash_completion
source ~/lib/virtualenvwrapper_bashrc

# Task stuff -----------------------------------------------------------------
alias t='~/src/t/t.py --task-dir="~/tasks"'
alias m='~/src/t/t.py --task-dir="~/tasks" --list=music'
alias g='~/src/t/t.py --task-dir="~/tasks" --list=groceries'
alias k='~/src/t/t.py --task-dir="~/tasks" --list=books'
alias p='~/src/t/t.py --task-dir="~/tasks" --list=pack'
alias b='~/src/t/t.py --list=bugs'

alias pa='~/src/t/t.py --task-dir="~/tasks" --list=pack-archive'
packfor() {
    cp "$HOME/tasks/pack-archive" "$HOME/tasks/pack";
    touch "$HOME/tasks/.pack.done"
    hg -R ~/tasks add 'pack' '.pack.done';
    hg com -m 'Starting to pack.'
}

# Useful functions -----------------------------------------------------------

pull_everything() {
    for repo in $( ls -1 ); do
        if [[ -d $repo && -d $repo/.hg ]]; then
            echo "Pulling" $repo
            hg -R $repo pull -u
            echo
        fi
    done
}

wo() {
    [ -f './.venv' ] && workon `cat ./.venv`
}

# Prompt stuff ---------------------------------------------------------------

D=$'\[\e[37;40m\]'
PINK=$'\[\e[35;40m\]'
GREEN=$'\[\e[32;40m\]'
ORANGE=$'\[\e[33;40m\]'

hg_ps1() {
  hg prompt "\
{${D} on ${PINK}{branch}}\
{${D} at ${ORANGE}{tags|${D}, ${ORANGE}}}\
{${GREEN}{status}}{${GREEN}{update}}" 2> /dev/null
}

tasks_ps1() {
    t | wc -l | sed -e's/ *//'
}

render_ps1() {
  echo "\n\
${PINK}\u ${D}at ${ORANGE}\h ${D}in ${GREEN}\w$(hg_ps1)${D}\n\
[$(tasks_ps1)] $([ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') ' )$ "
}

PROMPT_COMMAND="$(echo "$PROMPT_COMMAND"|sed -e's/PS1="`render_ps1`";//g')"
PROMPT_COMMAND='PS1="`render_ps1`";'"$PROMPT_COMMAND"
