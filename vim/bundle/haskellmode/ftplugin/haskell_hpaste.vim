" rudimentary hpaste support for vim
" (using netrw for reading, wget for posting/annotating)
"
" claus reinke, last modified: 07/04/2009
"
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim

" unless wget is in your PATH, you need to set g:wget
" before loading this script. windows users are out of 
" luck, unless they have wget installed (such as the 
" cygwin one looked for here), or adapt this script to 
" whatever alternative they have at hand (perhaps using 
" vim's perl/python bindings?)
if !exists("g:wget")
  if executable("wget")
    let g:wget = "!wget -q"
  else
    let g:wget = "!c:\\cygwin\\bin\\wget -q"
  endif
endif

" read (recent) hpaste files
" show index in new buffer, where ,r will open current entry
" and ,p will annotate current entry with current buffer
command! HpasteIndex call HpasteIndex()
function! HpasteIndex()
  new
  read http://hpaste.org
  %s/\_$\_.//g
  %s/<tr[^>]*>//g
  %s/<\/tr>/
/g
  g/<\/table>/d
  g/DOCTYPE/d
  %s/<td>\([^<]*\)<\/td><td><a href="\/fastcgi\/hpaste\.fcgi\/view?id=\([0-9]*\)">\([^<]*\)<\/a><\/td><td>\([^<]*\)<\/td><td>\([^<]*\)<\/td><td>\([^<]*\)<\/td>/\2 [\1] "\3" \4 \5 \6/
  map <buffer> ,r 0yE:noh<cr>:call HpasteEditEntry('"')<cr>
endfunction

" load an existing entry for editing
command! -nargs=1 HpasteEditEntry call HpasteEditEntry(<f-args>)
function! HpasteEditEntry(entry)
  new
  exe 'Nread http://hpaste.org/fastcgi/hpaste.fcgi/raw?id='.a:entry
  "exe 'map <buffer> ,p :call HpasteAnnotate('''.a:entry.''')<cr>'
endfunction

" " posting temporarily disabled -- needs someone to look into new
" " hpaste.org structure

" " annotate existing entry (only to be called via ,p in HpasteIndex)
" function! HpasteAnnotate(entry)
"   let nick  = input("nick? ")
"   let title = input("title? ")
"   if nick=='' || title==''
"     echo "nick or title missing. aborting annotation"
"     return
"   endif
"   call HpastePost('annotate/'.a:entry,nick,title)
" endfunction
" 
" " post new hpaste entry
" " using 'wget --post-data' and url-encoded content
" command! HpastePostNew  call HpastePost('new',<args>)
" function! HpastePost(mode,nick,title,...)
"   let lines = getbufline("%",1,"$") 
"   let pat   = '\([^[:alnum:]]\)'
"   let code  = '\=printf("%%%02X",char2nr(submatch(1)))'
"   let lines = map(lines,'substitute(v:val."\r\n",'''.pat.''','''.code.''',''g'')')
" 
"   let url   = 'http://hpaste.org/' . a:mode 
"   let nick  = substitute(a:nick,pat,code,'g')
"   let title = substitute(a:title,pat,code,'g')
"   if a:0==0
"     let announce = 'false'
"   else
"     let announce = a:1
"   endif
"   let cmd = g:wget.' --post-data="content='.join(lines,'').'&nick='.nick.'&title='.title.'&announce='.announce.'" '.url
"   exe escape(cmd,'%')