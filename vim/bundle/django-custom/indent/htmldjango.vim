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
    let pnb = getline(lnum)
    let cur = getline(v:lnum)

    let tagstart = '.*' . '{%\s*'
    let tagend = '.*%}' . '.*'

    let blocktags = '\(block\|for\|if\|with\|autoescape\|comment\|filter\|spaceless\)'
    let midtags = '\(empty\|else\)'

    let pnb_blockstart = pnb =~# tagstart . blocktags . tagend
    let pnb_blockend   = pnb =~# tagstart . 'end' . blocktags . tagend
    let pnb_blockmid   = pnb =~# tagstart . midtags . tagend

    let cur_blockstart = cur =~# tagstart . blocktags . tagend
    let cur_blockend   = cur =~# tagstart . 'end' . blocktags . tagend
    let cur_blockmid   = cur =~# tagstart . midtags . tagend

    if pnb_blockstart && !pnb_blockend
        let ind = ind + &sw
    elseif pnb_blockmid && !pnb_blockend
        let ind = ind + &sw
    endif

    if cur_blockend && !cur_blockstart
        let ind = ind - &sw
    elseif cur_blockmid
        let ind = ind - &sw
    endif

    return ind
endfunction

