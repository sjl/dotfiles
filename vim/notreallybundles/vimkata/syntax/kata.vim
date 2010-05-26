" Kata syntax file
" Language:     VimKata
" Author:       Barry Arthur <barry.arthur@gmail.com> (based on Duane
"               Johnson's original practice.vim script).
" URL:          http://github.com/canadaduane/VimKata
" Licence:      GPL (http://www.gnu.org) + MIT (url?)
" Remarks:      Vim 6 or greater
" Limitations:  See 'Appendix E: Vim Syntax Highlighter' in the AsciiDoc 'User
"               Guide'.

if exists("b:current_syntax")
  finish
endif

syn clear
syn sync fromstart
syn sync linebreaks=1

syntax region KataPlainText start="^[a-zA-Z0-9]" end="\n"
syntax region KataAnswer start="^>" end="\n"
syntax region KataComment start="#" end="\n"

highlight link KataPlainText Function
highlight link KataAnswer Define
highlight link KataComment Comment

let b:current_syntax = "kata"

" vim: wrap et sw=2 sts=2:
