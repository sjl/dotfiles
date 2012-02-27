if exists('loaded_clojurefolding') || &cp
    finish
endif
let loaded_clojurefolding=1

let folded_forms = [
            \ 'def',
            \ 'defn',
            \ 'defn-',
            \ 'defprotocol',
            \ 'defparser',
            \ 'defmacro',
            \ 'defmethod',
            \ 'defmulti',
            \ 'defonce',
            \ 'defpage',
            \ 'defpartial',
            \ 'deftest',
            \ 'defroutes',
            \ 'defentity',
            \ 'defdb',
            \ 'defproject',
            \ 'defsynth',
            \ 'definst',
            \ 'ns'
            \ ]
let s:form_re      = '\v^\((' . join(folded_forms, '|') . ')\s'
let s:form_re_bare = '\v^\((' . join(folded_forms, '|') . ')$'

function! s:NextNonBlankLineContents(start)
    let lnum = a:start
    let max = line("$")

    while 1
        let lnum += 1

        " If we've run off the end of the file, return a blank string as
        " a sentinel.
        if lnum > max
            return ""
        endif

        " Otherwise, get the contents.
        let contents = getline(lnum)

        " If they're non-blank, return it.  Otherwise we'll loop to the next
        " line.
        if contents =~ '\v\S'
            return contents
        endif
    endwhile
endfunction

function! GetClojureFold()
    let line = getline(v:lnum)

    if line =~ s:form_re || line =~ s:form_re_bare
        " We're on one of the forms we want to fold.

        let nextline = s:NextNonBlankLineContents(v:lnum)

        " If we've run off the end of the file, this means we're on a top-level
        " form with no later nonblank lines in the file.  This has to be a one
        " liner, because there's no content left that could be closing parens!
        if nextline == ""
            return 0
        elseif nextline =~ '\v^\s+'
            " If it's indented, this almost certainly isn't a one-liner.  Fold
            " away!
            return ">1"
        else
            " Otherwise, the next non-blank line after this one is not
            " indented.  This means we're on a one-liner, so we don't want to
            " fold.
            return 0
        endif
    elseif line =~ '^\s*$'
        " We need to look at the next non-blank line to determine how to fold
        " blank lines.
        let nextline = s:NextNonBlankLineContents(v:lnum)

        " If we've run off the end of the file, this means we're on one of
        " a series of blank lines ending the file.  They shouldn't be folded
        " with anything.
        if nextline == ""
            return 0
        elseif nextline =~ '\v^\s+'
            " If it's indented, we're in the middle of an existing form.
            " Just fold with that.
            return "="
        else
            " Otherwise, the next non-blank line after this one is not
            " indented.  That means we need to close any existing folds
            " here.
            return "<1"
        endif
    elseif line =~ '\v^\s+\S'
        " Indented content, fold it into any existing folds.
        return "="
    else
        " We are sitting on a non-blank, non-indented line, but it's not one of
        " our special top-level forms, so we'll just leave it alone.
        return 0
    endif
endfunction

function! TurnOnClojureFolding()
    setlocal foldexpr=GetClojureFold()
    setlocal foldmethod=expr
endfunction
