"
" use haddock docs and index files
" show documentation, complete & qualify identifiers 
"
" (Claus Reinke; last modified: 17/06/2009)
" 
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim
" please send patches to <claus.reinke@talk21.com>

" :Doc <name> and :IDoc <name> open haddocks for <name> in opera
"
"   :Doc needs qualified name (default Prelude) and package (default base)
"   :IDoc needs unqualified name, looks up possible links in g:haddock_index
"
"   :DocIndex populates g:haddock_index from haddock's index files
"   :ExportDocIndex saves g:haddock_index to cache file
"   :ImportDocIndex reloads g:haddock_index from cache file
"
" all the following use the haddock index (g:haddock_index)
"
" _? opens haddocks for unqualified name under cursor, 
"    suggesting alternative full qualifications in popup menu
"
" _. fully qualifies unqualified name under cursor,
"    suggesting alternative full qualifications in popup menu
"
" _i  add import <module>(<name>) statement for unqualified <name> under cursor,
" _im add import <module>         statement for unqualified <name> under cursor,
"    suggesting alternative full qualifications in popup menu
"    (this currently adds one statement per call, instead of
"     merging into existing import statements, but it's a start;-)
"
" CTRL-X CTRL-U (user-defined insert mode completion) 
"   suggests completions of unqualified names in popup menu

let s:scriptname = "haskell_doc.vim"

" script parameters
"   g:haddock_browser            *mandatory* which browser to call
"   g:haddock_browser_callformat [optional] how to call browser
"   g:haddock_indexfiledir       [optional] where to put 'haddock_index.vim'
"   g:haddock_docdir             [optional] where to find html docs
"   g:ghc                        [optional] which ghc to call
"   g:ghc_pkg                    [optional] which ghc_pkg to call

" been here before?
if exists("g:haddock_index")
  finish
endif

" initialise nested dictionary, to be populated 
" - from haddock index files via :DocIndex
" - from previous cached version via :ImportDocIndex
let g:haddock_index = {}

" initialise dictionary, mapping modules with haddocks to their packages,
" populated via MkHaddockModuleIndex() or HaveModuleIndex()
let g:haddock_moduleindex = {}

" program to open urls, please set this in your vimrc
  "examples (for windows):
  "let g:haddock_browser = "C:/Program Files/Opera/Opera.exe"
  "let g:haddock_browser = "C:/Program Files/Mozilla Firefox/firefox.exe"
  "let g:haddock_browser = "C:/Program Files/Internet Explorer/IEXPLORE.exe"
if !exists("g:haddock_browser")
  echoerr s:scriptname." WARNING: please set g:haddock_browser!"
endif

if !haskellmode#GHC() | finish | endif

if (!exists("g:ghc_pkg") || !executable(g:ghc_pkg))
  let g:ghc_pkg = substitute(g:ghc,'\(.*\)ghc','\1ghc-pkg','')
endif

if exists("g:haddock_docdir") && isdirectory(g:haddock_docdir)
  let s:docdir = g:haddock_docdir
elseif executable(g:ghc_pkg)
" try to figure out location of html docs
" first choice: where the base docs are (from the first base listed)
  let [field;x] = split(system(g:ghc_pkg . ' field base haddock-html'),'\n')
  " path changes in ghc-6.12.*
  " let field = substitute(field,'haddock-html: \(.*\)libraries.base','\1','')
  let field = substitute(field,'haddock-html: \(.*\)lib\(raries\)\?.base.*$','\1','')
  let field = substitute(field,'\\','/','g')
  " let alternate = substitute(field,'html','doc/html','')
  " changes for ghc-6.12.*: check for doc/html/ first
  let alternate = field.'doc/html/'
  if isdirectory(alternate)
    let s:docdir = alternate
  elseif isdirectory(field)
    let s:docdir = field
  endif
else
  echoerr s:scriptname." can't find ghc-pkg (set g:ghc_pkg ?)."
endif

