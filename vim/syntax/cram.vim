" Vim syntax file
" Language: Cram Tests
" Author: Steve Losh (steve@stevelosh.com)
"
" Add the following line to your ~/.vimrc to enable:
" au BufNewFile,BufRead *.t set filetype=cram

if exists("b:current_syntax")
  finish
endif

syn include @Shell syntax/sh.vim

syn match cramComment /^[^ ].*$/
syn region cramOutput start=/^  [^$>]/ start=/^  $/ end=/\v.(\n\n*[^ ])\@=/me=s end=/  [$>]/me=e-3 end=/^$/ fold containedin=cramBlock
syn match cramCommandStart /^  \$ / containedin=cramCommand
syn region cramCommand start=/^  \$ /hs=s+4,rs=s+4 end=/^  [^>]/me=e-3 end=/^  $/me=e-2 containedin=cramBlock contains=@Shell keepend
syn region cramBlock start=/^  /ms=e-2 end=/\v.(\n\n*[^ ])\@=/me=s end=/^$/me=e-1 fold keepend

hi link cramCommandStart Keyword
hi link cramComment Normal
hi link cramOutput Comment

set foldmethod=syntax
syn sync maxlines=200

let b:current_syntax = "cram"
