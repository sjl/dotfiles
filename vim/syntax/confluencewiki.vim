"============================================================================
"
" Confluence WIKI syntax file
"
" Language:    Confluence WIKI
" Version:     0.1.0
" Maintainer:  Daniel Grana <daniel{AT}insophia{DOT}com>
" Thanks:      Ingo Karkat <swdev{AT}ingo-karkat{DOT}de>
" License:     GPL (http://www.gnu.org/licenses/gpl.txt)
"    Copyright (C) 2004  Rainer Thierfelder
"
"    This program is free software; you can redistribute it and/or modify
"    it under the terms of the GNU General Public License as published by
"    the Free Software Foundation; either version 2 of the License, or
"    (at your option) any later version.
"
"    This program is distributed in the hope that it will be useful,
"    but WITHOUT ANY WARRANTY; without even the implied warranty of
"    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"    GNU General Public License for more details.
"
"    You should have received a copy of the GNU General Public License
"    along with this program; if not, write to the Free Software
"    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
"
"============================================================================
"
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'confluencewiki'
endif

" Don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ ConfluenceHiLink   highlight link <args>
  command! -nargs=+ ConfluenceSynColor highlight <args>
else
  command! -nargs=+ ConfluenceHiLink   highlight default link <args>
  command! -nargs=+ ConfluenceSynColor highlight default <args>
endif

if v:version >= 700
  syntax spell toplevel
endif 


"============================================================================
" Group Definitions:    
"============================================================================

" Emphasis:  
function! s:ConfluenceCreateEmphasis(token, name)
    execute 'syntax region confluence'.a:name.
    \' oneline start="\(^\|[ ]\)\zs'.a:token.'\%('.a:token.'\)\@!'.
    \'" end="'.a:token.'\ze\([,. ?!()[\]{}:\-]\|$\)"'
endfunction

syntax region confluenceFixed oneline start="\(^\|[ ]\)\zs{{" end="}}\ze\([,. ?!()[\]{}):\-]\|$\)"
" Note: Confluence 2.10.1 ignores escaping of \{{monospaced}} (same as {{monospaced}}). 
syntax region confluenceFixed oneline start="{{" end="}}\ze\([,. ?!()[\]{}):\-]\|$\)" contained

call s:ConfluenceCreateEmphasis('\*', 'Bold')
call s:ConfluenceCreateEmphasis('_',  'Italic')
call s:ConfluenceCreateEmphasis('??', 'Citation')
call s:ConfluenceCreateEmphasis('-', 'Strike')
call s:ConfluenceCreateEmphasis('+', 'Underlined')
call s:ConfluenceCreateEmphasis('\^', 'Superscript')
call s:ConfluenceCreateEmphasis('\~', 'Subscript')


