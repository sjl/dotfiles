" Vim compiler file for Python
" Compiler:     Style checking tool for Python
" Maintainer:   Oleksandr Tymoshenko <gonzo@univ.kiev.ua>
" Last Change:  2010 april 29
" Version:      0.6 
" Contributors:
"     Artur Wroblewski
"     Menno
"     Jose Blanca
"
" Installation:
"   Drop pylint.vim in ~/.vim/compiler directory. Ensure that your PATH
"   environment variable includes the path to 'pylint' executable.
"
"   Add the following line to the autocmd section of .vimrc
"
"      autocmd FileType python compiler pylint
"
" Usage:
"   Pylint is called after a buffer with Python code is saved. QuickFix
"   window is opened to show errors, warnings and hints provided by Pylint.
"   Code rate calculated by Pylint is displayed at the bottom of the
"   window.
"
"   Above is realized with :Pylint command. To disable calling Pylint every
"   time a buffer is saved put into .vimrc file
"
"       let g:pylint_onwrite = 0
"
"   Displaying code rate calculated by Pylint can be avoided by setting
"
"       let g:pylint_show_rate = 0
"
"   Openning of QuickFix window can be disabled with
"
"       let g:pylint_cwindow = 0
"
"   Setting signs for the lines with errors can be disabled with
"
"	let g:pylint_signs = 0
"
"   Of course, standard :make command can be used as in case of every
"   other compiler.
"

if exists('current_compiler')
  finish
endif
let current_compiler = 'pylint'

if !exists('g:pylint_onwrite')
    let g:pylint_onwrite = 1
endif

if !exists('g:pylint_show_rate')
    let g:pylint_show_rate = 1
endif

if !exists('g:pylint_cwindow')
    let g:pylint_cwindow = 1
endif

if !exists('g:pylint_signs')
    let g:pylint_signs = 1
endif

if exists(':Pylint') != 2
    command Pylint :call Pylint(0)
endif

if exists(":CompilerSet") != 2          " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

" We should echo filename because pylint truncates .py
" If someone know better way - let me know :) 
" CompilerSet makeprg=(echo\ '[%]';\ pylint\ -r\ y\ %)
" modified by Jose Blanca
" it does not list the info messages and it lists errors first
" pylint -i y hola.py|grep -e '^[WECY]'|sed -e 's/^W/2 W /' -e 's/^E/1 E /' -e
" 's/^C/3 C /' |sort -k1,3
CompilerSet makeprg=(echo\ '[%]';pylint\ -i\ y\ %\\\|grep\ -e\ \'^[WECY]\'\\\|sed\ -e\ \'s/^E/1\ E\ /\'\ -e\ \'s/^W/2\ W\ /\'\ -e\ \'s/^C/3\ C\ /\'\ \\\|sort\ -k1,3)

" We could omit end of file-entry, there is only one file
" %+I... - include code rating information
" %-G... - remove all remaining report lines from quickfix buffer
" the original efm
"CompilerSet efm=%+P[%f],%t:\ %#%l:%m,%Z,%+IYour\ code%m,%Z,%-G%.%#
"modified by Jose Blanca
"version for the sorted and filtered pylint
CompilerSet efm=%-GI%n:\ %#%l:%m,%*\\d\ %t\ %n:\ %#%l:%m,%Z,%+IYour\ code%m,%Z,%-G%.%#

""sings
"signs definition
sign define W text=WW texthl=pylint
sign define C text=CC texthl=pylint
sign define E text=EE texthl=pylint_error

if g:pylint_onwrite
    augroup python
        au!
        au BufWritePost * call Pylint(1)
    augroup end
endif

function! Pylint(writing)
    if !a:writing && &modified
        " Save before running
        write
    endif	

    if has('win32') || has('win16') || has('win95') || has('win64')
        setlocal sp=>%s
    else
        setlocal sp=>%s\ 2>&1
    endif

    " If check is executed by buffer write - do not jump to first error
    if !a:writing
        silent make
    else
        silent make!
    endif

    if g:pylint_cwindow
        cwindow
    endif

    call PylintEvaluation()

    if g:pylint_show_rate
        echon 'code rate: ' b:pylint_rate ', prev: ' b:pylint_prev_rate
    endif

    if g:pylint_signs
        call PlacePylintSigns()
    endif
endfunction

function! PylintEvaluation()
    let l:list = getqflist()
    let b:pylint_rate = '0.00'
    let b:pylint_prev_rate = '0.00'
    for l:item in l:list
        if l:item.type == 'I' && l:item.text =~ 'Your code has been rated'
            let l:re_rate = '\(-\?[0-9]\{1,2\}\.[0-9]\{2\}\)/'
            let b:pylint_rate = substitute(l:item.text, '.*rated at '.l:re_rate.'.*', '\1', 'g')
            " Only if there is information about previous run
            if l:item.text =~ 'previous run: '
                let b:pylint_prev_rate = substitute(l:item.text, '.*previous run: '.l:re_rate.'.*', '\1', 'g')
            endif    
        endif
    endfor
endfunction

function! PlacePylintSigns()
    "in which buffer are we?
    "in theory let l:buffr=bufname(l:item.bufnr)
    "should work inside the next loop, but i haven't manage to do it
    let l:buffr = bufname('%')
    "the previous lines are suppose to work, but sometimes it doesn't
    if empty(l:buffr)
        let l:buffr=bufname(1)
    endif

    "first remove all sings
    exec('sign unplace *')
    "now we place one sign for every quickfix line
    let l:list = getqflist()
    let l:id = 1
    for l:item in l:list
	"the line signs
	let l:lnum=item.lnum
	let l:type=item.type
	"sign place 1 line=l:lnum name=pylint file=l:buffr
	if l:type != 'I'
	    let l:exec = printf('sign place %d name=%s line=%d file=%s',
	                        \ l:id, l:type, l:lnum, l:buffr)
	    let l:id = l:id + 1
	    execute l:exec
	endif
    endfor
endfunction

