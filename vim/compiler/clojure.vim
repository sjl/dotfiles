"============================================================================
"Compiler:    Clojure (cake test)
"Maintainer:  Steve Losh <steve@stevelosh.com>
"License:     MIT/X11
"============================================================================

if exists("current_compiler")
  finish
endif
let current_compiler = "clojure"

let s:cpo_save = &cpo
set cpo-=C"endif


setlocal makeprg=\(echo\ DIR:\ `pwd`/test/`ls\ test`/test\ &&\ cake\ test\)

setlocal errorformat=
            \%-DDIR:\ %f,
            \%E%tAIL\ in\ %m\ (%f:%l),
            \%C%m,
            \%Z%^%$,
            \%-G%>Ran\ %.%#\ tests\ containing\ %.%#\ assertions.,
            \%-G%.%#,


let &cpo = s:cpo_save
unlet s:cpo_save
