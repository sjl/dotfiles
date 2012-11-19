if exists("b:did_lispyscript_ftplugin")
    finish
endif


setlocal iskeyword+=-,>,?,=,!,<,>,+,*,/,%,&,|

let b:did_lispyscript_ftplugin = 1