" Syntax:  
" Note: Confluence 2.10.1 ignores escaping of \{{monospaced}} (same as {{monospaced}}). 
"syntax match confluenceEscaping "\\\%(??\|{{\|[*_\-+^~{!\[(]\)" contains=confluenceEscapeCharacter
syntax match confluenceEscaping "\\\%(??\|{{\|[*_\-+^~{!\[(]\)" contains=confluenceEscapeCharacter,confluenceFixed
syntax match confluenceEscapeCharacter "\\" contained
syntax match confluenceDelimiter "|"
syntax match confluenceDelimiter "||[^|]" contains=confluenceTableHeader
syntax match confluenceDelimiter "[^|]||"
syntax match confluenceTableHeader "||\zs[^|]\+\ze||" contained contains=ALLBUT,confluenceDelimiter
syntax match confluenceSymbols "\%(^\|\s\)\zs-\{2,3}\ze\%($\|\s\)"
syntax match confluenceSeparator    "^\s*----\s*$"
syntax match confluenceList "^[*#]\+\ze "
syntax match confluenceSingleList "^-\ze "

"syntax match confluenceVariable "\([^!]\|^\)\zs%\w\+%"

" tag support is a limited to no white spaces in tag parameters
syntax match confluenceTagParameterName      "[:|]\zs\w\+=\?[^|}]\+" contained contains=@NoSpell,confluenceTagParameterValue
syntax match confluenceTagParameterValue     "\w\+=\zs[^|}]\+" contained contains=@NoSpell
syntax match confluenceTag                   "{\%(\w\|-\)\+\(:\(\w\+=\?[^|}]\+|\?\)*\)\?}" contains=@NoSpell,confluenceTagParameterName

syntax region confluenceComment start="{HTMLcomment\%(:hidden\)\?}" end="{HTMLcomment}" keepend contains=TOP

syntax match confluenceCodeTag "{code\(:\(\w\+=\?[^|}]\+|\?\)*\)\?}" contains=confluenceTagParameterName,@NoSpell contained
syntax region confluenceCode start="{code\(:\(\w\+=\?[^|}]\+|\?\)*\)\?}" end="{code}" keepend contains=confluenceCodeTag
syntax match confluenceVerbatimTag "{noformat\(:\(\w\+=\?[^|}]\+|\?\)*\)\?}" contains=confluenceTagParameterName,@NoSpell contained
syntax region confluenceVerbatim start="{noformat\(:\(\w\+=\?[^|}]\+|\?\)*\)\?}" end="{noformat}" keepend contains=confluenceVerbatimTag

syntax match confluenceQuoteMarker "^bq. " contains=@NoSpell contained
syntax match confluenceQuote "^bq. .*$" contains=confluenceQuoteMarker
syntax region confluenceQuote start="{quote}" end="{quote}" keepend contains=TOP

syntax match confluenceHeadingMarker "^h[1-6]. " contains=@NoSpell contained
syntax match confluenceHeading "^h[1-6]. .*$" contains=confluenceHeadingMarker

" Note: Confluence 2.10.1 does not escape smileys \:) \:( \:P \:D \;)
syntax match confluenceEmoticons "\%(^\|\s\)\zs\%(:)\|:(\|:P\|:D\|;)\)\ze\%($\|\s\)"
syntax match confluenceEmoticons "\%(^\|[^\\]\)\zs([yni/x!+-?*])\|(\%(on\|off\))"

let s:wikiWord = '\u[a-z0-9]\+\(\u[a-z0-9]\+\)\+'

execute 'syntax match confluenceAnchor +^#'.s:wikiWord.'\ze\(\>\|_\)+'
execute 'syntax match confluenceWord +\(\s\|^\)\zs\(\u\l\+\.\)\='.s:wikiWord.'\(#'.s:wikiWord.'\)\=\ze\(\>\|_\)+'
" Regex guide:                        ^pre        ^web name       ^wikiword  ^anchor               ^ post

" Images: 
syntax match confluenceImageParameterName      "[,|]\zs\w\+=\?[^,!]\+" contained contains=confluenceImageParameterValue,@NoSpell
syntax match confluenceImageParameterValue     "\w\+=\zs[^,!]\+" contained contains=@NoSpell
syntax match confluenceImageLink               "!\zs\S[^|!]*" contained contains=@NoSpell
syntax match confluenceImage "!\S[^!]*\S!" contains=confluenceImageLink,confluenceImageParameterName

" Links: 
syntax match confluenceLink "\[[^|\]]\+\]" contains=confluenceLinkStart,confluenceLinkEnd,@NoSpell
syntax match confluenceLink "\[[^|\]]\+|[^|\]]\+\]" contains=confluenceLinkMarker,confluenceLinkEnd,confluenceLinkLabel,@NoSpell
syntax match confluenceLink "\[[^|\]]\+|[^|\]]\+|[^|\]]\+\]" contains=confluenceLinkMarker,confluenceLinkLabel,confluenceLinkTip,@NoSpell

syntax match confluenceLinkLabel    "\[[^|\]]\+\ze|" contained contains=confluenceLinkStart
syntax match confluenceLinkTip  "[^|\]]\+\]"   contained contains=confluenceLinkEnd
syntax match confluenceLinkMarker "|"          contained
syntax match confluenceLinkStart "\["          contained
syntax match confluenceLinkEnd "\]"            contained

"============================================================================
" Group Linking:    
"============================================================================

ConfluenceHiLink confluenceEscapeCharacter Type
ConfluenceHiLink confluenceHeading       Title
ConfluenceHiLink confluenceHeadingMarker Type
ConfluenceHiLink confluenceVariable      PreProc
ConfluenceHiLink confluenceTagParameterName   Type
ConfluenceHiLink confluenceTagParameterValue  Constant
ConfluenceHiLink confluenceCodeTag       PreProc
ConfluenceHiLink confluenceVerbatimTag   PreProc
ConfluenceHiLink confluenceTag           PreProc
ConfluenceHiLink confluenceQuoteMarker   Type
ConfluenceHiLink confluenceQuote         String
ConfluenceHiLink confluenceComment       Comment
ConfluenceHiLink confluenceWord          Tag
ConfluenceHiLink confluenceAnchor        PreProc
ConfluenceHiLink confluenceVerbatim      Constant
ConfluenceHiLink confluenceCode          Constant
ConfluenceHiLink confluenceList          Type
ConfluenceHiLink confluenceSingleList    Type
ConfluenceSynColor confluenceTableHeader term=bold cterm=bold gui=bold

ConfluenceHiLink confluenceDelimiter     Type
ConfluenceHiLink confluenceSeparator     Type

ConfluenceHiLink confluenceEmoticons     Special
ConfluenceHiLink confluenceSymbols       Special

" Images
ConfluenceHiLink confluenceImageParameterName  Type
ConfluenceHiLink confluenceImageParameterValue Constant
ConfluenceHiLink confluenceImageLink           Underlined
ConfluenceHiLink confluenceImage               PreProc

" Links
ConfluenceHiLink   confluenceLinkMarker Type
ConfluenceHiLink   confluenceLinkStart  Type
ConfluenceHiLink   confluenceLinkEnd    Type
ConfluenceHiLink   confluenceLink       Underlined
ConfluenceHiLink   confluenceLinkLabel  Identifier
ConfluenceHiLink   confluenceLinkTip    NonText

" Emphasis
ConfluenceHiLink   confluenceFixed      Constant
ConfluenceSynColor confluenceBold       term=bold cterm=bold gui=bold
ConfluenceSynColor confluenceItalic     term=italic cterm=italic gui=italic
ConfluenceHiLink   confluenceCitation   String
ConfluenceHiLink   confluenceStrike     Special
ConfluenceSynColor confluenceUnderlined term=underline cterm=underline gui=underline
ConfluenceHiLink   confluenceSuperscript Special
ConfluenceHiLink   confluenceSubscript  Special

"============================================================================}" Clean Up:    {{{1
"============================================================================

delcommand ConfluenceHiLink
delcommand ConfluenceSynColor

if main_syntax == 'confluencewiki'
  unlet main_syntax
endif

let b:current_syntax = "confluencewiki"

" vim:fdm=marker
