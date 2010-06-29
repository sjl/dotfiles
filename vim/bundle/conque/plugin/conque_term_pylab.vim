" FILE:     plugin/conque_term_pylab.vim {{{
" AUTHOR:   Gökhan Sever
"           Nico Raffo <nicoraffo@gmail.com>
" MODIFIED: __MODIFIED__
" VERSION:  __VERSION__, for Vim 7.0
" LICENSE:
" }}}
"
" Summary: Ipython shortcuts contributed by Gökhan Sever
" 
" Installation: place this file in your .vim/plugin/ directory.
" 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings {{{

" create a new ipython buffer below
map <F6> :cd %:p:h <CR> :call conque_term#open('ipython -pylab', ['belowright split'])<CR>

" run the current buffer in ipython
nnoremap <silent> <F8> :<C-u>call conque_term_pylab#ipython_run()<CR>

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions {{{

" run the current buffer in ipython
function! conque_term_pylab#ipython_run()
    let cmd = "run " . expand("%:t")
    silent execute 'python ' . g:ConqueTerm_Var . '.write(''' . cmd . ''' + "\n")'
    startinsert!
endfunction 

" }}}

