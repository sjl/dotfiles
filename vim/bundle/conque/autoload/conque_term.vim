" FILE:     plugin/conque_term.vim {{{
"
" AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
" MODIFIED: __MODIFIED__
" VERSION:  __VERSION__, for Vim 7.0
" LICENSE:
" Conque - pty interaction in Vim
" Copyright (C) 2009-2010 Nico Raffo 
"
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}


" **********************************************************************************************************
" **** VIM FUNCTIONS ***************************************************************************************
" **********************************************************************************************************

" launch conque
function! conque_term#open(...) "{{{
    let command = get(a:000, 0, '')
    let hooks   = get(a:000, 1, [])

    " bare minimum validation
    if has('python') != 1
        echohl WarningMsg | echomsg "Conque requires the Python interface to be installed" | echohl None
        return 0
    endif
    if empty(command)
        echohl WarningMsg | echomsg "No command found" | echohl None
        return 0
    else
        let l:cargs = split(command, '\s')
        if !executable(l:cargs[0])
            echohl WarningMsg | echomsg "Not an executable: " . l:cargs[0] | echohl None
            return 0
        endif
    endif

    " set buffer window options
    let g:ConqueTerm_BufName = substitute(command, ' ', '\\ ', 'g') . "\\ -\\ " . g:ConqueTerm_Idx
    call conque_term#set_buffer_settings(command, hooks)
    let b:ConqueTerm_Var = 'ConqueTerm_' . g:ConqueTerm_Idx
    let g:ConqueTerm_Var = 'ConqueTerm_' . g:ConqueTerm_Idx
    let g:ConqueTerm_Idx += 1

    " open command
    try
        let l:config = '{"color":' . string(g:ConqueTerm_Color) . ',"TERM":"' . g:ConqueTerm_TERM . '"}'
        execute 'python ' . b:ConqueTerm_Var . ' = Conque()'
        execute "python " . b:ConqueTerm_Var . ".open('" . conque_term#python_escape(command) . "', " . l:config . ")"
    catch 
        echohl WarningMsg | echomsg "Unable to open command: " . command | echohl None
        return 0
    endtry

    " set buffer mappings and auto commands 
    call conque_term#set_mappings('start')

    startinsert!
    return 1
endfunction "}}}

" set buffer options
function! conque_term#set_buffer_settings(command, pre_hooks) "{{{

    " optional hooks to execute, e.g. 'split'
    for h in a:pre_hooks
        sil exe h
    endfor
    sil exe "edit " . g:ConqueTerm_BufName

    " buffer settings 
    setlocal nocompatible      " conque won't work in compatible mode
    setlocal nopaste           " conque won't work in paste mode
    setlocal buftype=nofile    " this buffer is not a file, you can't save it
    setlocal nonumber          " hide line numbers
    setlocal foldcolumn=0      " reasonable left margin
    setlocal nowrap            " default to no wrap (esp with MySQL)
    setlocal noswapfile        " don't bother creating a .swp file
    setlocal updatetime=50     " trigger cursorhold event after 50ms / XXX - global
    setlocal scrolloff=0       " don't use buffer lines. it makes the 'clear' command not work as expected
    setlocal sidescrolloff=0   " don't use buffer lines. it makes the 'clear' command not work as expected
    setlocal sidescroll=1      " don't use buffer lines. it makes the 'clear' command not work as expected
    setlocal foldmethod=manual " don't fold on {{{}}} and stuff
    setlocal bufhidden=hide    " when buffer is no longer displayed, don't wipe it out
    setfiletype conque_term    " useful
    sil exe "setlocal syntax=" . g:ConqueTerm_Syntax

endfunction " }}}

