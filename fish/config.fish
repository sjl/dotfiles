# Useful aliases {{{

alias serve_this 'python -m SimpleHTTPServer'
# alias fab 'fab -i ~/.ssh/stevelosh'
alias oldgcc 'set -g CC /usr/bin/gcc-4.0'
alias tm 'tmux -u2'
alias c 'clear'
alias hl 'less -R'
alias paththis 'set PATH (pwd) $PATH'
alias clc './get-last-commit-url.py | pbcopy'
alias t '~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt'

alias swank 'dtach -A /tmp/dtach-swank.sock -r winch lein swank'

alias ef 'vim ~/.config/fish/config.fish'
alias ev 'vim ~/.vimrc'
alias ed 'vim ~/.vim/custom-dictionary.utf-8.add'
alias eo 'vim ~/Dropbox/Org'
alias eh 'vim ~/.hgrc'
alias ep 'vim ~/.pentadactylrc'
alias em 'vim ~/.mutt/muttrc'
alias ez 'vim ~/lib/dotfiles/zsh'
alias ek 'vim ~/lib/dotfiles/keymando/keymandorc.rb'
alias et 'vim ~/.tmux.conf'
alias eg 'vim ~/.gitconfig'


alias spotlight-off 'sudo mdutil -a -i off ; and sudo mv /System/Library/CoreServices/Search.bundle/ /System/Library/CoreServices/SearchOff.bundle/ ; and killall SystemUIServer'
alias spotlight-on 'sudo mdutil -a -i on ; and sudo mv /System/Library/CoreServices/SearchOff.bundle/ /System/Library/CoreServices/Search.bundle/ ; and killall SystemUIServer'
alias spotlight-wat 'sudo fs_usage -w -f filesys mdworker | grep "open"'

set MUTT_BIN (which mutt)
alias mutt "bash -c 'cd ~/Desktop; $MUTT_BIN'"

alias h 'hg'
alias g 'git'

alias pbc 'pbcopy'
alias pbp 'pbpaste'
alias pbpb 'pbp | pb'

alias weechat 'weechat-curses'

alias collapse="sed -e 's/  */ /g'"
alias cuts "cut -d' '"

alias pbc 'pbcopy'
alias pbp 'pbpaste'

alias v 'vim'
alias V 'vim .'

alias vu 'vagrant up'
alias vs 'vagrant suspend'

alias o 'open'
alias oo 'open .'

alias wo 'workon'
alias deact 'deactivate'

function psg -d "Grep for a running process, returning its PID and full string"
    ps auxww | grep --color=always $argv | grep -v grep | collapse | cuts -f 2,11-
end

function hey_virtualbox_shut_down_or_i_will_fucking_cut_you
    VBoxManage controlvm $argv poweroff
end

function a -d "Run Ag with appropriate options."
    if test -f '.agignorevcs'
        ag -U $argv
    else
        ag $argv
    end
end

# }}}
# Bind Keys {{{

function fish_user_keybindings
    bind \cn accept-autosuggestion

    # Ignore iterm2 escape sequences.  Vim will handle them if needed.
    bind \e\[I true
    bind \e\[O true
    # ]]
end

# }}}
# Environment variables {{{

set PATH "/usr/local/bin"          $PATH
set PATH "/usr/local/share/python" $PATH
set PATH "/usr/local/sbin"         $PATH
set PATH "$HOME/bin"               $PATH
set PATH "$HOME/lib/dotfiles/bin"  $PATH
set PATH "/opt/local/bin"          $PATH
set PATH "/opt/subversion/bin"     $PATH
set PATH "$HOME/lib/hg/hg"         $PATH

set PATH "$HOME/Library/Haskell/bin" $PATH

set PATH "/usr/local/Cellar/ruby/1.9.3-p194/bin" $PATH

set PATH "/usr/local/Cellar/ruby/1.9.3-p125/bin" $PATH

set BROWSER open

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x COMMAND_MODE unix2003
set -g -x RUBYOPT rubygems
set -g -x CLASSPATH "$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar"

set -g -x NODE_PATH "/usr/local/lib/node_modules"

# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
set -g -x PYTHONSTARTUP "$HOME/.pythonrc.py"
set -g -x WORKON_HOME "$HOME/lib/virtualenvs"

set PATH $PATH "/usr/local/share/python"
set PATH $PATH "/usr/local/Cellar/PyPi/3.6/bin"
set PATH $PATH "/usr/local/Cellar/python/2.7.1/bin"
set PATH $PATH "/usr/local/Cellar/python/2.7/bin"
set PATH $PATH "/usr/local/Cellar/python/2.6.5/bin"

set -g -x PYTHONPATH ""
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.6/site-packages"
set PYTHONPATH "$HOME/lib/python/see:$PYTHONPATH"
set PYTHONPATH "$HOME/lib/hg/hg:$PYTHONPATH"

set -gx WORKON_HOME "$HOME/lib/virtualenvs"
. ~/.config/fish/virtualenv.fish

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

function virtualenv_prompt
    if [ -n "$VIRTUAL_ENV" ]
        printf '(%s) ' (basename "$VIRTUAL_ENV")
    end
end

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

    virtualenv_prompt

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
alias l4 'tree --dirsfirst -ChFL 4'
alias l5 'tree --dirsfirst -ChFL 5'
alias l6 'tree --dirsfirst -ChFL 6'

alias ll1 'tree --dirsfirst -ChFupDaL 1'
alias ll2 'tree --dirsfirst -ChFupDaL 2'
alias ll3 'tree --dirsfirst -ChFupDaL 3'
alias ll4 'tree --dirsfirst -ChFupDaL 4'
alias ll5 'tree --dirsfirst -ChFupDaL 5'
alias ll6 'tree --dirsfirst -ChFupDaL 6'

alias l  'l1'
alias ll 'll1'

# }}}
# Misc {{{

# }}}
# Local Settings {{{

if test -s $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

# }}}

if status --is-interactive
    command fortune -s | cowsay -n | lolcat
end