" second choice: try some known suspects for windows/unix
if !exists('s:docdir') || !isdirectory(s:docdir)
  let s:ghc_libdir = substitute(system(g:ghc . ' --print-libdir'),'\n','','')
  let location1a = s:ghc_libdir . '/doc/html/'
  let location1b = s:ghc_libdir . '/doc/'
  let location2 = '/usr/share/doc/ghc-' . haskellmode#GHC_Version() . '/html/' 
  if isdirectory(location1a)
    let s:docdir = location1a
  elseif isdirectory(location1b)
    let s:docdir = location1b
  elseif isdirectory(location2)
    let s:docdir = location2
  else " give up
    echoerr s:scriptname." can't find locaton of html documentation (set g:haddock_docdir)."
    finish
  endif
endif

" todo: can we turn s:docdir into a list of paths, and
" include docs for third-party libs as well?

let s:libraries         = s:docdir . 'libraries/'
let s:guide             = s:docdir . 'users_guide/'
let s:index             = 'index.html'
if exists("g:haddock_indexfiledir") && filewritable(g:haddock_indexfiledir)
  let s:haddock_indexfiledir = g:haddock_indexfiledir 
elseif filewritable(s:libraries)
  let s:haddock_indexfiledir = s:libraries
elseif filewritable($HOME)
  let s:haddock_indexfiledir = $HOME.'/'
else "give up
  echoerr s:scriptname." can't locate index file. please set g:haddock_indexfiledir"
  finish
endif
let s:haddock_indexfile = s:haddock_indexfiledir . 'haddock_index.vim'

" different browser setups require different call formats;
" you might want to call the browser synchronously or 
" asynchronously, and the latter is os-dependent;
"
" by default, the browser is started in the background when on 
" windows or if running in a gui, and in the foreground otherwise
" (eg, console-mode for remote sessions, with text-mode browsers).
"
" you can override these defaults in your vimrc, via a format 
" string including 2 %s parameters (the first being the browser 
" to call, the second being the url).
if !exists("g:haddock_browser_callformat")
  if has("win32") || has("win64")
    let g:haddock_browser_callformat = 'start %s "%s"'
  else
    if has("gui_running")
      let g:haddock_browser_callformat = '%s %s '.printf(&shellredir,'/dev/null').' &'
    else
      let g:haddock_browser_callformat = '%s %s'
    endif
  endif
endif

" allow map leader override
if !exists("maplocalleader")
  let maplocalleader='_'
endif

command! DocSettings call DocSettings()
function! DocSettings()
  for v in ["g:haddock_browser","g:haddock_browser_callformat","g:haddock_docdir","g:haddock_indexfiledir","s:ghc_libdir","g:ghc_version","s:docdir","s:libraries","s:guide","s:haddock_indexfile"]
    if exists(v)
      echo v '=' eval(v)
    else
      echo v '='
    endif
  endfor
endfunction

function! DocBrowser(url)
  "echomsg "DocBrowser(".url.")"
  if (!exists("g:haddock_browser") || !executable(g:haddock_browser))
    echoerr s:scriptname." can't find documentation browser. please set g:haddock_browser"
    return
  endif
  " start browser to open url, according to specified format
  let url = a:url=~'^\(file://\|http://\)' ? a:url : 'file://'.a:url
  silent exe '!'.printf(g:haddock_browser_callformat,g:haddock_browser,escape(url,'#%')) 
endfunction

"Doc/Doct are an old interface for documentation lookup
"(that is the reason they are not documented!-)
"
"These uses are still fine at the moment, and are the reason 
"that this command still exists at all
"
" :Doc -top
" :Doc -libs
" :Doc -guide
"
"These uses may or may not work, and shouldn't be relied on anymore
"(usually, you want _?/_?1/_?2 or :MDoc; there is also :IDoc)
"
" :Doc length
" :Doc Control.Monad.when
" :Doc Data.List.
" :Doc Control.Monad.State.runState mtl
command! -nargs=+ Doc  call Doc('v',<f-args>)
command! -nargs=+ Doct call Doc('t',<f-args>)

