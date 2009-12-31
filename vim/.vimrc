set nocompatible
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set wrap
set lbr

set showmatch
set ruler
set incsearch
set backspace=indent,eol,start
set nu
set hls

syntax on
set background=dark

runtime! autoload/pathogen.vim
if exists('g:loaded_pathogen')
  call pathogen#runtime_prepend_subdirectories(expand('~/.vimbundles'))
end

colorscheme molokai
