" Rebind keys in this file in the middle of nowhere because Tim Pope doesn't
" like letting me do it in my vimrc like every other plugin in the world.

" K is for "Kill", M is for "Man"
autocmd FileType clojure nunmap <buffer> K
autocmd FileType clojure nmap   <buffer> M <Plug>FireplaceK

" Soft and hard require can take "r" in localleaderland
autocmd FileType clojure nunmap <buffer> cpr
autocmd FileType clojure nmap   <buffer> <localleader>r :Require<cr>
autocmd FileType clojure nmap   <buffer> <localleader>R :Require!<cr>

" Okay enough with the goddamn eval mappings
autocmd FileType clojure nunmap <buffer> cp
autocmd FileType clojure nunmap <buffer> cpp
autocmd FileType clojure nunmap <buffer> cq
autocmd FileType clojure nunmap <buffer> cqq
autocmd FileType clojure nunmap <buffer> cqp
autocmd FileType clojure nunmap <buffer> cqc
autocmd FileType clojure nunmap <buffer> c!
autocmd FileType clojure nunmap <buffer> c!!

" Eval form
autocmd FileType clojure nmap   <buffer> <localleader>ef <Plug>FireplacePrintab

" Eval top-level form
autocmd FileType clojure nmap   <buffer> <localleader>ee mz:call PareditFindDefunBck()<cr><Plug>FireplacePrintab:normal! `z<cr>

" QuasiREPL
autocmd FileType clojure execute 'nmap <buffer> <localleader>q <Plug>FireplacePrompt' . &cedit . 'i'

" Again!
autocmd FileType clojure execute 'nmap <buffer> <localleader>a <Plug>FireplacePrompt' . &cedit . 'k<cr>'

" Edit form in quasirepl
autocmd FileType clojure nmap   <buffer> <localleader>Ef <Plug>FireplaceEditab

" Kill all the movement mappings except gf (I like that one)
autocmd FileType clojure nunmap <buffer> [<c-d>
autocmd FileType clojure nunmap <buffer> ]<c-d>
autocmd FileType clojure nunmap <buffer> <c-w><c-d>
autocmd FileType clojure nunmap <buffer> <c-w>d
autocmd FileType clojure nunmap <buffer> <c-w>gd

" Use normal tag movement keys instead, ctags is fucked for Clojure anyway
autocmd FileType clojure nmap   <buffer> <c-]> <Plug>FireplaceDjump
autocmd FileType clojure nmap   <buffer> <c-\> :vsplit<cr><Plug>FireplaceDjump