function! Doc(kind,qualname,...) 
  let suffix   = '.html'
  let relative = '#'.a:kind.'%3A'

  if a:qualname=="-top"
    call DocBrowser(s:docdir . s:index)
    return
  elseif a:qualname=="-libs"
    call DocBrowser(s:libraries . s:index)
    return
  elseif a:qualname=="-guide"
    call DocBrowser(s:guide . s:index)
    return
  endif

  if a:0==0 " no package specified
    let package = 'base/'
  else
    let package = a:1 . '/'
  endif

  if match(a:qualname,'\.')==-1 " unqualified name
    let [qual,name] = [['Prelude'],a:qualname]
    let file = join(qual,'-') . suffix . relative . name
  elseif a:qualname[-1:]=='.' " module qualifier only
    let parts = split(a:qualname,'\.')
    let quallen = len(parts)-1
    let [qual,name] = [parts[0:quallen],parts[-1]]
    let file = join(qual,'-') . suffix
  else " qualified name
    let parts = split(a:qualname,'\.')
    let quallen = len(parts)-2
    let [qual,name] = [parts[0:quallen],parts[-1]]
    let file = join(qual,'-') . suffix . relative . name
  endif

  let path = s:libraries . package . file
  call DocBrowser(path)
endfunction

" TODO: add commandline completion for :IDoc
"       switch to :emenu instead of inputlist?
" indexed variant of Doc, looking up links in g:haddock_index
" usage:
"  1. :IDoc length
"  2. click on one of the choices, or select by number (starting from 0)
command! -nargs=+ IDoc call IDoc(<f-args>)
function! IDoc(name,...) 
  let choices = HaddockIndexLookup(a:name)
  if choices=={} | return | endif
  if a:0==0
    let keylist = map(deepcopy(keys(choices)),'substitute(v:val,"\\[.\\]","","")')
    let choice = inputlist(keylist)
  else
    let choice = a:1
  endif
  let path = values(choices)[choice] " assumes same order for keys/values..
  call DocBrowser(path)
endfunction

let s:flagref = s:guide . 'flag-reference.html'
if filereadable(s:flagref)
  " extract the generated fragment ids for the 
  " flag reference sections 
  let s:headerPat     = '.\{-}<h3 class="title"><a name="\([^"]*\)"><\/a>\([^<]*\)<\/h3>\(.*\)'
  let s:flagheaders   = []
  let s:flagheaderids = {}
  let s:contents      = join(readfile(s:flagref))
  let s:ml = matchlist(s:contents,s:headerPat)
  while s:ml!=[]
    let [_,s:id,s:title,s:r;s:x] = s:ml
    let s:flagheaders            = add(s:flagheaders, s:title)
    let s:flagheaderids[s:title] = s:id
    let s:ml = matchlist(s:r,s:headerPat)
  endwhile
  command! -nargs=1 -complete=customlist,CompleteFlagHeaders FlagReference call FlagReference(<f-args>)
  function! FlagReference(section)
    let relativeUrl = a:section==""||!exists("s:flagheaderids['".a:section."']") ? 
                    \ "" : "#".s:flagheaderids[a:section]
    call DocBrowser(s:flagref.relativeUrl)
  endfunction
  function! CompleteFlagHeaders(al,cl,cp)
    let s:choices = s:flagheaders
    return CompleteAux(a:al,a:cl,a:cp)
  endfunction
endif

command! -nargs=1 -complete=customlist,CompleteHaddockModules MDoc call MDoc(<f-args>)
function! MDoc(module)
  let suffix   = '.html'
  call HaveModuleIndex()
  if !has_key(g:haddock_moduleindex,a:module)
    echoerr a:module 'not found in haddock module index'
    return
  endif
  let package = g:haddock_moduleindex[a:module]['package']
  let file    = substitute(a:module,'\.','-','g') . suffix
" let path    = s:libraries . package . '/' . file
  let path    = g:haddock_moduleindex[a:module]['html']
  call DocBrowser(path)
endfunction

function! CompleteHaddockModules(al,cl,cp)
  call HaveModuleIndex()
  let s:choices = keys(g:haddock_moduleindex)
  return CompleteAux(a:al,a:cl,a:cp)
endfunction

