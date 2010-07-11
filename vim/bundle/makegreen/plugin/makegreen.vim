" plugin/makegreen.vim
" Author:   Rein Henrichs <reinh@reinh.com>
" License:  MIT License

" Install this file as plugin/makegreen.vim.

" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if &cp || exists("g:makegreen_loaded") && g:makegreen_loaded
  finish
endif
let g:makegreen_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function s:RunMake() "{{{1
  silent! w
  let s:old_sp = &shellpipe
  "set shellpipe=> "quieter make output
  silent! make %
  let &shellpipe = s:old_sp

  redraw!

  let error = s:GetFirstError()
  if error != ''
    call s:Bar("red", error)
  else
    call s:Bar("green","All tests passed")
  endif
endfunction
"}}}1
" Utility Functions" {{{1
function s:GetFirstError()
  if getqflist() == []
    return ''
  endif

  for error in getqflist()
    if error['valid']
      break
    endif
  endfor
  let error_message = substitute(error['text'], '^ *', '', 'g')
  let error_message = substitute(error_message, "\n", ' ', 'g')
  let error_message = substitute(error_message, "  *", ' ', 'g')
  return error_message
endfunction

function s:Bar(type, msg)
  hi GreenBar term=reverse ctermfg=black ctermbg=green guifg=white guibg=green
  hi RedBar   term=reverse ctermfg=white ctermbg=red guifg=white guibg=red
  if a:type == "red"
    echohl RedBar
  else
    echohl GreenBar
  endif
  echon a:msg repeat(" ", &columns - strlen(a:msg))
  echohl None
endfunction

" }}}1
" Mappings" {{{1

noremap <unique> <script> <Plug>MakeGreen <SID>Make
noremap <SID>Make :call <SID>RunMake()<CR>

if !hasmapto('<Plug>MakeGreen')
  map <unique> <silent> <Leader>t <Plug>MakeGreen
endif
" }}}1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set sw=2 sts=2:
