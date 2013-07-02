" These are all out here in the middle of goddamned nowhere because Fireplace is
" an asshole and won't let you disable mappings like any other plugin.

augroup unmap_fireplace_bullshit
    au!

    au Filetype clojure nunmap <buffer> cp
    au Filetype clojure nunmap <buffer> cpp

    au Filetype clojure nunmap <buffer> c!
    au Filetype clojure nunmap <buffer> c!!

    au Filetype clojure nunmap <buffer> cq
    au Filetype clojure nunmap <buffer> cqq

    au Filetype clojure nunmap <buffer> cqp
    au Filetype clojure nunmap <buffer> cqc

    au Filetype clojure nunmap <buffer> cpr

    au Filetype clojure nunmap <buffer> K
    au Filetype clojure nunmap <buffer> [d
    au Filetype clojure nunmap <buffer> ]d

    au Filetype clojure nunmap <buffer> [<c-d>
    au Filetype clojure nunmap <buffer> ]<c-d>

    au Filetype clojure nunmap <buffer> <c-w><c-d>
    au Filetype clojure nunmap <buffer> <c-w>d
    au Filetype clojure nunmap <buffer> <c-w>gd
augroup END

augroup map_good_fireplace_keys
    au!

    " [M]an (get documentation)
    au Filetype clojure nmap <buffer> M <Plug>FireplaceK

    " Go to Definition
    au Filetype clojure nmap <buffer> gd <Plug>FireplaceDjump

    " Require
    au Filetype clojure nnoremap <buffer> <localleader>r :Require<cr>

    " Require Harder
    au Filetype clojure nnoremap <buffer> <localleader>R :Require!<cr>

    " Get [S]ource
    au Filetype clojure nmap <buffer> <localleader>s <Plug>FireplaceSource

    " Eval Form
    " au Filetype clojure nmap <buffer> <localleader>ef

    " Eval Top-Level Form
    " au Filetype clojure nmap <buffer> <localleader>ee

    " Open clojure command line editor client thing
    " au Filetype clojure nmap <buffer> <localleader>E
augroup END
