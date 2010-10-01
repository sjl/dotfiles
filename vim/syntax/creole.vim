" Vim syntax file
" Language:     creole
" Maintainer:   Peter Hoffmann <ph@peter-hoffmann.com>
" Last Change:  2007 May 31

" This syntax file is based on the wiki.vim syntax file from Andreas Kneib

" Little syntax file to use a wiki-editor with VIM
" (if your browser allow this action) 
" To use this syntax file:
" 1. mkdir ~/.vim/syntax
" 2. mv ~/creole.vim ~/.vim/syntax/creole.vim
" 3. :set syntax=creole
"

"Some hints to extend wiki creole editing
"set path=.,~/wiki/
"au BufRead,BufNewFile *.txt setfiletype creole

"write current file and open file under cursor in new tab
"nnoremap gF :w<cr> :tabedit <cfile><cr>

"use the snippetsEmu plugin for wiki code
"Snippet { {{{<CR><{}><CR>}}}<CR><{}>
"Snippet * **<{}>** <{}> 
"Snippet _ __<{}>__ <{}> 
"Snippet - --<{}>-- <{}> 
"Snippet [ [[<{}>]] <{}> 


" Quit if syntax file is already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if version < 508
  command! -nargs=+ WikiHiLink hi link <args>
else
  command! -nargs=+ WikiHiLink hi def link <args>
endif

syn match   wikiLine        "^----$"
"TODO add different markup for [[link|name]] type of links
syn region  wikiLink        start=+\[\[+hs=s+2 end=+\]\]+he=e-2
syn match   wikiList        "^[*#]* "
syn region  wikiCurly       start="{\{3\}" end="}\{3\}"
syn region  wikiHead        start="^=" end="$"
"syn region  wikiSubhead     start="^== " end="$"
"TODO add syntax for tables

"try to not get confused with wikiLink
syn region  wikiBold        start="\*\*[^ ]" end="\*\*"
"try to not get confused with http://
"FIXME does not work at beginning of line
syn region  wikiItalic      start="[^:]\/\/"hs=s+1   end="[^:]\/\/"
syn region  wikiUnderline   start="__" end="__"
"syn region  wikiStrike      start="--" end="--"
"TODO add regions for mixed markup
"syn region wikiBoldItalic   contained start=+\([^']\|^\)''[^']+ end=+[^']''\([^']\|$\)+
"syn region wikiItalicBold   contained start=+'''+ end=+'''+

" The default highlighting.
if version >= 508 || !exists("did_wiki_syn_inits")
  if version < 508
    let did_wiki_syn_inits = 1
  endif
  
WikiHiLink wikiCurly       Type
WikiHiLink wikiHead        Statement 
"  WikiHiLink wikiSubhead     PreProc
WikiHiLink wikiList        String
WikiHiLink wikiExtLink     Identifier
WikiHiLink wikiLink        Identifier
WikiHiLink wikiLine        PreProc

hi def     wikiBold        term=bold cterm=bold gui=bold
 " hi def     wikiBoldItalic  term=bold,italic cterm=bold,italic gui=bold,italic
hi def     wikiItalic      term=italic cterm=italic gui=italic
 " hi def     wikiItalicBold  term=bold,italic cterm=bold,italic gui=bold,italic
hi def  wikiUnderline   term=underline cterm=underline gui=underline
"hi def wikiStrike ???

endif

delcommand WikiHiLink
  
let b:current_syntax = "creole"

"EOF vim: tw=78:ft=vim:ts=8

