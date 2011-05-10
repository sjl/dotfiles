" The django/python/htmldjango filetype situation is a gigantic clusterfuck.
"
" This file contains stuff for htmldjango files, but is named django.vim because the
" htmldjango.vim file that ships with vim sources html.vim and django.vim.
"
" Of course, using python.django for the Python files ALSO sources django.vim.
"
" Awesome.

if (&ft == "htmldjango")
    if exists("loaded_matchit")
        let b:match_ignorecase = 1
        let b:match_skip = 's:Comment'
        let b:match_words = '<:>,' .
        \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
        \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
        \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>,'  .
        \ '{% *if .*%}:{% *else *%}:{% *endif *%},' .
        \ '{% *ifequal .*%}:{% *else *%}:{% *endifequal *%},' .
        \ '{% *ifnotequal .*%}:{% *else *%}:{% *endifnotequal *%},' .
        \ '{% *ifchanged .*%}:{% *else *%}:{% *endifchanged *%},' .
        \ '{% *for .*%}:{% *endfor *%},' .
        \ '{% *with .*%}:{% *endwith *%},' .
        \ '{% *comment .*%}:{% *endcomment *%},' .
        \ '{% *block .*%}:{% *endblock *%},' .
        \ '{% *filter .*%}:{% *endfilter *%},' .
        \ '{% *spaceless .*%}:{% *endspaceless *%}'
    endif
endif
