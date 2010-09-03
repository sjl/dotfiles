" Vim color file
" Converted from Textmate theme Clouds using Coloration v0.2.4 (http://github.com/sickill/coloration)

set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "Clouds"

hi Cursor  guifg=NONE guibg=#000000 gui=NONE
hi Visual  guifg=NONE guibg=#bdd5fc gui=NONE
hi CursorLine  guifg=NONE guibg=#fffbd1 gui=NONE
hi CursorColumn  guifg=NONE guibg=#fffbd1 gui=NONE
hi LineNr  guifg=#808080 guibg=#ffffff gui=NONE
hi VertSplit  guifg=#cfcfcf guibg=#cfcfcf gui=NONE
hi MatchParen  guifg=#af956f guibg=NONE gui=NONE
hi StatusLine  guifg=#000000 guibg=#cfcfcf gui=bold
hi StatusLineNC  guifg=#000000 guibg=#cfcfcf gui=NONE
hi Pmenu  guifg=NONE guibg=NONE gui=NONE
hi PmenuSel  guifg=NONE guibg=#bdd5fc gui=NONE
hi IncSearch  guifg=NONE guibg=#e5dccf gui=NONE
hi Search  guifg=NONE guibg=#e5dccf gui=NONE
hi Directory  guifg=NONE guibg=NONE gui=NONE
hi Folded  guifg=#bcc8ba guibg=#ffffff gui=NONE

hi Normal  guifg=#000000 guibg=#ffffff gui=NONE
hi Boolean  guifg=#39946a guibg=NONE gui=NONE
hi Character  guifg=NONE guibg=NONE gui=NONE
hi Comment  guifg=#bcc8ba guibg=NONE gui=NONE
hi Conditional  guifg=#af956f guibg=NONE gui=NONE
hi Constant  guifg=NONE guibg=NONE gui=NONE
hi Define  guifg=#af956f guibg=NONE gui=NONE
hi ErrorMsg  guifg=NONE guibg=#ff002a gui=NONE
hi WarningMsg  guifg=NONE guibg=#ff002a gui=NONE
hi Float  guifg=#46a609 guibg=NONE gui=NONE
hi Function  guifg=NONE guibg=NONE gui=NONE
hi Identifier  guifg=#c52727 guibg=NONE gui=NONE
hi Keyword  guifg=#af956f guibg=NONE gui=NONE
hi Label  guifg=#5d90cd guibg=NONE gui=NONE
hi NonText  guifg=#bfbfbf guibg=#fffbd1 gui=NONE
hi Number  guifg=#46a609 guibg=NONE gui=NONE
hi Operator  guifg=#484848 guibg=NONE gui=NONE
hi PreProc  guifg=#af956f guibg=NONE gui=NONE
hi Special  guifg=#000000 guibg=NONE gui=NONE
hi SpecialKey  guifg=#bfbfbf guibg=#fffbd1 gui=NONE
hi Statement  guifg=#af956f guibg=NONE gui=NONE
hi StorageClass  guifg=#c52727 guibg=NONE gui=NONE
hi String  guifg=#5d90cd guibg=NONE gui=NONE
hi Tag  guifg=#606060 guibg=NONE gui=NONE
hi Title  guifg=#000000 guibg=NONE gui=bold
hi Todo  guifg=#bcc8ba guibg=NONE gui=inverse,bold
hi Type  guifg=NONE guibg=NONE gui=NONE
hi Underlined  guifg=NONE guibg=NONE gui=underline
hi rubyClass  guifg=#af956f guibg=NONE gui=NONE
hi rubyFunction  guifg=NONE guibg=NONE gui=NONE
hi rubyInterpolationDelimiter  guifg=NONE guibg=NONE gui=NONE
hi rubySymbol  guifg=NONE guibg=NONE gui=NONE
hi rubyConstant  guifg=NONE guibg=NONE gui=NONE
hi rubyStringDelimiter  guifg=#5d90cd guibg=NONE gui=NONE
hi rubyBlockParameter  guifg=NONE guibg=NONE gui=NONE
hi rubyInstanceVariable  guifg=NONE guibg=NONE gui=NONE
hi rubyInclude  guifg=#af956f guibg=NONE gui=NONE
hi rubyGlobalVariable  guifg=NONE guibg=NONE gui=NONE
hi rubyRegexp  guifg=#5d90cd guibg=NONE gui=NONE
hi rubyRegexpDelimiter  guifg=#5d90cd guibg=NONE gui=NONE
hi rubyEscape  guifg=NONE guibg=NONE gui=NONE
hi rubyControl  guifg=#af956f guibg=NONE gui=NONE
hi rubyClassVariable  guifg=NONE guibg=NONE gui=NONE
hi rubyOperator  guifg=#484848 guibg=NONE gui=NONE
hi rubyException  guifg=#af956f guibg=NONE gui=NONE
hi rubyPseudoVariable  guifg=NONE guibg=NONE gui=NONE
hi rubyRailsUserClass  guifg=NONE guibg=NONE gui=NONE
hi rubyRailsARAssociationMethod  guifg=#c52727 guibg=NONE gui=NONE
hi rubyRailsARMethod  guifg=#c52727 guibg=NONE gui=NONE
hi rubyRailsRenderMethod  guifg=#c52727 guibg=NONE gui=NONE
hi rubyRailsMethod  guifg=#c52727 guibg=NONE gui=NONE
hi erubyDelimiter  guifg=#c52727 guibg=NONE gui=NONE
hi erubyComment  guifg=#bcc8ba guibg=NONE gui=NONE
hi erubyRailsMethod  guifg=#c52727 guibg=NONE gui=NONE
hi htmlTag  guifg=NONE guibg=NONE gui=NONE
hi htmlEndTag  guifg=NONE guibg=NONE gui=NONE
hi htmlTagName  guifg=NONE guibg=NONE gui=NONE
hi htmlArg  guifg=NONE guibg=NONE gui=NONE
hi htmlSpecialChar  guifg=#bf78cc guibg=NONE gui=NONE
hi javaScriptFunction  guifg=#c52727 guibg=NONE gui=NONE
hi javaScriptRailsFunction  guifg=#c52727 guibg=NONE gui=NONE
hi javaScriptBraces  guifg=NONE guibg=NONE gui=NONE
hi yamlKey  guifg=#606060 guibg=NONE gui=NONE
hi yamlAnchor  guifg=NONE guibg=NONE gui=NONE
hi yamlAlias  guifg=NONE guibg=NONE gui=NONE
hi yamlDocumentHeader  guifg=#5d90cd guibg=NONE gui=NONE
hi cssURL  guifg=NONE guibg=NONE gui=NONE
hi cssFunctionName  guifg=#c52727 guibg=NONE gui=NONE
hi cssColor  guifg=#bf78cc guibg=NONE gui=NONE
hi cssPseudoClassId  guifg=#606060 guibg=NONE gui=NONE
hi cssClassName  guifg=#c52727 guibg=NONE gui=NONE
hi cssValueLength  guifg=#46a609 guibg=NONE gui=NONE
hi cssCommonAttr  guifg=#bf78cc guibg=NONE gui=NONE
hi cssBraces  guifg=NONE guibg=NONE gui=NONE