if exists("b:current_syntax")
    finish
endif

syntax keyword alienscriptDefFunction defn

syntax keyword alienscriptDefMacro defmacro

syntax keyword alienscriptKeyword fn
" syntax keyword alienscriptKeyword do -> new object str var
" syntax keyword alienscriptKeyword array arrayInit arrayInit2d
" syntax keyword alienscriptTesting assert testGroup testRunner
" syntax keyword alienscriptTemplating template template-repeat template-repeat-key

" syntax keyword alienscriptOperator undefined? null? true? false? zero? boolean?
" syntax keyword alienscriptOperator number? string? object? array? function?
" syntax keyword alienscriptOperator = ! != > < <= >= + - * / % &&
" syntax match alienscriptOperator "\v([ \t()]|^)\zs\|\|\ze([ \t()]|$)"

syntax keyword alienscriptConstant null undefined

syntax keyword alienscriptBoolean true false

" syntax keyword alienscriptRepeat loop each each2d eachKey reduce map for

syntax keyword alienscriptConditional if

" syntax keyword alienscriptException try catch throw

" syntax keyword alienscriptImport include

syntax match alienscriptComment "\v;.*$"

syntax match alienscriptNumber "\v<-?\d+(\.\d+)?>"

syntax region alienscriptString start=+"+  skip=+\\\\\|\\"+  end=+"\|$+

" Custom words go here...
" syntax keyword alienscriptKeyword defn
" syntax keyword alienscriptKeyword onload

highlight link alienscriptKeyword Keyword
" highlight link alienscriptTesting Keyword
" highlight link alienscriptTemplating Keyword
highlight link alienscriptDefFunction Keyword
highlight link alienscriptDefMacro Keyword
" highlight link alienscriptOperator Operator
highlight link alienscriptConditional Conditional
" highlight link alienscriptException Exception
" highlight link alienscriptImport Include
highlight link alienscriptBoolean Boolean
" highlight link alienscriptRepeat Repeat
highlight link alienscriptNumber Number
highlight link alienscriptComment Comment
highlight link alienscriptString String
highlight link alienscriptConstant Constant

let b:current_syntax = "alienscript"

