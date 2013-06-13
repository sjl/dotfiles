if exists("b:did_alienscript_ftplugin")
    finish
endif


setlocal iskeyword+=-,>,?,=,!,<,>,+,*,/,%,&,|

let b:did_alienscript_ftplugin = 1
