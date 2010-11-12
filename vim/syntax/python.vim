syn match  pythonBlock		":$" nextgroup=pythonDocString skipempty skipwhite
syn region pythonDocString	matchgroup=Normal start=+[uU]\='+ end=+'+ skip=+\\\\\|\\'+ contains=pythonEscape,@Spell contained
syn region pythonDocString	matchgroup=Normal start=+[uU]\="+ end=+"+ skip=+\\\\\|\\"+ contains=pythonEscape,@Spell contained
syn region pythonDocString	matchgroup=Normal start=+[uU]\="""+ end=+"""+ contains=pythonEscape,@Spell contained
syn region pythonDocString	matchgroup=Normal start=+[uU]\='''+ end=+'''+ contains=pythonEscape,@Spell contained
hi def link pythonDocString	Comment

