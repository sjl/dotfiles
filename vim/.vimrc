filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

set nocompatible

" Security
set modelines=0

" Tabs/spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Basic options
set encoding=utf-8
set scrolloff=3
set autoindent
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
set relativenumber
set laststatus=2
set undofile
set undoreload=10000

" Status line
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)

" Backups
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
set backup                        " enable backups

" Leader
let mapleader = ","

" Make Y not dumb
nnoremap Y y$

" Searching
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch
set gdefault
map <leader><space> :noh<cr>
runtime macros/matchit.vim
nmap <tab> %
vmap <tab> %

" Soft/hard wrapping
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85

" Use the same symbols as TextMate for tabstops and EOLs
set list
set listchars=tab:▸\ ,eol:¬

" Color scheme (terminal)
syntax on
set background=dark
colorscheme delek

" NERD Tree
map <F2> :NERDTreeToggle<cr>
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$']

" Use the damn hjkl keys
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>

" And make them fucking work, too.
nnoremap j gj
nnoremap k gk

" Easy buffer navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <leader>w <C-w>v<C-w>l

" Folding
set foldlevelstart=0
nnoremap <Space> za
vnoremap <Space> za
noremap <leader>ft Vatzf

function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 4
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction
set foldtext=MyFoldText()

" Fuck you, help key.
set fuoptions=maxvert,maxhorz
inoremap <F1> <ESC>:set invfullscreen<CR>a
nnoremap <F1> :set invfullscreen<CR>
vnoremap <F1> :set invfullscreen<CR>

" Fuck you too, manual key
nnoremap K <nop>

" Various syntax stuff
au BufNewFile,BufRead *.less set filetype=less
au BufRead,BufNewFile *.scss set filetype=scss

au BufRead,BufNewFile *.confluencewiki set filetype=confluencewiki
au BufRead,BufNewFile *.confluencewiki set wrap linebreak nolist

au BufNewFile,BufRead *.m*down set filetype=markdown
au BufNewFile,BufRead *.m*down nnoremap <leader>1 yypVr=
au BufNewFile,BufRead *.m*down nnoremap <leader>2 yypVr-
au BufNewFile,BufRead *.m*down nnoremap <leader>3 I### <ESC>

au BufNewFile,BufRead *.vim set foldmethod=marker

au BufNewFile,BufRead urls.py set nowrap

" Sort CSS
map <leader>S ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

" Clean whitespace
map <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Ack
map <leader>a :Ack 

" Yankring
nnoremap <silent> <leader>y :YRShow<cr>

" Formatting, TextMate-style
map <leader>q gqip

nmap <leader>m :make<cr>

" Google's JSLint
au BufNewFile,BufRead *.js set makeprg=gjslint\ %
au BufNewFile,BufRead *.js set errorformat=%-P-----\ FILE\ \ :\ \ %f\ -----,Line\ %l\\,\ E:%n:\ %m,%-Q,%-GFound\ %s,%-GSome\ %s,%-Gfixjsstyle%s,%-Gscript\ can\ %s,%-G

" TESTING GOAT APPROVES OF THESE LINES
au BufNewFile,BufRead test_*.py set makeprg=nosetests\ --machine-out\ --nocapture
au BufNewFile,BufRead test_*.py set shellpipe=2>&1\ >/dev/null\ \|\ tee
au BufNewFile,BufRead test_*.py set errorformat=%f:%l:\ %m
au BufNewFile,BufRead test_*.py nmap <Leader>N :make<cr>
nmap <leader>fn :cn<cr>
nmap <leader>fp :cp<cr>

" TODO: Put this in filetype-specific files
au BufNewFile,BufRead *.less set foldmethod=marker
au BufNewFile,BufRead *.less set foldmarker={,}
au BufNewFile,BufRead *.less set nocursorline
au BufRead,BufNewFile /etc/nginx/conf/* set ft=nginx
au BufRead,BufNewFile /etc/nginx/sites-available/* set ft=nginx
au BufRead,BufNewFile /usr/local/etc/nginx/sites-available/* set ft=nginx
au BufNewFile,BufRead *.js set foldmethod=marker
au BufNewFile,BufRead *.js set foldmarker={,}

" Easier linewise reselection
map <leader>v V`]

" HTML tag closing
inoremap <C-_> <Space><BS><Esc>:call InsertCloseTag()<cr>a

" Faster Esc
inoremap <Esc> <nop>
inoremap jj <ESC>

" Scratch
nmap <leader><tab> :Sscratch<cr><C-W>x<C-j>:resize 15<cr>

" Make selecting inside an HTML tag less dumb
nnoremap Vit vitVkoj
nnoremap Vat vatV

" Diff
nmap <leader>d :!hg diff %<cr>

" Rainbows!
nmap <leader>R :RainbowParenthesesToggle<CR>

" Edit vim stuff.
nnoremap <leader>ev <C-w>s<C-w>j<C-w>L:e $MYVIMRC<cr>
nnoremap <leader>es <C-w>s<C-w>j<C-w>L:e ~/.vim/snippets/<cr>

" Sudo to write
cmap w!! w !sudo tee % >/dev/null

" Easy filetype switching
nnoremap _dt :set ft=htmldjango<CR>
nnoremap _jt :set ft=htmljinja<CR>
nnoremap _cw :set ft=confluencewiki<CR>
nnoremap _pd :set ft=python.django<CR>

" Python docs
nnoremap <leader>P :Pydoc<space>

" HALP
nnoremap _wtfcw :!open 'http://confluence.atlassian.com/renderer/notationhelp.action?section=all'<cr>

" VCS Stuff
let VCSCommandMapPrefix = "<leader>h"

" Disable useless HTML5 junk
let g:event_handler_attributes_complete = 0
let g:rdfa_attributes_complete = 0
let g:microdata_attributes_complete = 0
let g:atia_attributes_complete = 0

" Save when losing focus
au FocusLost * :wa

" Stop it, hash key
inoremap # X<BS>#

" Cram tests
au BufNewFile,BufRead *.t set filetype=cram
let cram_fold=1
autocmd Syntax cram setlocal foldlevel=1

" Show syntax highlighting groups for word under cursor
nmap <C-S> :call SynStack()<CR>
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Tags!
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"
let Tlist_WinWidth = 50
let Tlist_Show_One_File = 1
map <F4> :TlistToggle<cr>
map <leader>T :!/usr/local/bin/ctags --exclude='**/ckeditor' -R . $(test -f .venv && echo ~/lib/virtualenvs/`cat .venv`)<CR>

