" Plugin to turn a CVS conflict file into a set of diff'ed files
" with mappings to simplify the merging
" 
" Version: 1.1
" Last Changed: 07 Jul 2003
"
" Maintainer: Chris Rimmer <c@24.org.uk>

let s:save_cpo = &cpo
set cpo&vim

if exists("loaded_conf2dif")
  finish
endif

let s:starts = "<<<<<<<"
let s:middle = "======="
let s:ends   = ">>>>>>>"

let s:conf2dif_orig = ""

function s:FilterConf(which) range
  let switch = 1
  let linenum = a:firstline
  let lastline = a:lastline
  let s:conflict = 0
  while linenum <= lastline
    execute linenum
    let line = getline(".")
    
    let newline = ""
    if line =~ "^".s:starts
      let switch = (a:which == 0)
      let s:conflict = 1
    elseif line =~ "^".s:middle
      let switch = (a:which == 1)
      let s:conflict = 1
    elseif line =~ "^".s:ends
      let s:conflict = 1
      let switch = 1
      if a:which == 2
        let newline = s:middle
      endif
    else
      let newline = line
    endif    
    
    if (newline == "" && line != "") || switch == 0
      normal dd
      let lastline = lastline - 1
    else
      if newline != line
        call setline(".", newline)
      endif
      let linenum = linenum + 1  
    endif
  endwhile
endfunction

function s:NewBuffer(which)
  vnew
  setlocal noswapfile
  normal "ap
  execute 0
  normal dd
  %call s:FilterConf(a:which)
  diffthis
  setlocal nomodifiable
  setlocal buftype=nowrite
  setlocal bufhidden=delete
endfunction

function s:GotoOriginal()
  execute bufwinnr(s:conf2dif_orig)."wincmd W"
endfunction

function s:GetLeft()
  if bufnr("%") != s:conf2dif_orig
    return
  endif
  execute "diffget ".s:conf2dif_left
  diffupdate 
endfunction

function s:GetRight()
  if bufnr("%") != s:conf2dif_orig
    return
  endif
  call s:GotoOriginal()
  execute "diffget ".s:conf2dif_right
  diffupdate 
endfunction

function s:Finish()
  if s:conf2dif_orig == "" 
    return
  endif
  call s:GotoOriginal()
  set nodiff
  set foldcolumn=0
  nmapclear <buffer>
  execute "bunload ".s:conf2dif_left
  execute "bunload ".s:conf2dif_right
  let s:conf2dif_orig = ""
  call s:MenusBefore()
endfunction

function s:Conflict2Diff()
  if s:conf2dif_orig != "" 
    return
  endif
  let s:conf2dif_orig = bufnr("%")
  let temp_a = @a
  %yank a
  %call s:FilterConf(2)
  if s:conflict == 0 
    execute 0
    echoerr "This doesn't seem to be a CVS Conflict File!"
    let s:conf2dif_orig = ""
    return
  endif
  set nosplitright
  call s:NewBuffer(0)
  let s:conf2dif_left = bufnr("%")
  call s:GotoOriginal()
  set splitright
  call s:NewBuffer(1)
  let s:conf2dif_right = bufnr("%")
  call s:GotoOriginal()
  diffthis
  execute 0
  nmap <buffer> <C-Left> :Conflict2DiffGetLeft<CR>
  nmap <buffer> <C-Right> :Conflict2DiffGetRight<CR>
  nmap <buffer> <C-Up> [cz.
  nmap <buffer> <C-Down> ]cz.
  nmap <buffer> <C-q> :Conflict2DiffFinish<CR>
  call s:MenusDuring()
  normal ]c
  let @a = temp_a
endfunction

function s:MenusBefore()
  nmenu enable Plugin.CVS\ Conflict.Resolve 
  nmenu disable Plugin.CVS\ Conflict.Use\ Left 
  nmenu disable Plugin.CVS\ Conflict.Use\ Right
  nmenu disable Plugin.CVS\ Conflict.Finish
endfunction

function s:MenusDuring()
  nmenu disable Plugin.CVS\ Conflict.Resolve
  nmenu enable Plugin.CVS\ Conflict.Use\ Left 
  nmenu enable Plugin.CVS\ Conflict.Use\ Right
  nmenu enable Plugin.CVS\ Conflict.Finish
endfunction

command Conflict2Diff :call s:Conflict2Diff()
command Conflict2DiffGetLeft :call s:GetLeft()
command Conflict2DiffGetRight :call s:GetRight()
command Conflict2DiffFinish :call s:Finish()

nmenu Plugin.CVS\ Conflict.Resolve :Conflict2Diff<CR>
nmenu Plugin.CVS\ Conflict.Use\ Left :Conflict2DiffGetLeft<CR>
nmenu Plugin.CVS\ Conflict.Use\ Right :Conflict2DiffGetRight<CR>
nmenu Plugin.CVS\ Conflict.Finish :Conflict2DiffFinish<CR>

call s:MenusBefore()

let &cpo = s:save_cpo
