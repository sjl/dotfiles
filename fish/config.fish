# Useful functions {{{

function serve_this; python -m SimpleHTTPServer; end
function fabric; fab -i ~/.ssh/stevelosh $argv; end
function oldgcc; set -g CC /usr/bin/gcc-4.0 $argv; end
function tm; tmux -u2 $argv; end
function c; clear; end
function hl; less -R; end
function paththis; set PATH (pwd) $PATH $argv; end
function clc; ./bin/get-last-commit-url.py | pbcopy; end

function swank; dtach -A /tmp/dtach-swank.sock -r winch lein ritz; end

function ef; vim ~/.config/fish/config.fish; end
function ev; vim ~/.vimrc; end
function ed; vim ~/.vim/custom-dictionary.utf-8.add; end
function eo; vim ~/Dropbox/Org; end
function eh; vim ~/.hgrc; end
function ep; vim ~/.pentadactylrc; end
function em; vim ~/.mutt/muttrc; end
function ez; vim ~/lib/dotfiles/zsh; end
function ek; vim ~/lib/dotfiles/keymando/keymandorc.rb; end
function et; vim ~/.tmux.conf; end
function eg; vim ~/.gitconfig; end
function es; vim ~/.slate; end

function vup
    set -x VAGRANT_LOG debug
    vagrant up $argv
    set -e VAGRANT_LOG
end

function fixopenwith
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
end

function ss; bcvi --wrap-ssh -- $argv; end
function bcvid; dtach -A /tmp/bcvi.socket bcvi --listener; end

function spotlight-off; sudo mdutil -a -i off ; and sudo mv /System/Library/CoreServices/Search.bundle/ /System/Library/CoreServices/SearchOff.bundle/ ; and killall SystemUIServer; end
function spotlight-on; sudo mdutil -a -i on ; and sudo mv /System/Library/CoreServices/SearchOff.bundle/ /System/Library/CoreServices/Search.bundle/ ; and killall SystemUIServer; end
function spotlight-wat; sudo fs_usage -w -f filesys mdworker | grep "open" ; end

set MUTT_BIN (which mutt)
function mutt; bash --login -c "cd ~/Desktop; $MUTT_BIN"; end

function h; hg $argv; end
function g; git $argv; end

function pbc; pbcopy; end
function pbp; pbpaste; end
function pbpb; pbp | pb; end

function weechat; weechat-curses $argv; end

function collapse; sed -e 's/  */ /g'; end
function cuts; cut -d' ' $argv; end