" set key mappings and auto commands
function! conque_term#set_mappings(action) "{{{

    " set action
    if a:action == 'toggle'
        if exists('b:conque_on') && b:conque_on == 1
            let l:action = 'stop'
            echohl WarningMsg | echomsg "Terminal is paused" | echohl None
        else
            let l:action = 'start'
            echohl WarningMsg | echomsg "Terminal is resumed" | echohl None
        endif
    else
        let l:action = a:action
    endif

    " if mappings are being removed, add 'un'
    let map_modifier = 'nore'
    if l:action == 'stop'
        let map_modifier = 'un'
    endif

    " remove all auto commands
    if l:action == 'stop'
        execute 'autocmd! ' . b:ConqueTerm_Var

    else
        execute 'augroup ' . b:ConqueTerm_Var

        " handle unexpected closing of shell, passes HUP to parent and all child processes
        execute 'autocmd ' . b:ConqueTerm_Var . ' BufUnload <buffer> python ' . b:ConqueTerm_Var . '.proc.signal(1)'

        " check for resized/scrolled buffer when entering buffer
        execute 'autocmd ' . b:ConqueTerm_Var . ' BufEnter <buffer> python ' . b:ConqueTerm_Var . '.update_window_size()'
        execute 'autocmd ' . b:ConqueTerm_Var . ' VimResized python ' . b:ConqueTerm_Var . '.update_window_size()'

        " set/reset updatetime on entering/exiting buffer
        autocmd BufEnter <buffer> set updatetime=50
        autocmd BufLeave <buffer> set updatetime=2000

        " check for resized/scrolled buffer when entering insert mode
        " XXX - messed up since we enter insert mode at each updatetime
        "execute 'autocmd InsertEnter <buffer> python ' . b:ConqueTerm_Var . '.screen.align()'

        " read more output when this isn't the current buffer
        if g:ConqueTerm_ReadUnfocused == 1
            execute 'autocmd ' . b:ConqueTerm_Var . ' CursorHold * call conque_term#read_all()'
        endif

        " poll for more output
        sil execute 'autocmd ' . b:ConqueTerm_Var . ' CursorHoldI <buffer> python ' .  b:ConqueTerm_Var . '.auto_read()'
    endif

    " use F22 key to get more input
    if l:action == 'start'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <expr> <F22> "\<left>\<right>"'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <expr> <F23> "\<right>\<left>"'
    else
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <expr> <F22>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <expr> <F23>'
    endif

    " map ASCII 1-31
    for c in range(1, 31)
        " <Esc>
        if c == 27
            continue
        endif
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-' . nr2char(64 + c) . '> <C-o>:python ' . b:ConqueTerm_Var . '.write(chr(' . c . '))<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-' . nr2char(64 + c) . '>'
        endif
    endfor
    if l:action == 'start'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> <C-c> <C-o>:python ' . b:ConqueTerm_Var . '.write(chr(3))<CR>'
    else
        sil exe 'n' . map_modifier . 'map <silent> <buffer> <C-c>'
    endif

    " leave insert mode
    if !exists('g:ConqueTerm_EscKey') || g:ConqueTerm_EscKey == '<Esc>'
        " use <Esc><Esc> to send <Esc> to terminal
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc><Esc> <C-o>:python ' . b:ConqueTerm_Var . '.write(chr(27))<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc><Esc>'
        endif
    else
        " use <Esc> to send <Esc> to terminal
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_EscKey . ' <Esc>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc> <C-o>:python ' . b:ConqueTerm_Var . '.write(chr(27))<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_EscKey
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc>'
        endif
    endif

    " Map <C-w> in insert mode
    if exists('g:ConqueTerm_CWInsert') && g:ConqueTerm_CWInsert == 1
        inoremap <silent> <buffer> <C-w>j <Esc><C-w>j
        inoremap <silent> <buffer> <C-w>k <Esc><C-w>k
        inoremap <silent> <buffer> <C-w>h <Esc><C-w>h
        inoremap <silent> <buffer> <C-w>l <Esc><C-w>l
        inoremap <silent> <buffer> <C-w>w <Esc><C-w>w
    endif

    " map ASCII 33-127
    for i in range(33, 127)
        " <Bar>
        if i == 124
            if l:action == 'start'
                sil exe "i" . map_modifier . "map <silent> <buffer> <Bar> <C-o>:python " . b:ConqueTerm_Var . ".write(chr(124))<CR>"
            else
                sil exe "i" . map_modifier . "map <silent> <buffer> <Bar>"
            endif
            continue
        endif
        if l:action == 'start'
            sil exe "i" . map_modifier . "map <silent> <buffer> " . nr2char(i) . " <C-o>:python " . b:ConqueTerm_Var . ".write(chr(" . i . "))<CR>"
        else
            sil exe "i" . map_modifier . "map <silent> <buffer> " . nr2char(i)
        endif
    endfor

    " map ASCII 128-255
    for i in range(128, 255)
        if l:action == 'start'
            sil exe "i" . map_modifier . "map <silent> <buffer> " . nr2char(i) . " <C-o>:python " . b:ConqueTerm_Var . ".write('" . nr2char(i) . "')<CR>"
        else
            sil exe "i" . map_modifier . "map <silent> <buffer> " . nr2char(i)
        endif
    endfor

    " Special cases
    if l:action == 'start'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <BS> <C-o>:python ' . b:ConqueTerm_Var . '.write(u"\u0008")<CR>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Space> <C-o>:python ' . b:ConqueTerm_Var . '.write(" ")<CR>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Up> <C-o>:python ' . b:ConqueTerm_Var . '.write(u"\u001b[A")<CR>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Down> <C-o>:python ' . b:ConqueTerm_Var . '.write(u"\u001b[B")<CR>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Right> <C-o>:python ' . b:ConqueTerm_Var . '.write(u"\u001b[C")<CR>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Left> <C-o>:python ' . b:ConqueTerm_Var . '.write(u"\u001b[D")<CR>'
    else
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <BS>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Space>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Up>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Down>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Right>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Left>'
    endif

    " send selected text into conque
    if l:action == 'start'
        sil exe 'v' . map_modifier . 'map <silent> <F9> :<C-u>call conque_term#send_selected(visualmode())<CR>'
    else
        sil exe 'v' . map_modifier . 'map <silent> <F9>'
    endif

    " remap paste keys
    if l:action == 'start'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> p :python ' . b:ConqueTerm_Var . '.write(vim.eval("@@"))<CR>a'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> P :python ' . b:ConqueTerm_Var . '.write(vim.eval("@@"))<CR>a'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> ]p :python ' . b:ConqueTerm_Var . '.write(vim.eval("@@"))<CR>a'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> [p :python ' . b:ConqueTerm_Var . '.write(vim.eval("@@"))<CR>a'
    else
        sil exe 'n' . map_modifier . 'map <silent> <buffer> p'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> P'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> ]p'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> [p'
    endif
    if has('gui_running')
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <buffer> <S-Insert> <Esc>:<C-u>python ' . b:ConqueTerm_Var . ".write(vim.eval('@+'))<CR>a"
        else
            sil exe 'i' . map_modifier . 'map <buffer> <S-Insert>'
        endif
    endif

    " disable other normal mode keys which insert text
    if l:action == 'start'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> r :echo "Replace mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> R :echo "Replace mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> c :echo "Change mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> C :echo "Change mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> s :echo "Change mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> S :echo "Change mode disabled in shell."<CR>'
    else
        sil exe 'n' . map_modifier . 'map <silent> <buffer> r'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> R'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> c'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> C'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> s'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> S'
    endif

    " set conque as on or off
    if l:action == 'start'
        let b:conque_on = 1
    else
        let b:conque_on = 0
    endif

    " map command to start stop the shell
    if a:action == 'start'
        nnoremap <F5> :<C-u>call conque_term#set_mappings('toggle')<CR>
    endif

endfunction " }}}


" send selected text from another buffer
function! conque_term#send_selected(type) "{{{
    let reg_save = @@

    " save user's sb settings
    let sb_save = &switchbuf
    set switchbuf=usetab

    " yank current selection
    sil exe "normal! `<" . a:type . "`>y"

    " format yanked text
    let @@ = substitute(@@, '^[\r\n]*', '', '')
    let @@ = substitute(@@, '[\r\n]*$', '', '')

    " execute yanked text
    sil exe ":sb " . g:ConqueTerm_BufName
    sil exe 'python ' . g:ConqueTerm_Var . '.paste_selection()'

    " reset original values
    let @@ = reg_save
    sil exe 'set switchbuf=' . sb_save

    " scroll buffer left
    startinsert!
    normal 0zH
endfunction "}}}

" read from all known conque buffers
function! conque_term#read_all() "{{{
    " don't run this if we're in a conque buffer
    if exists('b:ConqueTerm_Var')
        return
    endif

    try
        for i in range(1, g:ConqueTerm_Idx - 1)
            execute 'python ConqueTerm_' . string(i) . '.read(1)'
        endfor
    catch
        " probably a deleted buffer
    endtry

    " restart updatetime
    call feedkeys("f\e")
endfunction "}}}

" util function to add enough \s to pass a string to python
function! conque_term#python_escape(input) "{{{
    let l:cleaned = a:input
    let l:cleaned = substitute(l:cleaned, '\\', '\\\\', 'g')
    let l:cleaned = substitute(l:cleaned, '\n', '\\n', 'g')
    let l:cleaned = substitute(l:cleaned, '\r', '\\r', 'g')
    let l:cleaned = substitute(l:cleaned, "'", "\\\\'", 'g')
    return l:cleaned
endfunction "}}}

" **********************************************************************************************************
" **** PYTHON **********************************************************************************************
" **********************************************************************************************************

let conque_py_dir = substitute(findfile('autoload/conque_term.vim', &rtp), 'conque_term.vim', '', '')
exec "pyfile " . conque_py_dir . "conque.py"
exec "pyfile " . conque_py_dir . "conque_subprocess.py"
exec "pyfile " . conque_py_dir . "conque_screen.py"

