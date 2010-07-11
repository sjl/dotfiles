" Vim additional syntax: vim/arpeggio - highlight :Arpeggio commands
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

syntax keyword vimArpeggioCommand
\      Arpeggio
\      skipwhite nextgroup=vimMap

syntax match vimArpeggioCommand
\      /\<Arpeggio[cilnosvx]\(\|nore\|un\)map\>/
\      skipwhite nextgroup=vimMapBang,vimMapMod,vimMapLhs

syntax match vimArpeggioCommand
\      /\<Arpeggio\%(\|nore\|un\)map\>!\?/
\      skipwhite nextgroup=vimMapMod,vimMapLhs




highlight default link vimArpeggioCommand  vimCommand

" __END__
" vim: foldmethod=marker
