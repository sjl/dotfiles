" .vimrc
" Author: Steve Losh <steve@stevelosh.com>
" Source: http://bitbucket.org/sjl/dotfiles/src/tip/vim/
"
" This file changes a lot.  I'll try to document pieces of it whenever I have
" a few minutes to kill.

" Preamble -------------------------------------------------------------------- {{{

filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on
set nocompatible

" }}}
" Basic options --------------------------------------------------------------- {{{

set encoding=utf-8
set modelines=0
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
set nonumber
set norelativenumber
set laststatus=2
set history=1000
set undofile
set undoreload=10000
set cpoptions+=J
set list
set listchars=tab:▸\ ,eol:¬
set shell=/bin/bash
set lazyredraw
set wildignore+=*.pyc,.hg,.git
set matchtime=3
set showbreak=↪
set splitbelow
set splitright
set fillchars=diff:\ 
set ttimeout
set notimeout
set nottimeout

" Make Vim able to edit crontab files again.
set backupskip=/tmp/*,/private/tmp/*" 

" Save when losing focus
au FocusLost * :wa

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" Tabs, spaces, wrapping {{{

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set wrap
set textwidth=85
set formatoptions=qrn1
set colorcolumn=+1

" }}}
" Status line {{{

set statusline=%F%m%r%h%w
set statusline+=\ %#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%=(%{&ff}/%Y)
set statusline+=\ (line\ %l\/%L,\ col\ %c)

" }}}
" Backups {{{

set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
set backup                        " enable backups

" }}}
" Leader {{{

let mapleader = ","
let maplocalleader = "\\"

" }}}
" Color scheme {{{

syntax on
set background=dark
colorscheme molokai

" }}}

" }}}
" Useful abbreviations -------------------------------------------------------- {{{

iabbrev ldis ಠ_ಠ
iabbrev sl/ http://stevelosh.com/
iabbrev bb/ http://bitbucket.org/
iabbrev bbs/ http://bitbucket.org/sjl/
iabbrev gh/ http://github.com/
iabbrev ghs/ http://github.com/sjl/
iabbrev sl@ steve@stevelosh.com

" }}}
" Searching and movement ------------------------------------------------------ {{{

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

set ignorecase
set smartcase

set incsearch
set showmatch
set hlsearch

set gdefault

set virtualedit+=block

map <leader><space> :noh<cr>

runtime macros/matchit.vim
map <tab> %

nnoremap Y y$
nnoremap D d$

" Keep search matches in the middle of the window.
nnoremap * *zzzv
nnoremap # #zzzv
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz

" L is easier to type, and I never use the default behavior.
noremap L $

" Heresy
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A

" Open a Quickfix window for the last search
nnoremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

" Fix linewise visual selection of various text objects
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV

" Error navigation {{{
"
"             Location List     QuickFix Window
"            (e.g. Syntastic)     (e.g. Ack)
"            ----------------------------------
" Next      |     M-k               M-Down     |
" Previous  |     M-l                M-Up      |
"            ----------------------------------
"
nnoremap ˚ :lnext<cr>zvzz
nnoremap ¬ :lprevious<cr>zvzz
inoremap ˚ <esc>:lnext<cr>zvzz
inoremap ¬ <esc>:lprevious<cr>zvzz
nnoremap <m-Down> :cnext<cr>zvzz
nnoremap <m-Up> :cprevious<cr>zvzz
" }}}

" Directional Keys {{{

" It's 2011.
noremap j gj
noremap k gk

" Easy buffer navigation
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l
noremap <leader>g <C-w>v

" }}}

" }}}
" Folding --------------------------------------------------------------------- {{{

set foldlevelstart=0

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

" Make zO recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zO zCzO

function! MyFoldText() " {{{
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction " }}}
set foldtext=MyFoldText()

" }}}
" Destroy infuriating keys ---------------------------------------------------- {{{

" Fuck you, help key.
set fuoptions=maxvert,maxhorz
noremap <F1> :set invfullscreen<CR>
inoremap <F1> <ESC>:set invfullscreen<CR>a

" Fuck you too, manual key.
nnoremap K <nop>

" Stop it, hash key.
inoremap # X<BS>#

" }}}
" Various filetype-specific stuff --------------------------------------------- {{{

" C {{{

au FileType c setlocal foldmethod=syntax

" }}}
" Clojure {{{

au FileType clojure call TurnOnClojureFolding()
au FileType clojure compiler clojure
au FileType clojure setlocal report=100000

let g:slimv_leader = '\'
let g:slimv_keybindings = 2

" Fix the eval mapping.
au FileType clojure nmap <buffer> \ee \ed

" Indent top-level form.
au FileType clojure nmap <buffer> <localleader>= v((((((((((((=%

" Use a swank command that works, and doesn't require new app windows.
au FileType clojure let g:slimv_swank_cmd='!dtach -n /tmp/dvtm-swank.sock -r winch lein swank'

" }}}
" Confluence {{{

au BufRead,BufNewFile *.confluencewiki setlocal filetype=confluencewiki

" Wiki pages should be soft-wrapped.
au FileType confluencewiki setlocal wrap linebreak nolist

" }}}
" Cram {{{

au BufNewFile,BufRead *.t set filetype=cram

let cram_fold=1
autocmd Syntax cram setlocal foldlevel=1

" }}}
" CSS and LessCSS {{{

au BufNewFile,BufRead *.less setlocal filetype=less

au BufNewFile,BufRead *.css  setlocal foldmethod=marker
au BufNewFile,BufRead *.less setlocal foldmethod=marker

au BufNewFile,BufRead *.css  setlocal foldmarker={,}
au BufNewFile,BufRead *.less setlocal foldmarker={,}

" Use cc to change lines without borking the indentation.
au BufNewFile,BufRead *.css  nnoremap <buffer> cc ddko
au BufNewFile,BufRead *.less nnoremap <buffer> cc ddko

" Use <leader>S to sort properties.  Turns this:
"
"     p {
"         width: 200px;
"         height: 100px;
"         background: red;
"
"         ...
"     }
"
" into this:

"     p {
"         background: red;
"         height: 100px;
"         width: 200px;
"
"         ...
"     }
"
au BufNewFile,BufRead *.css  nnoremap <buffer> <localleader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>
au BufNewFile,BufRead *.less nnoremap <buffer> <localleader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

" Make {<cr> insert a pair of brackets in such a way that the cursor is correctly
" positioned inside of them AND the following code doesn't get unfolded.
au BufNewFile,BufRead *.css  inoremap <buffer> {<cr> {}<left><cr>.<cr><esc>kA<bs><space><space><space><space>
au BufNewFile,BufRead *.less inoremap <buffer> {<cr> {}<left><cr>.<cr><esc>kA<bs><space><space><space><space>

" }}}
" Django {{{

au BufNewFile,BufRead urls.py      setlocal nowrap
au BufNewFile,BufRead urls.py      normal! zR
au BufNewFile,BufRead dashboard.py normal! zR

au BufNewFile,BufRead admin.py     setlocal filetype=python.django
au BufNewFile,BufRead urls.py      setlocal filetype=python.django
au BufNewFile,BufRead models.py    setlocal filetype=python.django
au BufNewFile,BufRead views.py     setlocal filetype=python.django
au BufNewFile,BufRead settings.py  setlocal filetype=python.django
au BufNewFile,BufRead settings.py  setlocal foldmethod=marker
au BufNewFile,BufRead forms.py     setlocal filetype=python.django
au BufNewFile,BufRead common_settings.py  setlocal filetype=python.django
au BufNewFile,BufRead common_settings.py  setlocal foldmethod=marker

" }}}
" Firefox {{{

au BufRead,BufNewFile ~/Library/Caches/* setlocal buftype=nofile

" }}}
" Fish {{{

au BufNewFile,BufRead *.fish setlocal filetype=fish

" }}}
" HTML and HTMLDjango {{{

au BufNewFile,BufRead *.html setlocal filetype=htmldjango
au BufNewFile,BufRead *.html setlocal foldmethod=manual

" Use <localleader>f to fold the current tag.
au BufNewFile,BufRead *.html nnoremap <buffer> <localleader>f Vatzf
au BufNewFile,BufRead *.html nnoremap <buffer> VV vatV

" Use Shift-Return to turn this:
"     <tag>|</tag>
"
" into this:
"     <tag>
"         |
"     </tag>
au BufNewFile,BufRead *.html inoremap <buffer> <s-cr> <cr><esc>kA<cr>
au BufNewFile,BufRead *.html nnoremap <buffer> <s-cr> vit<esc>a<cr><esc>vito<esc>i<cr><esc>

" Django tags
au FileType jinja,htmldjango inoremap <buffer> <c-t> {%<space><space>%}<left><left><left>

" Django variables
au FileType jinja,htmldjango inoremap <buffer> <c-f> {{<space><space>}}<left><left><left>

" }}}
" Javascript {{{

au FileType javascript setlocal foldmethod=marker
au FileType javascript setlocal foldmarker={,}

" }}}
" Lisp {{{

au FileType lisp call TurnOnLispFolding()

" }}}
" Markdown {{{

au BufNewFile,BufRead *.m*down setlocal filetype=markdown

" Use <localleader>1/2/3 to add headings.
au Filetype markdown nnoremap <buffer> <localleader>1 yypVr=
au Filetype markdown nnoremap <buffer> <localleader>2 yypVr-
au Filetype markdown nnoremap <buffer> <localleader>3 I### <ESC>

" }}}
" Nginx {{{

au BufRead,BufNewFile /etc/nginx/conf/*                      set ft=nginx
au BufRead,BufNewFile /etc/nginx/sites-available/*           set ft=nginx
au BufRead,BufNewFile /usr/local/etc/nginx/sites-available/* set ft=nginx

" }}}
" Pentadactyl {{{

au BufNewFile,BufRead .pentadactylrc set filetype=pentadactyl

" }}}
" Puppet {{{

au Filetype puppet setlocal foldmethod=marker
au Filetype puppet setlocal foldmarker={,}

" }}}
" Python {{{

au Filetype python noremap  <localleader>rr :RopeRename<CR>
au Filetype python vnoremap <localleader>rm :RopeExtractMethod<CR>
au Filetype python noremap  <localleader>ri :RopeOrganizeImports<CR>
au FileType python setlocal omnifunc=pythoncomplete#Complete

" }}}
" ReStructuredText {{{

au Filetype rst nnoremap <buffer> <localleader>1 yypVr=
au Filetype rst nnoremap <buffer> <localleader>2 yypVr-
au Filetype rst nnoremap <buffer> <localleader>3 yypVr~
au Filetype rst nnoremap <buffer> <localleader>4 yypVr`

" }}}
" Ruby {{{

au Filetype ruby setlocal foldmethod=syntax

" }}}
" Vagrant {{{

au BufRead,BufNewFile Vagrantfile set ft=ruby

" }}}
" Vim {{{

au FileType vim setlocal foldmethod=marker
au FileType help setlocal textwidth=78

" }}}

" }}}
" Quick editing --------------------------------------------------------------- {{{

nnoremap <leader>ev <C-w>s<C-w>j<C-w>L:e $MYVIMRC<cr>
nnoremap <leader>es <C-w>s<C-w>j<C-w>L:e ~/.vim/snippets/<cr>
nnoremap <leader>eo <C-w>s<C-w>j<C-w>L:e ~/Dropbox/Org<cr>4j
nnoremap <leader>eh <C-w>s<C-w>j<C-w>L:e ~/.hgrc<cr>
nnoremap <leader>em <C-w>s<C-w>j<C-w>L:e ~/.mutt/muttrc<cr>
nnoremap <leader>ez <C-w>s<C-w>j<C-w>L:e ~/lib/dotfiles/zsh<cr>4j
nnoremap <leader>ek <C-w>s<C-w>j<C-w>L:e ~/lib/dotfiles/keymando/keymandorc.rb<cr>

" }}}
" Convenience mappings -------------------------------------------------------- {{{

" Clean whitespace
map <leader>W  :%s/\s\+$//<cr>:let @/=''<CR>

" Dammit, Slimv
map <leader>WW :%s/\s\+$//<cr>:let @/=''<CR>

" Change case
nnoremap <C-u> gUiw
inoremap <C-u> <esc>gUiwea

" Substitute
nnoremap <leader>s :%s//<left>

" Diffoff
nnoremap <leader>D :diffoff!<cr>

" Yankring
nnoremap <silent> <F6> :YRShow<cr>

" Formatting, TextMate-style
nnoremap <leader>q gqip

" Easier linewise reselection
nnoremap <leader>v V`]

" HTML tag closing
inoremap <C-_> <Space><BS><Esc>:call InsertCloseTag()<cr>a

" Faster Esc
inoremap jk <esc>

" Cmdheight switching
nnoremap <leader>1 :set cmdheight=1<cr>
nnoremap <leader>2 :set cmdheight=2<cr>

" Marks and Quotes
noremap ' `
noremap æ '
noremap ` <C-^>

" Calculator
inoremap <C-B> <C-O>yiW<End>=<C-R>=<C-R>0<CR>

" Better Completion
set completeopt=longest,menuone,preview
inoremap <expr> <CR>  pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <C-p> pumvisible() ? '<C-n>'  : '<C-n><C-r>=pumvisible() ? "\<lt>up>" : ""<CR>'
inoremap <expr> <C-n> pumvisible() ? '<C-n>'  : '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" Rainbows!
nmap <leader>R :RainbowParenthesesToggle<CR>

" Sudo to write
cmap w!! w !sudo tee % >/dev/null

" Tags
nnoremap <leader>T :!ctags -R -f ./tags .<cr>

" Easy filetype switching
nnoremap _md :set ft=markdown<CR>
nnoremap _hd :set ft=htmldjango<CR>
nnoremap _jt :set ft=htmljinja<CR>
nnoremap _cw :set ft=confluencewiki<CR>
nnoremap _pd :set ft=python.django<CR>
nnoremap _d  :set ft=diff<CR>

" Toggle paste
set pastetoggle=<F8>

" Replaste
nnoremap <D-p> "_ddPV`]

" }}}
" Plugin settings ------------------------------------------------------------- {{{

" Ack {{{

map <leader>a :Ack! 

" }}}
" NERD Tree {{{

noremap <F2> :NERDTreeToggle<cr>
inoremap <F2> <esc>:NERDTreeToggle<cr>
let NERDTreeIgnore=['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index', 'xapian_index', '.*.pid', 'monitor.py', '.*-fixtures-.*.json', '.*\.o$', 'db.db']
au Filetype nerdtree setlocal nolist

" }}}
" HTML5 {{{

let g:event_handler_attributes_complete = 0
let g:rdfa_attributes_complete = 0
let g:microdata_attributes_complete = 0
let g:atia_attributes_complete = 0

" }}}
" Rope {{{

let ropevim_enable_shortcuts = 0
let ropevim_guess_project = 1
let ropevim_global_prefix = '<C-c>p'

source $HOME/.vim/sadness/sadness.vim

" }}}
" Gundo {{{

nnoremap <F5> :GundoToggle<CR>
let g:gundo_debug = 1
let g:gundo_preview_bottom = 1

" }}}
" VimClojure {{{

let vimclojure#HighlightBuiltins = 1
let vimclojure#ParenRainbow = 1
let vimclojure#WantNailgun = 0

" }}}
" Syntastic {{{

let g:syntastic_enable_signs=1
let g:syntastic_disabled_filetypes = ['html']
let g:syntastic_stl_format = '[%E{Error 1/%e: line %fe}%B{, }%W{Warning 1/%w: line %fw}]'
let g:syntastic_jsl_conf = '$HOME/.vim/jsl.conf'

" }}}
" Command-T {{{

let g:CommandTMaxHeight = 20

" }}}
" LISP (built-in) {{{

let g:lisp_rainbow = 1

" }}}
" Easymotion {{{

let g:EasyMotion_do_mapping = 0

nnoremap <silent> <Leader>f      :call EasyMotionF(0, 0)<CR>
onoremap <silent> <Leader>f      :call EasyMotionF(0, 0)<CR>
vnoremap <silent> <Leader>f :<C-U>call EasyMotionF(1, 0)<CR>

nnoremap <silent> <Leader>F      :call EasyMotionF(0, 1)<CR>
onoremap <silent> <Leader>F      :call EasyMotionF(0, 1)<CR>
vnoremap <silent> <Leader>F :<C-U>call EasyMotionF(1, 1)<CR>

onoremap <silent> <Leader>t      :call EasyMotionT(0, 0)<CR>
onoremap <silent> <Leader>T      :call EasyMotionT(0, 1)<CR>

" }}}
" Sparkup {{{

let g:sparkupNextMapping = '<c-s>'

"}}}
" Autoclose {{{

nmap <Leader>x <Plug>ToggleAutoCloseMappings

" }}}
" Makegreen {{{

nnoremap \| :call MakeGreen('')<cr>

" }}}
" Pydoc {{{

au FileType python noremap <buffer> <localleader>Lw :call ShowPyDoc('<C-R><C-W>', 1)<CR>
au FileType python noremap <buffer> <localleader>LW :call ShowPyDoc('<C-R><C-A>', 1)<CR>

" }}}
" Scratch {{{

command! ScratchToggle call ScratchToggle()
function! ScratchToggle() " {{{
  if exists("w:is_scratch_window")
    unlet w:is_scratch_window
    exec "q"
  else
    exec "normal! :Sscratch\<cr>\<C-W>J:resize 13\<cr>"
    let w:is_scratch_window = 1
  endif
endfunction " }}}
nnoremap <silent> <leader><tab> :ScratchToggle<cr>

" }}}
" OrgMode {{{
let g:org_plugins = ['ShowHide', '|', 'Navigator', 'EditStructure', '|', 'Todo', 'Date', 'Misc']

let g:org_todo_keywords = ['TODO', '|', 'DONE']
let g:org_debug = 1
" }}}
" SLIMV {{{

let g:slimv_lisp = '"java -cp `lein classpath` clojure.main"'
let g:slimv_repl_split = 4
let g:slimv_repl_syntax = 1

" }}}}
" Threesome {{{

let g:threesome_initial_mode = "grid"

let g:threesome_initial_layout_grid = 1
let g:threesome_initial_layout_loupe = 0
let g:threesome_initial_layout_compare = 0
let g:threesome_initial_layout_path = 0

let g:threesome_initial_diff_grid = 1
let g:threesome_initial_diff_loupe = 0
let g:threesome_initial_diff_compare = 0
let g:threesome_initial_diff_path = 0

let g:threesome_initial_scrollbind_grid = 0
let g:threesome_initial_scrollbind_loupe = 0
let g:threesome_initial_scrollbind_compare = 0
let g:threesome_initial_scrollbind_path = 0

let g:threesome_wrap = "nowrap"

" }}}

" }}}
" Synstack -------------------------------------------------------------------- {{{

" Show the stack of syntax hilighting classes affecting whatever is under the
" cursor.
function! SynStack() " {{{
  if !exists("*synstack")
    return
  endif

  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc " }}}

nmap <M-S> :call SynStack()<CR>

" }}}
" Text objects ---------------------------------------------------------------- {{{

" Shortcut for [] {{{

onoremap id i[
onoremap ad a[
vnoremap id i[
vnoremap ad a[

" }}}
" Next/Last () {{{
vnoremap <silent> inb :<C-U>normal! f(vib<cr>
onoremap <silent> inb :<C-U>normal! f(vib<cr>
vnoremap <silent> anb :<C-U>normal! f(vab<cr>
onoremap <silent> anb :<C-U>normal! f(vab<cr>
vnoremap <silent> in( :<C-U>normal! f(vi(<cr>
onoremap <silent> in( :<C-U>normal! f(vi(<cr>
vnoremap <silent> an( :<C-U>normal! f(va(<cr>
onoremap <silent> an( :<C-U>normal! f(va(<cr>

vnoremap <silent> ilb :<C-U>normal! F)vib<cr>
onoremap <silent> ilb :<C-U>normal! F)vib<cr>
vnoremap <silent> alb :<C-U>normal! F)vab<cr>
onoremap <silent> alb :<C-U>normal! F)vab<cr>
vnoremap <silent> il( :<C-U>normal! F)vi(<cr>
onoremap <silent> il( :<C-U>normal! F)vi(<cr>
vnoremap <silent> al( :<C-U>normal! F)va(<cr>
onoremap <silent> al( :<C-U>normal! F)va(<cr>
" }}}
" Next/Last {} {{{
vnoremap <silent> inB :<C-U>normal! f{viB<cr>
onoremap <silent> inB :<C-U>normal! f{viB<cr>
vnoremap <silent> anB :<C-U>normal! f{vaB<cr>
onoremap <silent> anB :<C-U>normal! f{vaB<cr>
vnoremap <silent> in{ :<C-U>normal! f{vi{<cr>
onoremap <silent> in{ :<C-U>normal! f{vi{<cr>
vnoremap <silent> an{ :<C-U>normal! f{va{<cr>
onoremap <silent> an{ :<C-U>normal! f{va{<cr>

vnoremap <silent> ilB :<C-U>normal! F}viB<cr>
onoremap <silent> ilB :<C-U>normal! F}viB<cr>
vnoremap <silent> alB :<C-U>normal! F}vaB<cr>
onoremap <silent> alB :<C-U>normal! F}vaB<cr>
vnoremap <silent> il{ :<C-U>normal! F}vi{<cr>
onoremap <silent> il{ :<C-U>normal! F}vi{<cr>
vnoremap <silent> al{ :<C-U>normal! F}va{<cr>
onoremap <silent> al{ :<C-U>normal! F}va{<cr>
" }}}
" Next/Last [] {{{
vnoremap <silent> ind :<C-U>normal! f[vi[<cr>
onoremap <silent> ind :<C-U>normal! f[vi[<cr>
vnoremap <silent> and :<C-U>normal! f[va[<cr>
onoremap <silent> and :<C-U>normal! f[va[<cr>
vnoremap <silent> in[ :<C-U>normal! f[vi[<cr>
onoremap <silent> in[ :<C-U>normal! f[vi[<cr>
vnoremap <silent> an[ :<C-U>normal! f[va[<cr>
onoremap <silent> an[ :<C-U>normal! f[va[<cr>

vnoremap <silent> ild :<C-U>normal! F]vi[<cr>
onoremap <silent> ild :<C-U>normal! F]vi[<cr>
vnoremap <silent> ald :<C-U>normal! F]va[<cr>
onoremap <silent> ald :<C-U>normal! F]va[<cr>
vnoremap <silent> il[ :<C-U>normal! F]vi[<cr>
onoremap <silent> il[ :<C-U>normal! F]vi[<cr>
vnoremap <silent> al[ :<C-U>normal! F]va[<cr>
onoremap <silent> al[ :<C-U>normal! F]va[<cr>
" }}}
" Next/Last <> {{{
vnoremap <silent> in< :<C-U>normal! f<vi<<cr>
onoremap <silent> in< :<C-U>normal! f<vi<<cr>
vnoremap <silent> an< :<C-U>normal! f<va<<cr>
onoremap <silent> an< :<C-U>normal! f<va<<cr>

vnoremap <silent> il< :<C-U>normal! f>vi<<cr>
onoremap <silent> il< :<C-U>normal! f>vi<<cr>
vnoremap <silent> al< :<C-U>normal! f>va<<cr>
onoremap <silent> al< :<C-U>normal! f>va<<cr>
" }}}
" Next '' {{{
vnoremap <silent> in' :<C-U>normal! f'vi'<cr>
onoremap <silent> in' :<C-U>normal! f'vi'<cr>
vnoremap <silent> an' :<C-U>normal! f'va'<cr>
onoremap <silent> an' :<C-U>normal! f'va'<cr>

vnoremap <silent> il' :<C-U>normal! F'vi'<cr>
onoremap <silent> il' :<C-U>normal! F'vi'<cr>
vnoremap <silent> al' :<C-U>normal! F'va'<cr>
onoremap <silent> al' :<C-U>normal! F'va'<cr>
" }}}
" Next "" {{{
vnoremap <silent> in" :<C-U>normal! f"vi"<cr>
onoremap <silent> in" :<C-U>normal! f"vi"<cr>
vnoremap <silent> an" :<C-U>normal! f"va"<cr>
onoremap <silent> an" :<C-U>normal! f"va"<cr>

vnoremap <silent> il" :<C-U>normal! F"vi"<cr>
onoremap <silent> il" :<C-U>normal! F"vi"<cr>
vnoremap <silent> al" :<C-U>normal! F"va"<cr>
onoremap <silent> al" :<C-U>normal! F"va"<cr>
" }}}

" }}}
" Quickreturn ----------------------------------------------------------------- {{{

inoremap <c-cr> <esc>A<cr>
inoremap <s-cr> <esc>A:<cr>

" }}}
" Error toggles --------------------------------------------------------------- {{{

command! ErrorsToggle call ErrorsToggle()
function! ErrorsToggle() " {{{
  if exists("w:is_error_window")
    unlet w:is_error_window
    exec "q"
  else
    exec "Errors"
    lopen
    let w:is_error_window = 1
  endif
endfunction " }}}

command! -bang -nargs=? QFixToggle call QFixToggle(<bang>0)
function! QFixToggle(forced) " {{{
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction " }}}

nmap <silent> <f3> :ErrorsToggle<cr>
nmap <silent> <f4> :QFixToggle<cr>

" }}}
" Persistent echo ------------------------------------------------------------- {{{

" http://vim.wikia.com/wiki/Make_echo_seen_when_it_would_otherwise_disappear_and_go_unseen
"
" further improvement in restoration of the &updatetime. To make this
" usable in the plugins, we want it to be safe for the case when
" two plugins use same this same technique. Two independent
" restorations of &ut can run in unpredictable sequence. In order to
" make it safe, we add additional check in &ut restoration.
let s:Pecho=''
fu! s:Pecho(msg)
  let s:hold_ut=&ut | if &ut>1|let &ut=1|en
  let s:Pecho=a:msg
  aug Pecho
    au CursorHold * if s:Pecho!=''|echo s:Pecho
          \|let s:Pecho=''|if s:hold_ut > &ut |let &ut=s:hold_ut|en|en
          \|aug Pecho|exe 'au!'|aug END|aug! Pecho
  aug END
endf

" }}}
" Hg Diff --------------------------------------------------------------------- {{{

function! s:HgDiff()
    diffthis
    let fn = expand('%:p')
    let ft = &ft
    wincmd v
    edit __hgdiff_orig__
    setlocal buftype=nofile
    normal ggdG
    execute "silent r!hg cat --rev . " . fn
    normal ggdd
    execute "setlocal ft=" . ft
    diffthis
    diffupdate
endf
command! -nargs=0 HgDiff call s:HgDiff()
nnoremap <leader>hd :HgDiff<cr>

" }}}
" Open quoted ----------------------------------------------------------------- {{{

nnoremap <silent> ø :OpenQuoted<cr>
command! OpenQuoted call OpenQuoted()

" Open the file in the current (or next) set of quotes.
function! OpenQuoted() " {{{
    let @r = ''

    exe 'normal! vi' . "'" . '"ry'

    if len(@r) == 0
        exe 'normal! i' . '"' . '"ry'
    endif

    if len(@r) == 0
        exe 'normal! "ry'
        let @r = ''
    endif

    exe "silent !open ." . @r
endfunction " }}}

" }}}
" MacVim ---------------------------------------------------------------------- {{{

if has('gui_running')
    set guifont=Menlo:h12

    " Remove all the UI cruft
    set go-=T
    set go-=l
    set go-=L
    set go-=r
    set go-=R

    " PeepOpen
    if has("gui_macvim")
        macmenu &File.New\ Tab key=<nop>
        map <leader><leader> <Plug>PeepOpen
    end

    highlight SpellBad term=underline gui=undercurl guisp=Orange

    " Use a line-drawing char for pretty vertical splits.
    set fillchars+=vert:│

    " Different cursors for different modes.
    set guicursor=n-c:block-Cursor-blinkon0
    set guicursor+=v:block-vCursor-blinkon0
    set guicursor+=i-ci:ver20-iCursor

    " Use the normal HIG movements, except for M-Up/Down
    let macvim_skip_cmd_opt_movement = 1
    no   <D-Left>       <Home>
    no!  <D-Left>       <Home>
    no   <M-Left>       <C-Left>
    no!  <M-Left>       <C-Left>

    no   <D-Right>      <End>
    no!  <D-Right>      <End>
    no   <M-Right>      <C-Right>
    no!  <M-Right>      <C-Right>

    no   <D-Up>         <C-Home>
    ino  <D-Up>         <C-Home>
    imap <M-Up>         <C-o>{

    no   <D-Down>       <C-End>
    ino  <D-Down>       <C-End>
    imap <M-Down>       <C-o>}

    imap <M-BS>         <C-w>
    inoremap <D-BS>     <esc>my0c`y
endif

" }}}