function emptytrash -d "Empty the OS X trash folders"
    sudo rm -rfv /Volumes/*/.Trashes
    sudo rm -rfv ~/.Trash
    sudo rm -rfv /private/var/log/asl/*.asl
end

function urlencode
    python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);" $argv
end

function fix_open_with -d "Fix the shitty OS X Open With menu duplicates"
    /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user
    killall Finder
    echo "Open With has been rebuilt, Finder will relaunch"
end

function v; vim $argv; end
function V; vim . $argv; end

function vu; vagrant up; end
function vs; vagrant suspend; end

function o; open $argv; end
function oo; open .; end

function wo; workon $argv; end
function deact; deactivate; end

function psg -d "Grep for a running process, returning its PID and full string"
    ps auxww | grep -i --color=always $argv | grep -v grep | collapse | cuts -f 2,11-
end

function hey_virtualbox_shut_down_or_i_will_fucking_cut_you
    VBoxManage controlvm $argv poweroff
end

set AG_BIN (which ag)
function actual_ag
    # Fuck you fish this is fucking ridiculous.  Let me use $AG_BIN as
    # a command.  Or at least give me a way to do it like run $AG_BIN args or
    # something jesus.
    if test $AG_BIN = '/usr/local/bin/ag'
        /usr/local/bin/ag $argv
    else
        if test $AG_BIN = '/usr/bin/ag'
            /usr/bin/ag $argv
        else
            echo "Fish is a dick, sorry."
        end
    end
end
function ag -d "Run Ag with appropriate options."
    if test -f '.agignore'
        # Extra if statement because I can't figure out how to && things in
        # a fish conditional and the documentation does not see fit to explain
        # that little tidbit and can we please get a shell without complete
        # bullshit as a scripting language syntax?
        if grep -q 'pragma: skipvcs' '.agignore'
            actual_ag --search-files -U $argv
        else
            actual_ag --search-files $argv
        end
    else
        actual_ag --search-files $argv
    end
end

function count_t_tasks; ~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt | wc -l $argv; end
# set -g T_TASK_COUNT (count_t_tasks)
function t
    ~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=tasks.txt $argv
    set -g T_TASK_COUNT (count_t_tasks)
end

function packfor
    cp ~/Dropbox/tasks/pack-archive ~/Dropbox/tasks/pack.txt
end
function p
    ~/lib/t/t.py --task-dir="~/Dropbox/tasks" --list=pack.txt $argv
end

# }}}
# Bind Keys {{{

# Backwards compatibility?  Screw that, it's more important that our function
# names have underscores so they look pretty.
function jesus_fucking_christ_bind_the_fucking_keys_fish
    bind \cn accept-autosuggestion
end
function fish_user_keybindings
    jesus_fucking_christ_bind_the_fucking_keys_fish
end
function fish_user_key_bindings
    jesus_fucking_christ_bind_the_fucking_keys_fish
end

# }}}
# Environment variables {{{

function prepend_to_path -d "Prepend the given dir to PATH if it exists and is not already in it"
    if test -d $argv[1]
        if not contains $argv[1] $PATH
            set -gx PATH "$argv[1]" $PATH
        end
    end
end
set -gx PATH "/usr/X11R6/bin"
prepend_to_path "/usr/texbin"
prepend_to_path "/sbin"
prepend_to_path "/usr/sbin"
prepend_to_path "/bin"
prepend_to_path "/usr/bin"
prepend_to_path "/usr/local/bin"
prepend_to_path "/usr/local/share/python"
prepend_to_path "/usr/local/sbin"
prepend_to_path "$HOME/bin"
prepend_to_path "$HOME/lib/dotfiles/bin"
prepend_to_path "/opt/local/bin"
prepend_to_path "/opt/subversion/bin"
prepend_to_path "$HOME/lib/hg/hg"
prepend_to_path "$HOME/Library/Haskell/bin"
prepend_to_path "/usr/local/Cellar/ruby/1.9.3-p194/bin"
prepend_to_path "/Applications/Postgres.app/Contents/MacOS/bin"

set BROWSER open

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x COMMAND_MODE unix2003
set -g -x RUBYOPT rubygems
set -g -x CLASSPATH "$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar"

set -g -x NODE_PATH "/usr/local/lib/node_modules"

set -g -x VIM_BINARY "/usr/local/bin/vim"
set -g -x MVIM_BINARY "/usr/local/bin/mvim"

# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
set -g -x WORKON_HOME "$HOME/lib/virtualenvs"

prepend_to_path "/usr/local/share/python"
prepend_to_path "/usr/local/Cellar/PyPi/3.6/bin"
prepend_to_path "/usr/local/Cellar/python/2.7.1/bin"
prepend_to_path "/usr/local/Cellar/python/2.7/bin"
prepend_to_path "/usr/local/Cellar/python/2.6.5/bin"

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

function j; z $argv; end

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
    hg prompt --angle-brackets $hg_promptstring 2>/dev/null
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

function prompt_pwd --description 'Print the current working directory, shortend to fit the prompt'
    echo $PWD | sed -e "s|^$HOME|~|"
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

function ..;    cd ..; end
function ...;   cd ../..; end
function ....;  cd ../../..; end
function .....; cd ../../../..; end

function md; mkdir -p $argv; end

function l1; tree --dirsfirst -ChFL 1 $argv; end
function l2; tree --dirsfirst -ChFL 2 $argv; end
function l3; tree --dirsfirst -ChFL 3 $argv; end
function l4; tree --dirsfirst -ChFL 4 $argv; end
function l5; tree --dirsfirst -ChFL 5 $argv; end
function l6; tree --dirsfirst -ChFL 6 $argv; end

function ll1; tree --dirsfirst -ChFupDaL 1 $argv; end
function ll2; tree --dirsfirst -ChFupDaL 2 $argv; end
function ll3; tree --dirsfirst -ChFupDaL 3 $argv; end
function ll4; tree --dirsfirst -ChFupDaL 4 $argv; end
function ll5; tree --dirsfirst -ChFupDaL 5 $argv; end
function ll6; tree --dirsfirst -ChFupDaL 6 $argv; end

function l;  l1 $argv; end
function ll; ll1 $argv; end

# }}}
# Misc {{{

# }}}
# Local Settings {{{

if test -s $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

# }}}

true
