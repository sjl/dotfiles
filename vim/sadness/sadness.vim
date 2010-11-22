let $rope_pypath = $HOME."/.vim/sadness/ropevim/pylibs"
let $bike_pypath = $HOME."/.vim/sadness/bike"

let $PYTHONPATH = $rope_pypath.":".$bike_pypath.":".$PYTHONPATH
source $HOME/.vim/sadness/ropevim/src/ropevim/ropevim.vim

source $HOME/.vim/sadness/bike/ide-integration/bike.vim
