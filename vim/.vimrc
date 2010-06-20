filetype off
filetype plugin indent on

set nocompatible

" Tabs/spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Basic options
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
set ttyfast
set ruler
set backspace=indent,eol,start
set nu
set laststatus=2

" Backups
set backupdir=~/tmp,/tmp " backups (~)
set directory=~/tmp,/tmp " swap files
set backup               " enable backups

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
set gdefault
map <leader><space> :let @/=''<CR>

" Soft/hard wrapping
set wrap
set textwidth=79
set formatoptions=qrn1

" Use the same symbols as TextMate for tabstops and EOLs
set list
set listchars=tab:▸\ ,eol:¬

" Color scheme (terminal)
syntax on
set background=dark
colorscheme delek

" Use Pathogen to load bundles
call pathogen#runtime_append_all_bundles()
cab HALP call pathogen#helptags()<CR>

" NERD Tree
map <F2> :NERDTreeToggle<CR>
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$']

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
map <leader>w <C-w>v<C-w>l

" Folding
set foldlevelstart=1
nnoremap <F1> za
vnoremap <F1> za
au BufNewFile,BufRead *.html map <leader>ft Vatzf

set foldtext=MyFoldText()
function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 1
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction

" Fuck you, help key.
imap <F1> <nop>

" Various syntax stuff
au BufNewFile,BufRead *.less set filetype=less
au BufNewFile,BufRead *.markdown set filetype=markdown

" Sort CSS
map <leader>S ?{<CR>jV/^\s*\}\=$<CR>k:sort<CR>:let @/=''<CR>

" Clean whitespace
map <leader>W :%s/\s\+$//<CR>:let @/=''<CR>

" Exuberant ctags!
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"
let Tlist_WinWidth = 50
map <F4> :TlistToggle<cr>
map <F5> :!/usr/local/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --exclude='@.ctagsignore' .<CR>

" Ropevim
let $PYTHONPATH .= ":" . $HOME . "/lib/python/rope"
let $PYTHONPATH .= ":" . $HOME . "/lib/dotfiles/vim/notreallybundles/ropevim/ropevim"
source ~/lib/dotfiles/vim/notreallybundles/ropevim/ropevim.vim

" Ack
map <leader>a :Ack 

" Yankring
nnoremap <silent> <F3> :YRShow<CR>

" Formatting, TextMate-style
map <leader>q gqip

" TODO: Put this in filetype-specific files
map <leader>n :!nosetests<CR>
map <leader>N :!nosetests "%:p"<CR>
au BufNewFile,BufRead *.less set foldmethod=marker
au BufNewFile,BufRead *.less set foldmarker={,}
au BufNewFile,BufRead *.less set nocursorline
au BufNewFile,BufRead *.less map <leader>p o<ESC>pV`]>

" Easier linewise reselection
map <leader>v V`]

" HTML tag closing
imap <C-_> <Space><BS><Esc>:call InsertCloseTag()<CR>a
