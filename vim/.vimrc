filetype off
filetype plugin indent on

set nocompatible

" Tabs/spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set scrolloff=3
set autoindent
set smartindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline

" Backups
set nobackup
set nowritebackup
set directory=$HOME/.vim/tmp//,.

" Leader
let mapleader = ","

" FuzzyFinder
map <Leader>t :FuzzyFinderTextMate<Enter>
map <Leader>b :FuzzyFinderBuffer<Enter>
let g:fuzzy_ignore = "*.pyc;log/**;.svn/**;.git/**;.hg/**;pip-log.txt;*.gif;*.jpg;*.jpeg;*.png;**media/admin/**;**media/ckeditor/**;**media/filebrowser/**;**media/pages/**;**src/**;**build/**;**_build/**;**media/cache/**"
let g:fuzzy_matching_limit = 70

" Searching
set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch
map <leader>c :let @/=''<CR>

" Soft/hard wrapping
set wrap
set textwidth=79
set formatoptions=qrn1

set ruler
set backspace=indent,eol,start

" Use the same symbols as TextMate for tabstops and EOLs
set list
set listchars=tab:▸\ ,eol:¬

" Line numbers
set nu

" Color scheme (terminal)
syntax on
set background=dark
colorscheme delek

" Use Pathogen to load bundles
call pathogen#runtime_append_all_bundles()
cmap HALP call pathogen#helptags()<CR>

map <F2> :NERDTreeToggle<CR>

" Use the damn hjkl keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Easy buffer navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

map <D-h> :vertical resize -10<CR>
map <D-j> :resize -10<CR>
map <D-k> :resize +10<CR>
map <D-l> :vertical resize +10<CR>

" Use F1 to fold/unfold
nnoremap <F1> za
vnoremap <F1> za

" Fuck you, help key.
imap <F1> <nop>

" NERDTree ignore filters
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$']

" Various syntax stuff
au BufNewFile,BufRead *.less set filetype=less
au BufNewFile,BufRead *.less set foldmethod=marker
au BufNewFile,BufRead *.less set foldmarker={,}
au BufNewFile,BufRead *.less set nocursorline
au BufNewFile,BufRead *.markdown set filetype=markdown

" Sort CSS
map <leader>S ?{<CR>jV/^\s*\}\=$<CR>k:sort<CR>:let @/=''<CR>

" Clean whitespace
map <leader>W :%s/\s\+$//<CR>:let @/=''<CR>

" Exuberant ctags!
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"
let Tlist_WinWidth = 50
map <F3> :TlistToggle<cr>
map <F4> :!/usr/local/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" Ropevim
let $PYTHONPATH .= ":" . $HOME . "/lib/python/rope"
let $PYTHONPATH .= ":" . $HOME . "/lib/dotfiles/vim/notreallybundles/ropevim/ropevim"
source ~/lib/dotfiles/vim/notreallybundles/ropevim/ropevim.vim

" Ack
map <leader>a :Ack 

" Spellbad Coloring
if has("gui_running")
    highlight SpellBad term=underline gui=undercurl guisp=Orange
endif
