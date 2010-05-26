" Vim filetype plugin
" Language:		VimKata
" Maintainer:		Duane Johnson

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" preserve user's options
let s:save_cpo = &cpo
set cpo&vim

setlocal commentstring=#%s foldmethod=marker
setlocal nospell nohlsearch

function! s:Renumber() range
  let b:k_count = 1
  exe a:firstline . ',' . a:lastline . "g/^(\\d\\+/s//\\='('.b:k_count/ | let b:k_count += 1"
endfunction

function! s:GroupRenumber()
  let group_boundary = '^\[.\{-}\]$'
  " Locate the boundary of the group we're in
  let firstline  = search(group_boundary,'bnW') + 1
  let lastline   = search(group_boundary, 'nW') - 1
  if lastline < 0
    let lastline = line('$')
  endif
  exe firstline . ',' . lastline 'call s:Renumber()' 
endfunction

function! s:NextQuestion()
  call search("^(\\d\\+)")
  normal j
endfunction

function! s:NextQuestionWithPrep()
  call s:NextQuestion()
  call s:ExecutePreparation()
endfunction

function! s:PrevQuestion()
  call s:ThisQuestion()
  normal k
  call s:ThisInput()
endfunction

function! s:ThisQuestion()
  call search("^(\\d\\+)", "bc")
endfunction

function! s:ThisInput()
  call s:ThisQuestion()
  normal j
endfunction

function! s:ThisAnswer()
  call s:ThisQuestion()
  call search("^>")
  normal ll
endfunction

function! s:ThisPreparationLine()
  call s:ThisQuestion()
  let prepline = search("^<", "nW")
  let nextqline = search("^(\\d\\+)", "nW")

  if nextqline < 0
    nextqline = search("$", "nW")
  end

  if prepline > 0 && prepline < nextqline
    return prepline
  else
    return -1
  endif
endfunction

function! s:ExecuteAnswer()
  call s:ThisAnswer()
  exe "normal \"ay$"
  call s:ThisInput()
  exe "normal @a"
endfunction

function! s:ExecutePreparation()
  let prepline = s:ThisPreparationLine()
  if prepline > 0
    exe prepline + "G"
    normal ll
    exe "normal \"ay$"
    call s:ThisInput()
    exe "normal @a"
  else
    call s:ThisInput()
  end
endfunction

" maps
if !hasmapto('<Plug>Renumber')
  nmap <unique> <LocalLeader>kr <Plug>Renumber
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>Renumber <SID>Renumber
nnoremap <SID>Renumber ms:1,$ call <SID>Renumber()<CR>`s

if !hasmapto('<Plug>GroupRenumber')
  nmap <unique> <LocalLeader>kgr <Plug>GroupRenumber
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>GroupRenumber <SID>GroupRenumber
nnoremap <SID>GroupRenumber ms:call <SID>GroupRenumber()<CR>`s

if !hasmapto('<Plug>NextQuestionWithPrep')
  nmap <unique> Q <Plug>NextQuestionWithPrep
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>NextQuestionWithPrep <SID>NextQuestionWithPrep
nnoremap <SID>NextQuestionWithPrep :call <SID>NextQuestionWithPrep()<CR>

if !hasmapto('<Plug>NextQuestion')
  nmap <unique> <LocalLeader>kn <Plug>NextQuestion
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>NextQuestion <SID>NextQuestion
nnoremap <SID>NextQuestion :call <SID>NextQuestion()<CR>

if !hasmapto('<Plug>PrevQuestion')
  nmap <unique> <LocalLeader>kp <Plug>PrevQuestion
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>PrevQuestion <SID>PrevQuestion
nnoremap <SID>PrevQuestion :call <SID>PrevQuestion()<CR>

if !hasmapto('<Plug>ThisQuestion')
  nmap <unique> <LocalLeader>kq <Plug>ThisQuestion
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>ThisQuestion <SID>ThisQuestion
nnoremap <SID>ThisQuestion :call <SID>ThisQuestion()<CR>

if !hasmapto('<Plug>ThisInput')
  nmap <unique> <LocalLeader>ki <Plug>ThisInput
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>ThisInput <SID>ThisInput
nnoremap <SID>ThisInput :call <SID>ThisInput()<CR>

if !hasmapto('<Plug>ThisAnswer')
  nmap <unique> <LocalLeader>ka <Plug>ThisAnswer
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>ThisAnswer <SID>ThisAnswer
nnoremap <SID>ThisAnswer :call <SID>ThisAnswer()<CR>

if !hasmapto('<Plug>ExecutePreparation')
  nmap <unique> <LocalLeader>kx <Plug>ExecutePreparation
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>ExecutePreparation <SID>ExecutePreparation
nnoremap <SID>ExecutePreparation :call <SID>ExecutePreparation()<CR>

if !hasmapto('<Plug>ExecuteAnswer')
  nmap <unique> <LocalLeader>ke <Plug>ExecuteAnswer
endif
nnoremap <unique> <buffer> <silent> <script> <Plug>ExecuteAnswer <SID>ExecuteAnswer
nnoremap <SID>ExecuteAnswer :call <SID>ExecuteAnswer()<CR>

" restore user's options
let &cpo = s:save_cpo
" vim:set sw=2:
