filetype off
filetype plugin indent on

set nocompatible

" Tabs/spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab


set autoindent
set smartindent

" Soft/hard wrapping
set wrap
set textwidth=79
set formatoptions=qrn1

set ruler
set incsearch
set showmatch
set backspace=indent,eol,start

" Use the same symbols as TextMate for tabstops and EOLs
set list
set listchars=tab:▸\ ,eol:¬

" Line numbers
set nu

" Highlight search results
set hls

" Color scheme (terminal)
syntax on
set background=dark
colorscheme delek

" Use Pathogen to load bundles
call pathogen#runtime_append_all_bundles()

map <F2> :NERDTreeToggle<CR>

" Use the damn hjkl keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Minibufexplorer
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplModSelTarget = 1

" Use F1 to fold/unfold
nnoremap <F1> za
vnoremap <F1> za