" create a dictionary g:haddock_index, containing the haddoc index
command! DocIndex call DocIndex()
function! DocIndex()
  let files   = split(globpath(s:libraries,'doc-index*.html'),'\n')
  let g:haddock_index = {}
  if haskellmode#GHC_VersionGE([7,0,0])
    call ProcessHaddockIndexes3(s:libraries,files)
  else
    call ProcessHaddockIndexes2(s:libraries,files)
  endif
  if haskellmode#GHC_VersionGE([6,8,2])
    if &shell =~ 'sh' " unix-type shell
      let s:addon_libraries = split(system(g:ghc_pkg . ' field \* haddock-html'),'\n')
    else " windows cmd.exe and the like
      let s:addon_libraries = split(system(g:ghc_pkg . ' field * haddock-html'),'\n')
    endif
    for addon in s:addon_libraries
      let ml = matchlist(addon,'haddock-html: \("\)\?\(file:///\)\?\([^"]*\)\("\)\?')
      if ml!=[]
        let [_,quote,file,addon_path;x] = ml
        let addon_path = substitute(addon_path,'\(\\\\\|\\\)','/','g')
        let addon_files = split(globpath(addon_path,'doc-index*.html'),'\n')
        if haskellmode#GHC_VersionGE([7,0,0])
          call ProcessHaddockIndexes3(addon_path,addon_files)
        else
          call ProcessHaddockIndexes2(addon_path,addon_files)
        endif
      endif
    endfor
  endif
  return 1
endfunction

function! ProcessHaddockIndexes(location,files)
  let entryPat= '.\{-}"indexentry"[^>]*>\([^<]*\)<\(\%([^=]\{-}TD CLASS="\%(indexentry\)\@!.\{-}</TD\)*\)[^=]\{-}\(\%(="indexentry\|TABLE\).*\)'
  let linkPat = '.\{-}HREF="\([^"]*\)".>\([^<]*\)<\(.*\)'

  redraw
  echo 'populating g:haddock_index from haddock index files in ' a:location
  for f in a:files  
    echo f[len(a:location):]
    let contents = join(readfile(f))
    let ml = matchlist(contents,entryPat)
    while ml!=[]
      let [_,entry,links,r;x] = ml
      "echo entry links
      let ml2 = matchlist(links,linkPat)
      let link = {}
      while ml2!=[]
        let [_,l,m,links;x] = ml2
        "echo l m
        let link[m] = a:location . '/' . l
        let ml2 = matchlist(links,linkPat)
      endwhile
      let g:haddock_index[DeHTML(entry)] = deepcopy(link)
      "echo entry g:haddock_index[entry]
      let ml = matchlist(r,entryPat)
    endwhile
  endfor
endfunction

" concatenating all lines is too slow for a big file, process lines directly
function! ProcessHaddockIndexes2(location,files)
  let entryPat= '^>\([^<]*\)</'
  let linkPat = '.\{-}A HREF="\([^"]*\)"'
  let kindPat = '#\(.\)'

  " redraw
  echo 'populating g:haddock_index from haddock index files in ' a:location
  for f in a:files  
    echo f[len(a:location):]
    let isEntry = 0
    let isLink  = ''
    let link    = {}
    let entry   = ''
    for line in readfile(f)
      if line=~'CLASS="indexentry' 
        if (link!={}) && (entry!='')
          if has_key(g:haddock_index,DeHTML(entry))
            let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
          else
            let dict = deepcopy(link)
          endif
          let g:haddock_index[DeHTML(entry)] = dict
          let link  = {}
          let entry = ''
        endif
        let isEntry=1 
        continue 
      endif
      if isEntry==1
        let ml = matchlist(line,entryPat)
        if ml!=[] | let [_,entry;x] = ml | let isEntry=0 | continue | endif
      endif
      if entry!=''
        let ml = matchlist(line,linkPat)
        if ml!=[] | let [_,isLink;x]=ml | continue | endif
      endif
      if isLink!=''
        let ml = matchlist(line,entryPat)
        if ml!=[] 
          let [_,module;x] = ml 
          let [_,kind;x]   = matchlist(isLink,kindPat)
          let last         = a:location[strlen(a:location)-1]
          let link[module."[".kind."]"] = a:location . (last=='/'?'':'/') . isLink
          let isLink='' 
          continue 
        endif
      endif
    endfor
    if link!={} 
      if has_key(g:haddock_index,DeHTML(entry))
        let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
      else
        let dict = deepcopy(link)
      endif
      let g:haddock_index[DeHTML(entry)] = dict
    endif
  endfor
