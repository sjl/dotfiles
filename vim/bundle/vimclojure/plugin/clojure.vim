" Vim filetype plugin file
" Language:     Clojure
" Maintainer:   Meikel Brandmeyer <mb@kotka.de>

" Only do this when not done yet for this buffer
if exists("clojure_loaded")
	finish
endif

let clojure_loaded = "2.2.0-SNAPSHOT"

let s:cpo_save = &cpo
set cpo&vim

command! -nargs=0 ClojureRepl call vimclojure#StartRepl()

call vimclojure#MakeProtectedPlug("n", "AddToLispWords", "vimclojure#AddToLispWords", "expand(\"<cword>\")")

call vimclojure#MakeProtectedPlug("n", "DocLookupWord", "vimclojure#DocLookup", "expand(\"<cword>\")")
call vimclojure#MakeProtectedPlug("n", "DocLookupInteractive", "vimclojure#DocLookup", "input(\"Symbol to look up: \")")
call vimclojure#MakeProtectedPlug("n", "JavadocLookupWord", "vimclojure#JavadocLookup", "expand(\"<cword>\")")
call vimclojure#MakeProtectedPlug("n", "JavadocLookupInteractive", "vimclojure#JavadocLookup", "input(\"Class to lookup: \")")
call vimclojure#MakeProtectedPlug("n", "FindDoc", "vimclojure#FindDoc", "")

call vimclojure#MakeProtectedPlug("n", "MetaLookupWord", "vimclojure#MetaLookup", "expand(\"<cword>\")")
call vimclojure#MakeProtectedPlug("n", "MetaLookupInteractive", "vimclojure#MetaLookup", "input(\"Symbol to look up: \")")

call vimclojure#MakeProtectedPlug("n", "SourceLookupWord", "vimclojure#SourceLookup", "expand(\"<cword>\")")
call vimclojure#MakeProtectedPlug("n", "SourceLookupInteractive", "vimclojure#SourceLookup", "input(\"Symbol to look up: \")")

call vimclojure#MakeProtectedPlug("n", "GotoSourceWord", "vimclojure#GotoSource", "expand(\"<cword>\")")
call vimclojure#MakeProtectedPlug("n", "GotoSourceInteractive", "vimclojure#GotoSource", "input(\"Symbol to go to: \")")

call vimclojure#MakeProtectedPlug("n", "RequireFile", "vimclojure#RequireFile", "0")
call vimclojure#MakeProtectedPlug("n", "RequireFileAll", "vimclojure#RequireFile", "1")

call vimclojure#MakeProtectedPlug("n", "RunTests", "vimclojure#RunTests", "0")

call vimclojure#MakeProtectedPlug("n", "MacroExpand",  "vimclojure#MacroExpand", "0")
call vimclojure#MakeProtectedPlug("n", "MacroExpand1", "vimclojure#MacroExpand", "1")

call vimclojure#MakeProtectedPlug("n", "EvalFile",      "vimclojure#EvalFile", "")
call vimclojure#MakeProtectedPlug("n", "EvalLine",      "vimclojure#EvalLine", "")
call vimclojure#MakeProtectedPlug("v", "EvalBlock",     "vimclojure#EvalBlock", "")
call vimclojure#MakeProtectedPlug("n", "EvalToplevel",  "vimclojure#EvalToplevel", "")
call vimclojure#MakeProtectedPlug("n", "EvalParagraph", "vimclojure#EvalParagraph", "")

call vimclojure#MakeProtectedPlug("n", "StartRepl", "vimclojure#StartRepl", "")
call vimclojure#MakeProtectedPlug("n", "StartLocalRepl", "vimclojure#StartRepl", "b:vimclojure_namespace")

inoremap <Plug>ClojureReplEnterHook <Esc>:call b:vimclojure_repl.enterHook()<CR>
inoremap <Plug>ClojureReplUpHistory <C-O>:call b:vimclojure_repl.upHistory()<CR>
inoremap <Plug>ClojureReplDownHistory <C-O>:call b:vimclojure_repl.downHistory()<CR>

nnoremap <Plug>ClojureCloseResultBuffer :call vimclojure#ResultBuffer.CloseBuffer()<CR>

let &cpo = s:cpo_save
