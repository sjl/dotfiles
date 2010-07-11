" arpeggio - Mappings for simultaneously pressed keys
" Version: 0.0.6
" Copyright (C) 2008-2010 kana <http://whileimautomaton.net/>
" License: So-called MIT/X license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

if exists('g:loaded_arpeggio')
  finish
endif




if !exists('g:arpeggio_timeoutlen')
  let g:arpeggio_timeoutlen = 40
endif
if !exists('g:arpeggio_timeoutlens')
  let g:arpeggio_timeoutlens = {}
endif




command! -complete=command -nargs=+ Arpeggio  call arpeggio#_do(<q-args>)


function! s:_(...)
  execute call('printf',
  \            ['command! %s -complete=mapping -nargs=* Arpeggio%s'
  \             . '  call arpeggio#_map_or_list(%s, %s, <q-args>)']
  \            + a:000)
endfunction

call s:_('-bang', 'map', "(<bang>0 ? 'ic' : 'nvo')", 1)
call s:_('', 'cmap', '"c"', 1)
call s:_('', 'imap', '"i"', 1)
call s:_('', 'lmap', '"l"', 1)
call s:_('', 'nmap', '"n"', 1)
call s:_('', 'omap', '"o"', 1)
call s:_('', 'smap', '"s"', 1)
call s:_('', 'vmap', '"v"', 1)
call s:_('', 'xmap', '"x"', 1)

call s:_('-bang', 'noremap', "(<bang>0 ? 'ic' : 'nvo')", 0)
call s:_('', 'cnoremap', '"c"', 0)
call s:_('', 'inoremap', '"i"', 0)
call s:_('', 'lnoremap', '"l"', 0)
call s:_('', 'nnoremap', '"n"', 0)
call s:_('', 'onoremap', '"o"', 0)
call s:_('', 'snoremap', '"s"', 0)
call s:_('', 'vnoremap', '"v"', 0)
call s:_('', 'xnoremap', '"x"', 0)


function! s:_(...)
  execute call('printf',
  \            ['command! %s -complete=mapping -nargs=* Arpeggio%s'
  \             . '  call arpeggio#_unmap(%s, <q-args>)']
  \            + a:000)
endfunction

call s:_('-bang', 'unmap', "(<bang>0 ? 'ic' : 'nvo')")
call s:_('', 'cunmap', '"c"')
call s:_('', 'iunmap', '"i"')
call s:_('', 'lunmap', '"l"')
call s:_('', 'nunmap', '"n"')
call s:_('', 'ounmap', '"o"')
call s:_('', 'sunmap', '"s"')
call s:_('', 'vunmap', '"v"')
call s:_('', 'xunmap', '"x"')




let g:loaded_arpeggio = 1

" __END__
" vim: foldmethod=marker