endfunction

function! ProcessHaddockIndexes3(location,files)
  let entryPat= '>\(.*\)$'
  let linkPat = '<a href="\([^"]*\)"'
  let kindPat = '#\(.\)'

  " redraw
  echo 'populating g:haddock_index from haddock index files in ' a:location
  for f in a:files  
    echo f[len(a:location):]
    let isLink  = ''
    let link    = {}
    let entry   = ''
    let lines   = split(join(readfile(f,'b')),'\ze<')
    for line in lines
      if (line=~'class="src') || (line=~'/table')
        if (link!={}) && (entry!='')
          if has_key(g:haddock_index,DeHTML(entry))
            let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
          else
            let dict = deepcopy(link)
          endif
          let g:haddock_index[DeHTML(entry)] = dict
          let link  = {}
          let entry = ''
        endif
        let ml = matchlist(line,entryPat)
        if ml!=[] | let [_,entry;x] = ml | continue | endif
        continue 
      endif
      if entry!=''
        let ml = matchlist(line,linkPat)
        if ml!=[] 
          let [_,isLink;x]=ml
          let ml = matchlist(line,entryPat)
          if ml!=[] 
            let [_,module;x] = ml 
            let [_,kind;x]   = matchlist(isLink,kindPat)
            let last         = a:location[strlen(a:location)-1]
            let link[module."[".kind."]"] = a:location . (last=='/'?'':'/') . isLink
            let isLink='' 
          endif
          continue
        endif
      endif
    endfor
    if link!={} 
      if has_key(g:haddock_index,DeHTML(entry))
        let dict = extend(g:haddock_index[DeHTML(entry)],deepcopy(link))
      else
        let dict = deepcopy(link)
      endif
      let g:haddock_index[DeHTML(entry)] = dict
    endif
  endfor
endfunction


command! ExportDocIndex call ExportDocIndex()
function! ExportDocIndex()
  call HaveIndex()
  let entries = []
  for key in keys(g:haddock_index)
    let entries += [key,string(g:haddock_index[key])]
  endfor
  call writefile(entries,s:haddock_indexfile)
  redir end
endfunction

command! ImportDocIndex call ImportDocIndex()
function! ImportDocIndex()
  if filereadable(s:haddock_indexfile)
    let lines = readfile(s:haddock_indexfile)
    let i=0
    while i<len(lines)
      let [key,dict] = [lines[i],lines[i+1]]
      sandbox let g:haddock_index[key] = eval(dict) 
      let i+=2
    endwhile
    return 1
  else
    return 0
  endif
endfunction

function! HaveIndex()
  return (g:haddock_index!={} || ImportDocIndex() || DocIndex() )
endfunction

function! MkHaddockModuleIndex()
  let g:haddock_moduleindex = {}
  call HaveIndex()
  for key in keys(g:haddock_index)
    let dict = g:haddock_index[key]
    for module in keys(dict)
      let html = dict[module]
      let html   = substitute(html  ,'#.*$','','')
      let module = substitute(module,'\[.\]','','')
      let ml = matchlist(html,'libraries/\([^\/]*\)[\/]')
      if ml!=[]
        let [_,package;x] = ml
        let g:haddock_moduleindex[module] = {'package':package,'html':html}
      endif
      let ml = matchlist(html,'/\([^\/]*\)\/html/[A-Z]')
      if ml!=[]
        let [_,package;x] = ml
        let g:haddock_moduleindex[module] = {'package':package,'html':html}
      endif
    endfor
  endfor
endfunction

function! HaveModuleIndex()
  return (g:haddock_moduleindex!={} || MkHaddockModuleIndex() )
endfunction

" decode HTML symbol encodings (are these all we need?)
function! DeHTML(entry)
  let res = a:entry
  let decode = { '&lt;': '<', '&gt;': '>', '&amp;': '\\&' }
  for enc in keys(decode)
    exe 'let res = substitute(res,"'.enc.'","'.decode[enc].'","g")'
  endfor
  return res