" Rope and Bike.
let g:bike_exceptions=1
source $HOME/.vim/sadness/sadness.vim

let ropevim_enable_shortcuts = 0
let ropevim_guess_project = 1
noremap <leader>rr :RopeRename<CR>
vnoremap <leader>rm :RopeExtractMethod<CR>
noremap <leader>roi :RopeOrganizeImports<CR>

" Gundo
nnoremap U :GundoToggle<CR>
let g:gundo_debug = 1
let g:gundo_preview_bottom = 1

" Shortcut for square brackets
onoremap id i[
onoremap ad a[

" Next ()
vnoremap <silent> inb :<C-U>normal! f(vib<cr>
onoremap <silent> inb :<C-U>normal! f(vib<cr>
vnoremap <silent> anb :<C-U>normal! f(vab<cr>
onoremap <silent> anb :<C-U>normal! f(vab<cr>
vnoremap <silent> in( :<C-U>normal! f(vi(<cr>
onoremap <silent> in( :<C-U>normal! f(vi(<cr>
vnoremap <silent> an( :<C-U>normal! f(va(<cr>
onoremap <silent> an( :<C-U>normal! f(va(<cr>

" Next {}
vnoremap <silent> inB :<C-U>normal! f{viB<cr>
onoremap <silent> inB :<C-U>normal! f{viB<cr>
vnoremap <silent> anB :<C-U>normal! f{vaB<cr>
onoremap <silent> anB :<C-U>normal! f{vaB<cr>
vnoremap <silent> in{ :<C-U>normal! f{vi{<cr>
onoremap <silent> in{ :<C-U>normal! f{vi{<cr>
vnoremap <silent> an{ :<C-U>normal! f{va{<cr>
onoremap <silent> an{ :<C-U>normal! f{va{<cr>

" Next []
vnoremap <silent> ind :<C-U>normal! f[vi[<cr>
onoremap <silent> ind :<C-U>normal! f[vi[<cr>
vnoremap <silent> and :<C-U>normal! f[va[<cr>
onoremap <silent> and :<C-U>normal! f[va[<cr>
vnoremap <silent> in[ :<C-U>normal! f[vi[<cr>
onoremap <silent> in[ :<C-U>normal! f[vi[<cr>
vnoremap <silent> an[ :<C-U>normal! f[va[<cr>
onoremap <silent> an[ :<C-U>normal! f[va[<cr>

" Next <>
vnoremap <silent> in< :<C-U>normal! f<vi<<cr>
onoremap <silent> in< :<C-U>normal! f<vi<<cr>
vnoremap <silent> an< :<C-U>normal! f<va<<cr>
onoremap <silent> an< :<C-U>normal! f<va<<cr>

" Next ''
vnoremap <silent> in' :<C-U>normal! f'vi'<cr>
onoremap <silent> in' :<C-U>normal! f'vi'<cr>
vnoremap <silent> an' :<C-U>normal! f'va'<cr>
onoremap <silent> an' :<C-U>normal! f'va'<cr>

" Next ""
vnoremap <silent> in" :<C-U>normal! f"vi"<cr>
onoremap <silent> in" :<C-U>normal! f"vi"<cr>
vnoremap <silent> an" :<C-U>normal! f"va"<cr>
onoremap <silent> an" :<C-U>normal! f"va"<cr>

" Skipreturn
inoremap <c-cr> <esc>A<cr>
inoremap <s-cr> <esc>A:<cr>
au BufNewFile,BufRead *.html nnoremap <s-cr> vit<esc>a<cr><esc>vito<esc>i<cr><esc>

" VimClojure
let vimclojure#HighlightBuiltins=1
let vimclojure#ParenRainbow=1

" Syntastic
let g:syntastic_enable_signs=1

nmap <silent> <f3> :ErrorsToggle<cr>
command! ErrorsToggle call ErrorsToggle()
function! ErrorsToggle()
  if exists("w:is_error_window")
    unlet w:is_error_window
    exec "q"
  else
    exec "Errors"
    lopen
    let w:is_error_window = 1
  endif
endfunction

if has('gui_running')
    set guifont=Menlo:h12
    colorscheme molokai
    set background=dark

    set go-=T
    set go-=l
    set go-=L
    set go-=r
    set go-=R

    if has("gui_macvim")
        macmenu &File.New\ Tab key=<nop>
        map <leader>t <Plug>PeepOpen
    end

    let g:sparkupExecuteMapping = '<D-e>'

    highlight SpellBad term=underline gui=undercurl guisp=Orange
else
    set nocursorline
endif
