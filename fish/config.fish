# Useful aliases {{{

alias fab     'fab -i ~/.ssh/stevelosh'
alias oldgcc  'set -g CC /usr/bin/gcc-4.0'
alias tm      'tmux -u2'
alias c       'clear'
alias ef      'vim ~/.config/fish/config.fish'

alias h 'hg'
alias g 'git'

alias v 'vagrant'
alias vu 'vagrant up'
alias vs 'vagrant suspend'

# }}}
# Environment variables {{{

set PATH "/usr/local/bin"         $PATH
set PATH "/usr/local/sbin"        $PATH
set PATH "$HOME/bin"              $PATH
set PATH "$HOME/lib/dotfiles/bin" $PATH
set PATH "/opt/local/bin"         $PATH
set PATH "/opt/subversion/bin"    $PATH
set PATH "$HOME/lib/hg/hg-stable" $PATH

set BROWSER open

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x COMMAND_MODE unix2003
set -g -x RUBYOPT rubygems
set -g -x CLASSPATH "$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar"

# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
set -g -x PYTHONSTARTUP "$HOME/.pythonrc.py"
set -g -x WORKON_HOME "$HOME/lib/virtualenvs"

set PATH $PATH "/usr/local/Cellar/PyPi/3.6/bin"
set PATH $PATH "/usr/local/Cellar/python/2.7.1/bin"
set PATH $PATH "/usr/local/Cellar/python/2.7/bin"
set PATH $PATH "/usr/local/Cellar/python/2.6.5/bin"

set -g -x PYTHONPATH ""
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.6/site-packages"
set PYTHONPATH "$HOME/lib/python/see:$PYTHONPATH"
set PYTHONPATH "$HOME/lib/hg/hg-stable:$PYTHONPATH"

# }}}
# Z {{{

. ~/src/z-fish/z.fish

alias j 'z'

# }}}
# Prompt {{{

set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set gray (set_color -o black)
set hg_promptstring "< on $magenta<branch>$normal>< at $yellow<tags|$normal, $yellow>$normal>$green<status|modified|unknown><update>$normal<
patches: <patches|join( → )|pre_applied($yellow)|post_applied($normal)|pre_unapplied($gray)|post_unapplied($normal)>>" 2>/dev/null

function hg_prompt
    # hg prompt --angle-brackets $hg_promptstring 2>/dev/null
end

function git_prompt
    if git root >/dev/null 2>&1
        set_color normal
        printf ' on '
        set_color magenta
        printf '%s' (git currentbranch ^/dev/null)
        set_color green
        git_prompt_status
        set_color normal
    end
end

function fish_prompt
    set last_status $status

    z --add "$PWD"

    echo

    set_color magenta
    printf '%s' (whoami)
    set_color normal
    printf ' at '

    set_color yellow
    printf '%s' (hostname|cut -d . -f 1)
    set_color normal
    printf ' in '

    set_color $fish_color_cwd
    printf '%s' (prompt_pwd)
    set_color normal

    hg_prompt
    git_prompt

    echo

    if test $last_status -eq 0
        set_color white -o
        printf '><((°> '
    else
        set_color red -o
        printf '[%d] ><((ˣ> ' $last_status
    end

    set_color normal
end

# }}}
# Directories {{{

alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'

alias md 'mkdir -p'

alias l1 'tree --dirsfirst -ChFL 1'
alias l2 'tree --dirsfirst -ChFL 2'
alias l3 'tree --dirsfirst -ChFL 3'

alias ll1 'tree --dirsfirst -ChFupDaL 1'
alias ll2 'tree --dirsfirst -ChFupDaL 2'
alias ll3 'tree --dirsfirst -ChFupDaL 3'

alias l  'l1'
alias ll 'll1'

# }}}
# Local Settings {{{

if test -s $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

#normal }}}

if status --is-interactive
    command fortune -s | cowsay -n | lolcat
end
