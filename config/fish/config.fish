set tacklebox_path ~/lib/tacklebox
set tacklebox_theme prose
set tacklebox_plugins directories python django misc web osx

. $tacklebox_path/tacklebox.fish

# Useful aliases -------------------------------------------------------------
alias j       'z'
alias fab     'fab -i ~/.ssh/stevelosh'
alias oldgcc  'set -g CC /usr/bin/gcc-4.0'
alias tm      'tmux -u2'
alias c       'clear'
alias M       'mvim .'

# Environment variables ------------------------------------------------------
set PATH "$HOME/.gem/ruby/1.8/bin:$PATH"
set PATH "/usr/local/bin:/usr/local/sbin:$HOME/bin:/opt/local/bin:$PATH"
set PATH "/opt/subversion/bin:$PATH"
set -g -x EDITOR vim
set -g -x COMMAND_MODE unix2003
set -g -x RUBYOPT rubygems
set -g -x CLASSPATH "$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar"

# Python variables -----------------------------------------------------------
set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
set -g -x PYTHONSTARTUP "$HOME/.pythonrc.py"
set -g -x WORKON_HOME "$HOME/lib/virtualenvs"

set PATH "$PATH:/usr/local/Cellar/PyPi/3.6/bin"
set PATH "$PATH:/usr/local/Cellar/python/2.7.1/bin"
set PATH "$PATH:/usr/local/Cellar/python/2.7/bin"
set PATH "$PATH:/usr/local/Cellar/python/2.6.5/bin"

set -g -x PYTHONPATH ""
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.6/site-packages"
set PYTHONPATH "$HOME/lib/python/see:$PYTHONPATH"

# Mercurial variables --------------------------------------------------------
set PATH "$HOME/lib/hg/hg-stable:$PATH"
set PYTHONPATH "$HOME/lib/hg/hg-stable:$PYTHONPATH"

# Extra ----------------------------------------------------------------------
. ~/src/z-fish/z.fish

# Local Settings -------------------------------------------------------------
if test -s $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

function z_add --on-event prompt
    z --add "$PWD"
end

# hgd (for now) --------------------------------------------------------------

function h
    /Users/sjl/src/hgd/hd $argv
end
