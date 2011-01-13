" Vim syntax file
" Language: 	fish
" Maintainer:	 yann monclair <yann@monclair.info>
" Heavily based on zsh.vim by Felix von Leitner
" there is still much work to be done, this is just a start, it should get
" better with time 
" Url: http://monclair.info/~yann/vim  
" Last Change:	2005/11/08



" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" String and Character contstants
" Highlight special characters (those which have a backslash) differently
syn match   fishSpecial	"\\\d\d\d\|\\[abcfnrtv\\']"
syn region	fishSinglequote	start=+'+ skip=+\\'+ end=+'+
" A bunch of useful fish keywords
syn keyword	fishFunction	function
syn keyword	fishStatement	. and bg begin bind break builtin	
syn keyword	fishStatement	case cd command commandline complete continue count
syn keyword	fishStatement	dirh dirs end else eval exec exit
syn keyword	fishStatement	fg fishd for function functions
syn keyword	fishStatement	help if jobs mimedb nextd not or
syn keyword	fishStatement	popd prevd pushd random return read
syn keyword	fishStatement	set set_color switch tokenize
syn keyword	fishStatement	ulimit umask while
syn keyword	fishInputrc	backward-char backward-delete-char backward-kill-line backward-kill-word backward-word 
syn keyword	fishInputrc	beginning-of-history beginning-of-line complete delete-char delete-line
syn keyword     fishInputrc     explain forward-char forward-word history-search-backward history-search-forward 
syn keyword     fishInputrc     kill-line kill-whole-line kill-word yank yank-pop

syn keyword	fishConditional	if else case then in
syn keyword	fishRepeat	while for done


" Following is worth to notice: command substitution, file redirection and functions (so these features turns red)
syn match	fishFunctionName	"\h\w*\s*()"
syn region	fishshCommandSub	start=+(+  end=+)+ contains=ALLBUT,fishFunction
syn match	fishRedir	"\d\=\(<\|<<\|>\|>>\)\(|\|&\d\)\="

syn keyword	fishColors		black red green brown yellow blue magenta purple cyan white normal

syn keyword	fishSpecialCommands fish_on_exit fish_on_exec fish_on_return

syn keyword	fishTodo contained TODO

syn keyword	fishVariables		fish_prompt fish_title history status _ umask
syn keyword	fishShellVariables	USER LOGNAME HOME PATH CDPATH SHELL BROWSER
syn keyword	fishVariables		fish_color_normal fish_color_command fish_color_substitution fish_color_redirection fish_color_end fish_color_error fish_color_param fish_color_comment fish_color_match fish_color_search_match fish_color_cwd fish_pager_color_prefix fish_pager_color_completion fish_pager_color_description  fish_pager_color_progress

"syn keyword	fishShellVariables	LC_TYPE LC_MESSAGE MAIL MAILCHECK
"syn keyword	fishShellVariables	PS1 PS2 IFS EGID EUID ERRNO GID UID
"syn keyword	fishShellVariables	HOST LINENO MACHTYPE OLDPWD OPTARG
"syn keyword	fishShellVariables	OPTIND OSTYPE PPID PWD RANDOM SECONDS
"syn keyword	fishShellVariables	SHLVL TTY signals TTYIDLE USERNAME
"syn keyword	fishShellVariables	VENDOR fish_NAME fish_VERSION ARGV0
"syn keyword	fishShellVariables	BAUD COLUMNS cdpath DIRSTACKSIZE
"syn keyword	fishShellVariables	FCEDIT fignore fpath histchars HISTCHARS
"syn keyword	fishShellVariables	HISTFILE HISTSIZE KEYTIMEOUT LANG
"syn keyword	fishShellVariables	LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES
"syn keyword	fishShellVariables	LC_TIME LINES LISTMAX LOGCHECK mailpath
"syn keyword	fishShellVariables	MAILPATH MANPATH manpath module_path
"syn keyword	fishShellVariables	MODULE_PATH NULLCMD path POSTEDIT
"syn keyword	fishShellVariables	PS3 PS4 PROMPT PROMPT2 PROMPT3 PROMPT4
"syn keyword	fishShellVariables	psvar PSVAR prompt READNULLCMD
"syn keyword	fishShellVariables	REPORTTIME RPROMPT RPS1 SAVEHIST
"syn keyword	fishShellVariables	SPROMPT STTY TIMEFMT TMOUT TMPPREFIX
"syn keyword	fishShellVariables	watch WATCH WATCHFMT WORDCHARS ZDOTDIR
syn match	fishSpecialShellVar	"\$[-#@*$?!0-9]"
syn keyword	fishSetVariables		ignoreeof noclobber
syn region	fishDerefOpr	start="\${" end="}" contains=fishShellVariables
syn match	fishDerefIdentifier	"\$[a-zA-Z_][a-zA-Z0-9_]*\>"
syn match	fishOperator		"[][}{&;|)(]"



syn match  fishNumber		"-\=\<\d\+\>"
syn match  fishComment	"#.*$" contains=fishNumber,fishTodo


syn match fishTestOpr	"-\<[oeaznlg][tfqet]\=\>\|!\==\|-\<[b-gkLprsStuwjxOG]\>"
syn region fishTest	      start="\[" skip="\\$" end="\]" contains=fishString,fishTestOpr,fishDerefIdentifier,fishDerefOpr
syn region  fishString	start=+"+  skip=+\\"+  end=+"+  contains=fishSpecial,fishOperator,fishDerefIdentifier,fishDerefOpr,fishSpecialShellVar,fishSinglequote,fishCommandSub

syn region fishFunctions start=+function+  end=+end+ contains=fishShellVariables,fishRedir,fishCommandSub,fishVariables, fishConditional,fishRepeat,fishStatement

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_fish_syntax_inits")
  if version < 508
    let did_fish_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink fishSinglequote	fishString
  HiLink fishConditional	fishStatement
  HiLink fishRepeat		fishStatement
  HiLink fishFunctionName	fishFunction
  HiLink fishFunctions		fishFunction
  HiLink fishCommandSub		fishOperator
  HiLink fishRedir		fishOperator
  HiLink fishSetVariables	fishShellVariables
  HiLink fishSpecialShellVar	fishShellVariables
  HiLink fishColors		fishVariables
  HiLink fishTestOpr		fishOperator
  HiLink fishDerefOpr		fishSpecial
  HiLink fishDerefIdentifier	fishShellVariables
  HiLink fishOperator		Operator
  HiLink fishStatement		Statement
  HiLink fishNumber		Number
  HiLink fishString		String
  HiLink fishComment		Comment
  HiLink fishSpecial		Special
  HiLink fishTodo		Todo
  HiLink fishShellVariables	Special
  hi fishOperator		term=underline ctermfg=6 guifg=Purple gui=bold
 " hi fishShellVariables	term=underline ctermfg=2 guifg=SeaGreen gui=bold
 " hi fishVariables	term=underline ctermfg=5 guifg=Blue gui=bold
 " hi fishFunction		guifg=Red gui=bold
 " hi fishFunctionName		guifg=Blue gui=bold
  "hi fishVariables 		ctermbg=3 guifg=Blue gui=bold
  
  delcommand HiLink
endif

let b:current_syntax = "fish"

" vim: ts=8