endfunction

" find haddocks for word under cursor
" also lists possible definition sites
" - needs to work for both qualified and unqualified items
" - for 'import qualified M as A', consider M.item as source of A.item
" - offer sources from both type [t] and value [v] namespaces
" - for unqualified items, list all possible sites
" - for qualified items, list imported sites only
" keep track of keys with and without namespace tags:
" the former are needed for lookup, the latter for matching against source
map <LocalLeader>? :call Haddock()<cr>
function! Haddock()
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  let imports = haskellmode#GatherImports()
  let asm  = has_key(imports[1],qual) ? imports[1][qual]['modules'] : []
  let name = unqual
  let dict = HaddockIndexLookup(name)
  if dict=={} | return | endif
  " for qualified items, narrow results to possible imports that provide qualifier
  let filteredKeys = filter(copy(keys(dict))
                         \ ,'match(asm,substitute(v:val,''\[.\]'','''',''''))!=-1') 
  let keys = (qual!='') ?  filteredKeys : keys(dict)
  if (keys==[]) && (qual!='')
    echoerr qual.'.'.unqual.' not found in imports'
    return 0
  endif
  " use 'setlocal completeopt+=menuone' if you always want to see menus before
  " anything happens (I do, but many users don't..)
  if len(keys)==1 && (&completeopt!~'menuone')
        call DocBrowser(dict[keys[0]])
  elseif has("gui_running")
    for key in keys
      exe 'amenu ]Popup.'.escape(key,'\.').' :call DocBrowser('''.dict[key].''')<cr>'
    endfor
    popup ]Popup
  else
    let s:choices = keys
    let key = input('browse docs for '.name.' in: ','','customlist,CompleteAux')
    if key!=''
      call DocBrowser(dict[key])
    endif
  endif
endfunction

if !exists("g:haskell_search_engines")
  let g:haskell_search_engines = 
    \ {'hoogle':'http://www.haskell.org/hoogle/?hoogle=%s'
    \ ,'hayoo!':'http://holumbus.fh-wedel.de/hayoo/hayoo.html?query=%s'
    \ }
endif

map <LocalLeader>?? :let es=g:haskell_search_engines
                 \ \|echo "g:haskell_search_engines"
                 \ \|for e in keys(es)
                 \ \|echo e.' : '.es[e]
                 \ \|endfor<cr>
map <LocalLeader>?1 :call HaskellSearchEngine('hoogle')<cr>
map <LocalLeader>?2 :call HaskellSearchEngine('hayoo!')<cr>

" query one of the Haskell search engines for the thing under cursor
" - unqualified symbols need to be url-escaped
" - qualified ids need to be fed as separate qualifier and id for
"   both hoogle (doesn't handle qualified symbols) and hayoo! (no qualified
"   ids at all)
" - qualified ids referring to import-qualified-as qualifiers need to be
"   translated to the multi-module searches over the list of original modules
function! HaskellSearchEngine(engine)
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  let imports = haskellmode#GatherImports()
  let asm  = has_key(imports[1],qual) ? imports[1][qual]['modules'] : []
  let unqual = haskellmode#UrlEncode(unqual)
  if a:engine=='hoogle'
    let name = asm!=[] ? unqual.'+'.join(map(copy(asm),'"%2B".v:val'),'+')
           \ : qual!='' ? unqual.'+'.haskellmode#UrlEncode('+').qual
           \ : unqual
  elseif a:engine=='hayoo!'
    let name = asm!=[] ? unqual.'+module:('.join(copy(asm),' OR ').')'
           \ : qual!='' ? unqual.'+module:'.qual
           \ : unqual
  else
    let name = qual=="" ? unqual : qual.".".unqual
  endif
  if has_key(g:haskell_search_engines,a:engine)
    call DocBrowser(printf(g:haskell_search_engines[a:engine],name))
  else
    echoerr "unknown search engine: ".a:engine
  endif
endfunction

" used to pass on choices to CompleteAux
let s:choices=[]

" if there's no gui, use commandline completion instead of :popup
" completion function CompleteAux suggests completions for a:al, wrt to s:choices
function! CompleteAux(al,cl,cp)
  "echomsg '|'.a:al.'|'.a:cl.'|'.a:cp.'|'
  let res = []
  let l = len(a:al)-1
  for r in s:choices
    if l==-1 || r[0 : l]==a:al
      let res += [r]
    endif
  endfor
  return res
endfunction

" CamelCase shorthand matching: 
" favour upper-case letters and module qualifier separators (.) for disambiguation
function! CamelCase(shorthand,string)
  let s1 = a:shorthand
  let s2 = a:string
  let notFirst = 0 " don't elide before first pattern letter
  while ((s1!="")&&(s2!="")) 
    let head1 = s1[0]
    let head2 = s2[0]
    let elide = notFirst && ( ((head1=~'[A-Z]') && (head2!~'[A-Z.]')) 
              \             ||((head1=='.') && (head2!='.')) ) 
    if elide
      let s2=s2[1:]
    elseif (head1==head2) 
      let s1=s1[1:]
      let s2=s2[1:]
    else
      return 0
    endif
    let notFirst = (head1!='.')||(head2!='.') " treat separators as new beginnings
  endwhile
  return (s1=="")
endfunction

" use haddock name index for insert mode completion (CTRL-X CTRL-U)
function! CompleteHaddock(findstart, base)
  if a:findstart 
    let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),-1) " insert-mode: we're 1 beyond the text
    if namsym==[]
      redraw
      echo 'no name/symbol under cursor!'
      return -1
    endif
    let [start,symb,qual,unqual] = namsym
    return (start-1)
  else " find keys matching with "a:base"
    let res  = []
    let l    = len(a:base)-1
    let qual = a:base =~ '^[A-Z][a-zA-Z0-9_'']*\(\.[A-Z][a-zA-Z0-9_'']*\)*\(\.[a-zA-Z0-9_'']*\)\?$'
    call HaveIndex() 
    for key in keys(g:haddock_index)
      let keylist = map(deepcopy(keys(g:haddock_index[key])),'substitute(v:val,"\\[.\\]","","")')
      if (key[0 : l]==a:base)
        for m in keylist
          let res += [{"word":key,"menu":m,"dup":1}]
        endfor
      elseif qual " this tends to be slower
        for m in keylist
          let word = m . '.' . key
          if word[0 : l]==a:base
            let res += [{"word":word,"menu":m,"dup":1}]
          endif
        endfor
      endif
    endfor
    if res==[] " no prefix matches, try CamelCase shortcuts
      for key in keys(g:haddock_index)
        let keylist = map(deepcopy(keys(g:haddock_index[key])),'substitute(v:val,"\\[.\\]","","")')
        if CamelCase(a:base,key)
          for m in keylist
            let res += [{"word":key,"menu":m,"dup":1}]
          endfor
        elseif qual " this tends to be slower
          for m in keylist
            let word = m . '.' . key
            if CamelCase(a:base,word)
              let res += [{"word":word,"menu":m,"dup":1}]
            endif
          endfor
        endif
      endfor
    endif
    return res
  endif
endfunction
setlocal completefunc=CompleteHaddock
"
" Vim's default completeopt is menu,preview
" you probably want at least menu, or you won't see alternatives listed
" setlocal completeopt+=menu

" menuone is useful, but other haskellmode menus will try to follow your choice here in future
" setlocal completeopt+=menuone

" longest sounds useful, but doesn't seem to do what it says, and interferes with CTRL-E
" setlocal completeopt-=longest

" fully qualify an unqualified name
" TODO: - standardise commandline versions of menus
map <LocalLeader>. :call Qualify()<cr>
function! Qualify()
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  if qual!=''  " TODO: should we support re-qualification?
    redraw
    echo 'already qualified'
    return 0
  endif
  let name = unqual
  let line         = line('.')
  let prefix       = (start<=1 ? '' : getline(line)[0:start-2] )
  let dict   = HaddockIndexLookup(name)
  if dict=={} | return | endif
  let keylist = map(deepcopy(keys(dict)),'substitute(v:val,"\\[.\\]","","")')
  let imports = haskellmode#GatherImports()
  let qualifiedImports = []
  for qualifiedImport in keys(imports[1])
    let c=0
    for module in imports[1][qualifiedImport]['modules']
      if haskellmode#ListElem(keylist,module) | let c+=1 | endif
    endfor
    if c>0 | let qualifiedImports=[qualifiedImport]+qualifiedImports | endif
  endfor
  "let asm  = has_key(imports[1],qual) ? imports[1][qual]['modules'] : []
  let keylist = filter(copy(keylist),'index(qualifiedImports,v:val)==-1')
  if has("gui_running")
    " amenu ]Popup.-imported- :
    for key in qualifiedImports
      let lhs=escape(prefix.name,'/.|\')
      let rhs=escape(prefix.key.'.'.name,'/&|\')
      exe 'amenu ]Popup.'.escape(key,'\.').' :'.line.'s/'.lhs.'/'.rhs.'/<cr>:noh<cr>'
    endfor
    amenu ]Popup.-not\ imported- :
    for key in keylist
      let lhs=escape(prefix.name,'/.|\')
      let rhs=escape(prefix.key.'.'.name,'/&|\')
      exe 'amenu ]Popup.'.escape(key,'\.').' :'.line.'s/'.lhs.'/'.rhs.'/<cr>:noh<cr>'
    endfor
    popup ]Popup
  else
    let s:choices = qualifiedImports+keylist
    let key = input('qualify '.name.' with: ','','customlist,CompleteAux')
    if key!=''
      let lhs=escape(prefix.name,'/.\')
      let rhs=escape(prefix.key.'.'.name,'/&\')
      exe line.'s/'.lhs.'/'.rhs.'/'
      noh
    endif
  endif
endfunction

" create (qualified) import for a (qualified) name
" TODO: refine search patterns, to avoid misinterpretation of
"       oddities like import'Neither or not'module
map <LocalLeader>i :call Import(0,0)<cr>
map <LocalLeader>im :call Import(1,0)<cr>
map <LocalLeader>iq :call Import(0,1)<cr>
map <LocalLeader>iqm :call Import(1,1)<cr>
function! Import(module,qualified)
  amenu ]Popup.- :echo '-'<cr>
  aunmenu ]Popup
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [start,symb,qual,unqual] = namsym
  let name       = unqual
  let pname      = ( symb ? '('.name.')' : name )
  let importlist = a:module ? '' : '('.pname.')'
  let qualified  = a:qualified ? 'qualified ' : ''

  if qual!=''
    exe 'call append(search(''\%1c\(\<import\>\|\<module\>\|{-# OPTIONS\|{-# LANGUAGE\)'',''nb''),''import '.qualified.qual.importlist.''')'
    return
  endif

  let line   = line('.')
  let prefix = getline(line)[0:start-1]
  let dict   = HaddockIndexLookup(name)
  if dict=={} | return | endif
  let keylist = map(deepcopy(keys(dict)),'substitute(v:val,"\\[.\\]","","")')
  if has("gui_running")
    for key in keylist
      " exe 'amenu ]Popup.'.escape(key,'\.').' :call append(search("\\%1c\\(import\\\\|module\\\\|{-# OPTIONS\\)","nb"),"import '.key.importlist.'")<cr>'
      exe 'amenu ]Popup.'.escape(key,'\.').' :call append(search(''\%1c\(\<import\>\\|\<module\>\\|{-# OPTIONS\\|{-# LANGUAGE\)'',''nb''),''import '.qualified.key.escape(importlist,'|').''')<cr>'
    endfor
    popup ]Popup
  else
    let s:choices = keylist
    let key = input('import '.name.' from: ','','customlist,CompleteAux')
    if key!=''
      exe 'call append(search(''\%1c\(\<import\>\|\<module\>\|{-# OPTIONS\|{-# LANGUAGE\)'',''nb''),''import '.qualified.key.importlist.''')'
    endif
  endif
endfunction

function! HaddockIndexLookup(name)
  call HaveIndex()
  if !has_key(g:haddock_index,a:name)
    echoerr a:name 'not found in haddock index'
    return {}
  endif
  return g:haddock_index[a:name]
endfunction
