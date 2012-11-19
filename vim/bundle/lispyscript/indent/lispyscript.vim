" For now we'll just use normal Lisp indenting because it's 1 AM and I want to
" go to bed.
"
" TODO: Steal VimClojure's magic indenting.

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal expandtab nosmartindent

setlocal softtabstop=2
setlocal shiftwidth=2

setlocal indentkeys=!,o,O

setlocal autoindent
setlocal indentexpr=
setlocal lisp

" Special words go here.
setlocal lispwords=function,macro,do,->,var
setlocal lispwords+=if,cond,when,unless
setlocal lispwords+=try
setlocal lispwords+=loop,each,each2d,eachKey,reduce,map,for

" Custom:
setlocal lispwords+=defn

let &cpo = s:save_cpo

