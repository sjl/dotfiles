set tacklebox_path ~/lib/tacklebox
set tacklebox_theme prose
set tacklebox_plugins directories python django misc web osx
set tacklebox_short true

. $tacklebox_path/tacklebox.fish

# Useful aliases -------------------------------------------------------------
alias j       'z'
alias fab     'fab -i ~/.ssh/stevelosh'
alias oldgcc  'set -g CC /usr/bin/gcc-4.0'
alias tm      'tmux -u2'
alias c       'clear'

# Environment variables ------------------------------------------------------
set -g EDITOR vim
set -g PATH "$HOME/.gem/ruby/1.8/bin:$PATH"
set -g PATH "/usr/local/bin:/usr/local/sbin:$HOME/bin:/opt/local/bin:$PATH"
set -g PATH "/opt/subversion/bin:$PATH"
set -g COMMAND_MODE unix2003
set -g RUBYOPT rubygems
set -g CLASSPATH "$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar"

# Python variables -----------------------------------------------------------
set -g PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
set -g PYTHONSTARTUP "$HOME/.pythonrc.py"
set -g WORKON_HOME "$HOME/lib/virtualenvs"

set -g PATH "$PATH:/usr/local/Cellar/PyPi/3.6/bin"
set -g PATH "$PATH:/usr/local/Cellar/python/2.7.1/bin"
set -g PATH "$PATH:/usr/local/Cellar/python/2.7/bin"
set -g PATH "$PATH:/usr/local/Cellar/python/2.6.5/bin"

set -g PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
set -g PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
set -g PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.6/site-packages"
set -g PYTHONPATH "$HOME/lib/python/see:$PYTHONPATH"

# Mercurial variables --------------------------------------------------------
set -g PATH="$HOME/lib/hg/hg-stable:$PATH"
set -g PYTHONPATH="$HOME/lib/hg/hg-stable:$PYTHONPATH"

# Extra ----------------------------------------------------------------------
. ~/src/z-fish/z.sh

# Local Settings -------------------------------------------------------------
if test -s $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

function z_add --on-event prompt
    z --add "$PWD"
end
