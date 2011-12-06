"
" utility functions for haskellmode plugins
"
" (Claus Reinke; last modified: 22/06/2010)
" 
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim
" please send patches to <claus.reinke@talk21.com>



" find start/extent of name/symbol under cursor;
" return start, symbolic flag, qualifier, unqualified id
" (this is used in both haskell_doc.vim and in GHC.vim)
function! haskellmode#GetNameSymbol(line,col,off)
  let name    = "[a-zA-Z0-9_']"
  let symbol  = "[-!#$%&\*\+/<=>\?@\\^|~:.]"
  "let [line]  = getbufline(a:buf,a:lnum)
  let line    = a:line

  " find the beginning of unqualified id or qualified id component 
  let start   = (a:col - 1) + a:off
  if line[start] =~ name
    let pattern = name
  elseif line[start] =~ symbol
    let pattern = symbol
  else
    return []
  endif
  while start > 0 && line[start - 1] =~ pattern
    let start -= 1
  endwhile
  let id    = matchstr(line[start :],pattern.'*')
  " call confirm(id)

  " expand id to left and right, to get full id
  let idPos = id[0] == '.' ? start+2 : start+1
  let posA  = match(line,'\<\(\([A-Z]'.name.'*\.\)\+\)\%'.idPos.'c')
  let start = posA>-1 ? posA+1 : idPos
  let posB  = matchend(line,'\%'.idPos.'c\(\([A-Z]'.name.'*\.\)*\)\('.name.'\+\|'.symbol.'\+\)')
  let end   = posB>-1 ? posB : idPos

  " special case: symbolic ids starting with .
  if id[0]=='.' && posA==-1 
    let start = idPos-1
    let end   = posB==-1 ? start : end
  endif

  " classify full id and split into qualifier and unqualified id
  let fullid   = line[ (start>1 ? start-1 : 0) : (end-1) ]
  let symbolic = fullid[-1:-1] =~ symbol  " might also be incomplete qualified id ending in .
  let qualPos  = matchend(fullid, '\([A-Z]'.name.'*\.\)\+')
  let qualifier = qualPos>-1 ? fullid[ 0 : (qualPos-2) ] : ''
  let unqualId  = qualPos>-1 ? fullid[ qualPos : -1 ] : fullid
  " call confirm(start.'/'.end.'['.symbolic.']:'.qualifier.' '.unqualId)

  return [start,symbolic,qualifier,unqualId]
endfunction

function! haskellmode#GatherImports()
  let imports={0:{},1:{}}
  let i=1
  while i<=line('$')
    let res = haskellmode#GatherImport(i)
    if !empty(res)
      let [i,import] = res
      let prefixPat = '^import\s*\%({-#\s*SOURCE\s*#-}\)\?\(qualified\)\?\s\+'
      let modulePat = '\([A-Z][a-zA-Z0-9_''.]*\)'
      let asPat     = '\(\s\+as\s\+'.modulePat.'\)\?'
      let hidingPat = '\(\s\+hiding\s*\((.*)\)\)\?'
      let listPat   = '\(\s*\((.*)\)\)\?'
      let importPat = prefixPat.modulePat.asPat.hidingPat.listPat ".'\s*$'

      let ml = matchlist(import,importPat)
      if ml!=[]
        let [_,qualified,module,_,as,_,hiding,_,explicit;x] = ml
        let what = as=='' ? module : as
        let hidings   = split(hiding[1:-2],',')
        let explicits = split(explicit[1:-2],',')
        let empty = {'lines':[],'hiding':hidings,'explicit':[],'modules':[]}
        let entry = has_key(imports[1],what) ? imports[1][what] : deepcopy(empty)
        let imports[1][what] = haskellmode#MergeImport(deepcopy(entry),i,hidings,explicits,module)
        if !(qualified=='qualified')
          let imports[0][what] = haskellmode#MergeImport(deepcopy(entry),i,hidings,explicits,module)
        endif
      else
        echoerr "haskellmode#GatherImports doesn't understand: ".import
      endif
    endif
    let i+=1
  endwhile
  if !has_key(imports[1],'Prelude') 
    let imports[0]['Prelude'] = {'lines':[],'hiding':[],'explicit':[],'modules':[]}
    let imports[1]['Prelude'] = {'lines':[],'hiding':[],'explicit':[],'modules':[]}
  endif
  return imports
endfunction

function! haskellmode#ListElem(list,elem)
  for e in a:list | if e==a:elem | return 1 | endif | endfor
  return 0
endfunction

function! haskellmode#ListIntersect(list1,list2)
  let l = []
  for e in a:list1 | if index(a:list2,e)!=-1 | let l += [e] | endif | endfor
  return l
endfunction

function! haskellmode#ListUnion(list1,list2)
  let l = []
  for e in a:list2 | if index(a:list1,e)==-1 | let l += [e] | endif | endfor
  return a:list1 + l
endfunction

function! haskellmode#ListWithout(list1,list2)
  let l = []
  for e in a:list1 | if index(a:list2,e)==-1 | let l += [e] | endif | endfor
  return l
endfunction

function! haskellmode#MergeImport(entry,line,hiding,explicit,module)
  let lines    = a:entry['lines'] + [ a:line ]
  let hiding   = a:explicit==[] ? haskellmode#ListIntersect(a:entry['hiding'], a:hiding) 
                              \ : haskellmode#ListWithout(a:entry['hiding'],a:explicit)
  let explicit = haskellmode#ListUnion(a:entry['explicit'], a:explicit)
  let modules  = haskellmode#ListUnion(a:entry['modules'], [ a:module ])
  return {'lines':lines,'hiding':hiding,'explicit':explicit,'modules':modules}
endfunction

" collect lines belonging to a single import statement;
" return number of last line and collected import statement
" (assume opening parenthesis, if any, is on the first line)
function! haskellmode#GatherImport(lineno)
  let lineno = a:lineno
  let import = getline(lineno)
  if !(import=~'^import\s') | return [] | endif
  let open  = strlen(substitute(import,'[^(]','','g'))
  let close = strlen(substitute(import,'[^)]','','g'))
  while open!=close
    let lineno += 1
    let linecont = getline(lineno)
    let open  += strlen(substitute(linecont,'[^(]','','g'))
    let close += strlen(substitute(linecont,'[^)]','','g'))
    let import .= linecont
  endwhile
  return [lineno,import]
endfunction

function! haskellmode#UrlEncode(string)
  let pat  = '\([^[:alnum:]]\)'
  let code = '\=printf("%%%02X",char2nr(submatch(1)))'
  let url  = substitute(a:string,pat,code,'g')
  return url
endfunction

" TODO: we could have buffer-local settings, at the expense of
"       reconfiguring for every new buffer.. do we want to?
function! haskellmode#GHC()
  if (!exists("g:ghc") || !executable(g:ghc)) 
    if !executable('ghc') 
      echoerr s:scriptname.": can't find ghc. please set g:ghc, or extend $PATH"
      return 0
    else
      let g:ghc = 'ghc'
    endif
  endif    
  return 1
endfunction

function! haskellmode#GHC_Version()
  if !exists("g:ghc_version")
    let g:ghc_version = substitute(system(g:ghc . ' --numeric-version'),'\n','','')
  endif
  return g:ghc_version
endfunction

function! haskellmode#GHC_VersionGE(target)
  let current = split(haskellmode#GHC_Version(), '\.' )
  let target  = a:target
  for i in current
    if ((target==[]) || (i>target[0]))
      return 1
    elseif (i==target[0])
      let target = target[1:]
    else
      return 0
    endif
  endfor
  return 1
endfunction
