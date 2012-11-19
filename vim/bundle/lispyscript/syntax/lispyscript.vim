if exists("b:current_syntax")
    finish
endif

syntax keyword lispyscriptDefFunction function

syntax keyword lispyscriptDefMacro macro

syntax keyword lispyscriptKeyword do -> new object str var
syntax keyword lispyscriptKeyword array arrayInit arrayInit2d
syntax keyword lispyscriptTesting assert testGroup testRunner
syntax keyword lispyscriptTemplating template template-repeat template-repeat-key

syntax keyword lispyscriptOperator undefined? null? true? false? zero? boolean?
syntax keyword lispyscriptOperator number? string? object? array? function?
syntax keyword lispyscriptOperator = ! != > < <= >= + - * / % &&
syntax match lispyscriptOperator "\v([ \t()]|^)\zs\|\|\ze([ \t()]|$)"

syntax keyword lispyscriptConstant null undefined

syntax keyword lispyscriptBoolean true false

syntax keyword lispyscriptRepeat loop each each2d eachKey reduce map for

syntax keyword lispyscriptConditional if cond when unless

syntax keyword lispyscriptException try catch throw

syntax keyword lispyscriptImport include

syntax match lispyscriptComment "\v;.*$"

syntax match lispyscriptNumber "\v<-?\d+(\.\d+)?>"

syntax region lispyscriptString start=+"+  skip=+\\\\\|\\"+  end=+"\|$+

" Custom words go here...
syntax keyword lispyscriptKeyword defn
syntax keyword lispyscriptKeyword onload

highlight link lispyscriptKeyword Keyword
highlight link lispyscriptTesting Keyword
highlight link lispyscriptTemplating Keyword
highlight link lispyscriptDefFunction Keyword
highlight link lispyscriptDefMacro Keyword
highlight link lispyscriptOperator Operator
highlight link lispyscriptConditional Conditional
highlight link lispyscriptException Exception
highlight link lispyscriptImport Include
highlight link lispyscriptBoolean Boolean
highlight link lispyscriptRepeat Repeat
highlight link lispyscriptNumber Number
highlight link lispyscriptComment Comment
highlight link lispyscriptString String
highlight link lispyscriptConstant Constant

let b:current_syntax = "lispyscript"

