let $rope_pypath = $HOME."/.vim/sadness/ropevim/pylibs"

let $PYTHONPATH = $rope_pypath.":".$PYTHONPATH
source $HOME/.vim/sadness/ropevim/src/ropevim/ropevim.vim
