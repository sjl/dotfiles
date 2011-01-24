" Vim indent file
" Language:     htmldjango
" Maintainer:   Steve Losh <steve@stevelosh.com>
"
" Mostly based on indent/eruby.vim
"
" To use: save as ~/.vim/indent/htmldjango.vim

if exists("b:did_indent")
    finish
endif

runtime! indent/html.vim
unlet! b:did_indent

if &l:indentexpr == ''
    if &l:cindent
        let &l:indentexpr = 'cindent(v:lnum)'
    else
        let &l:indentexpr = 'indent(prevnonblank(v:lnum-1))'
    endif
endif
let b:html_indentexpr = &l:indentexpr

let b:did_indent = 1

setlocal indentexpr=GetDjangoIndent()
setlocal indentkeys=o,O,*<Return>,{,},o,O,!^F,<>>

" Only define the function once.
if exists("*GetDjangoIndent")
    finish
endif

function! GetDjangoIndent(...)
    if a:0 && a:1 == '.'
        let v:lnum = line('.')
    elseif a:0 && a:1 =~ '^\d'
        let v:lnum = a:1
    endif
    let vcol = col('.')

    call cursor(v:lnum,vcol)

    exe "let ind = ".b:html_indentexpr

    let lnum = prevnonblank(v:lnum-1)
    let prev_non_blank_line = getline(lnum)
    let current_line = getline(v:lnum)

    let tagstart = '^\s*' . '{%\s*'
    let tagend = '.*%}' . '\s*$'

    let blocktags = '\(block\|for\|if\|with\|autoescape\|comment\|filter\|spaceless\)'
    let midtags = '\(empty\|else\)'

    if prev_non_blank_line =~# tagstart . blocktags . tagend
        let ind = ind + &sw
    elseif prev_non_blank_line =~# tagstart . midtags . tagend
        let ind = ind + &sw
    endif

    if current_line =~# tagstart . 'end' . blocktags . '.*$'
        let ind = ind - &sw
    elseif current_line =~# tagstart . midtags . tagend
        let ind = ind - &sw
    endif

    return ind
endfunction

