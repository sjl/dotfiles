"============================================================================
"Compiler:    Clojure (cake test)
"Maintainer:  Steve Losh <steve@stevelosh.com>
"License:     MIT/X11
"============================================================================

" if exists("current_compiler")
"   finish
" endif
let current_compiler = "clojure"

let s:cpo_save = &cpo
set cpo-=C"endif

let &l:makeprg=fnameescape(globpath(&runtimepath, 'compiler/cake-test-wrapper.py'))

setlocal errorformat=%f:%l:%m

let &cpo = s:cpo_save
unlet s:cpo_save
