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
" Notes  "{{{1
"
" CONVENTIONS FOR INTERNAL MAPPINGS
"
" <SID>work:...
"               Use to set 'timeoutlen', to restore 'timeoutlen', and to
"               determine whether keys are simultaneously pressed or not.
"
" <SID>success:...
"               Use to restore 'timeoutlen' and to do user-defined action for
"               the simultaneously pressed keys "...".
"
"
" MAPPING FLOWCHART
"
"                        {X}            (user types a key {X})
"                         |
"                         v
"                  <SID>work:{X}
"                         |  (are {Y}... simultaneously typed with {X}?)
"                  [yes]  |  [no]
"         .---------------*-------------------.
"         |                                   |
"         v                                   v
"  <SID>work:{X}{Y}...          <Plug>(arpeggio-default:{X})
"         |
"         v
" <SID>success:{X}{Y}...
"         |
"         v
"       {rhs}








" Variables  "{{{1

" See s:set_up_options() and s:restore_options().
let s:original_showcmd = &showcmd
let s:original_timeout = &timeout
let s:original_timeoutlen = &timeoutlen
let s:original_ttimeoutlen = &ttimeoutlen








" Public  "{{{1
function! arpeggio#list(modes, options, ...)  "{{{2
  let lhs = 1 <= a:0 ? a:1 : 0
  let opt_buffer = a:options =~# 'b' ? '<buffer>' : ''

  for mode in s:each_char(a:modes)
    execute printf('%smap %s <SID>success:%s',
    \              mode, opt_buffer, lhs is 0 ? '' : lhs)
  endfor
  return
endfunction




function! arpeggio#load()  "{{{2
  runtime! plugin/arpeggio.vim
endfunction




function! arpeggio#map(modes, options, remap_p, lhs, rhs)  "{{{2
  for mode in s:each_char(a:modes)
    call s:do_map(mode, a:options, a:remap_p, s:split_to_keys(a:lhs), a:rhs)
  endfor
  return
endfunction




function! arpeggio#unmap(modes, options, lhs)  "{{{2
  let v:errmsg = ''

  for mode in s:each_char(a:modes)
    call s:do_unmap(mode, a:options, s:split_to_keys(a:lhs))
  endfor

  if v:errmsg != ''
    echoerr v:errmsg
  endif
  return v:errmsg == ''
endfunction








" Core  "{{{1
function! arpeggio#_do(script)  "{{{2
  let _ = split(substitute(a:script, '^\s\+', '', ''), '^\S\+\zs')
  execute 'Arpeggio'._[0] join(_[1:], '')
  return
endfunction




function! arpeggio#_map_or_list(modes, remap_p, q_args)  "{{{2
  let [options, lhs, rhs] = s:parse_args(a:q_args)
  if rhs isnot 0
    return arpeggio#map(a:modes, options, a:remap_p, lhs, rhs)
  else
    return arpeggio#list(a:modes, options, lhs)
  endif
endfunction




function! arpeggio#_unmap(modes, q_args)  "{{{2
  let [options, lhs, rhs] = s:parse_args(a:q_args)
  return arpeggio#unmap(a:modes, options, lhs)
endfunction




function! s:chord_cancel(key)  "{{{2
  call s:restore_options()
  return "\<Plug>(arpeggio-default:" . a:key . ')'
endfunction




function! s:chord_key(key)  "{{{2
  call s:set_up_options(a:key)
  return s:SID . 'work:' . a:key  " <SID>work:...
endfunction




function! s:chord_success(keys)  "{{{2
  call s:restore_options()
  return s:SID . 'success:' . a:keys  " <SID>success:...
endfunction




function! s:do_map(mode, options, remap_p, keys, rhs)  "{{{2
  " Assumption: Values in a:keys are <>-escaped, e.g., "<Tab>" not "\<Tab>".
  let opt_buffer = a:options =~# 'b' ? '<buffer>' : ''

  let already_mapped_p = 0
  for key in a:keys
    let rhs = maparg(key, a:mode)
    if rhs != '' && rhs !=# ('<SNR>' . matchstr(s:SID, '\d\+') . '_'
    \                        . 'chord_key(' . string(key) . ')')
      echohl WarningMsg
      echomsg 'Key' string(key) 'is already mapped in mode' string(a:mode)
      echohl None
      let already_mapped_p = !0
    endif
  endfor
  if a:options =~# 'u' && already_mapped_p
    echoerr 'Abort to map because of the above reason'
    return
  endif

  for key in a:keys
    execute printf('%smap <expr> %s %s  <SID>chord_key(%s)',
    \              a:mode, opt_buffer, key, string(s:unescape_lhs(key)))
  endfor

  let combos = []
  for i in range(1, len(a:keys) - 1)
    call extend(combos, s:permutations(a:keys, i))
  endfor
  for combo in combos
    execute printf('%smap <expr> <SID>work:%s  <SID>chord_cancel(%s)',
    \              a:mode, combo, string(s:unescape_lhs(combo)))
    execute printf('silent! %snoremap <unique> <Plug>(arpeggio-default:%s) %s',
    \              a:mode, combo, combo)
  endfor

  for combo in s:permutations(a:keys, len(a:keys))
    execute printf('%smap <expr> <SID>work:%s  <SID>chord_success(%s)',
    \              a:mode, combo, string(s:unescape_lhs(combo)))
    execute printf('%s%smap %s <SID>success:%s  %s',
    \              a:mode,
    \              a:remap_p ? '' : 'nore',
    \              s:to_map_arguments(a:options),
    \              combo,
    \              a:rhs)
  endfor
  return
endfunction




function! s:do_unmap(mode, options, keys)  "{{{2
  " FIXME: Mediate key mappings "<SID>work:" should be removed.
  "        But they may be used by other arpeggio key mappings and it's hard
  "        to determine whether a given mediate key mappng is still used or
  "        not in fast and exact way.  So that they aren't removed currently.
  let opt_buffer = a:options =~# 'b' ? '<buffer>' : ''

  for key in a:keys
    silent! execute printf('%sunmap %s %s',
    \                      a:mode, opt_buffer, key)
  endfor

  for combo in s:permutations(a:keys, len(a:keys))
    silent! execute printf('%sunmap %s <SID>success:%s',
    \                      a:mode,
    \                      s:to_map_arguments(a:options),
    \                      combo)
  endfor

  return
endfunction








" Misc.  "{{{1
function! s:SID()  "{{{2
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_')
endfunction
let s:SID = "\<SNR>" . s:SID() . '_'




function! s:each_char(s)  "{{{2
  return split(a:s, '.\zs')
endfunction




function! s:parse_args(q_args)  "{{{2
  " Parse <q-args> for :map commands into {options}, {lhs} and {rhs}.
  " Omitted arguments are expressed as 0.
  let ss = s:split_to_keys(a:q_args)

  let options = ''
  let ss = s:skip_spaces(ss)
  while 0 < len(ss)
    if ss[0] =~? '<buffer>'
      let options .= 'b'
    elseif ss[0] =~? '<expr>'
      let options .= 'e'
    elseif ss[0] =~? '<silent>'
      let options .= 's'
    elseif ss[0] =~? '<unique>'
      let options .= 'u'
    else
      break
    endif
    let ss = s:skip_spaces(ss[1:])
  endwhile

  let i = 0
  while i < len(ss)
    if ss[i] =~ '\s'
      break
    endif
    let i += 1
  endwhile
  let lhs = 1 <= i ? join(ss[:i-1], '') : 0
  let ss = s:skip_spaces(ss[(i):])

  let rhs = 0 < len(ss) ? join(ss, '') : 0

  return [options, lhs, rhs]
endfunction




function! s:permutations(ss, r)  "{{{2
  " This function is translated one of itertools.permutations() of Python 2.6:
  " http://www.python.org/doc/2.6/library/itertools.html#itertools.permutations
  let result = []
  let n = len(a:ss)
  let r = a:r
  let indices = range(n)
  let cycles = range(n, n-r+1, -1)
  let rest = n
  for _ in range(n-1, n-r+1, -1)
    let rest = rest * _
  endfor

  call add(result, join(map(indices[:r-1], 'a:ss[v:val]'), ''))
  for _ in range(rest - 1)
    for i in range(r-1, 0, -1)
      let cycles[i] -= 1
      if cycles[i] == 0
        let indices[(i):] = indices[(i+1):] + indices[(i):(i)]
        let cycles[i] = n - i
      else
        let j = cycles[i]
        let [indices[i], indices[-j]] = [indices[-j], indices[i]]
        call add(result, join(map(indices[:r-1], 'a:ss[v:val]'), ''))
        break
      endif
    endfor
  endfor
  return result
endfunction




function! s:restore_options()  "{{{2
  let &showcmd = s:original_showcmd
  let &timeout = s:original_timeout
  let &timeoutlen = s:original_timeoutlen
  let &ttimeoutlen = s:original_ttimeoutlen
  return
endfunction




function! s:set_up_options(key)  "{{{2
  let s:original_showcmd = &showcmd
  let s:original_timeout = &timeout
  let s:original_timeoutlen = &timeoutlen
  let s:original_ttimeoutlen = &ttimeoutlen

  set noshowcmd  " To avoid flickering in the bottom line.
  set timeout  " To ensure time out on :mappings
  let &timeoutlen = get(g:arpeggio_timeoutlens, a:key, g:arpeggio_timeoutlen)
  let &ttimeoutlen = (0 <= s:original_ttimeoutlen
  \                   ? s:original_ttimeoutlen
  \                   : s:original_timeoutlen)
  return
endfunction




function! s:skip_spaces(ss)  "{{{2
  let i = 0
  for i in range(len(a:ss))
    if a:ss[i] !~# '\s'
      break
    endif
  endfor
  return a:ss[(i):]
endfunction




function! s:split_to_keys(lhs)  "{{{2
  " Assumption: Special keys such as <C-u> are escaped with < and >, i.e.,
  "             a:lhs doesn't directly contain any escape sequences.
  return split(a:lhs, '\(<[^<>]\+>\|.\)\zs')
endfunction




function! s:to_map_arguments(options)  "{{{2
  let _ = {'b': '<buffer>', 'e': '<expr>', 's': '<silent>', 'u': '<unique>'}
  return join(map(s:each_char(a:options), '_[v:val]'))
endfunction




function! s:unescape_lhs(escaped_lhs)  "{{{2
  let keys = s:split_to_keys(a:escaped_lhs)
  call map(keys, 'v:val =~ "^<.*>$" ? eval(''"\'' . v:val . ''"'') : v:val')
  return join(keys, '')
endfunction




function! s:without(list, i)  "{{{2
  if 0 < a:i
    return a:list[0 : (a:i-1)] + a:list[(a:i+1) : -1]
  else
    return a:list[1:]
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
