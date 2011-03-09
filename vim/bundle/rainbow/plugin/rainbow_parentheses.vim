"------------------------------------------------------------------------------
"  Description: Rainbow colors for parentheses, based on rainbow_parenthsis.vim
"               by Martin Krischik.  This version cleans things up, simplifies
"               a few things, and changes "parenthsis" to "parentheses".
"------------------------------------------------------------------------------

command! -nargs=0 RainbowParenthesesToggle       call rainbow_parentheses#Toggle()
command! -nargs=0 RainbowParenthesesLoadSquare   call rainbow_parentheses#LoadSquare()
command! -nargs=0 RainbowParenthesesLoadRound    call rainbow_parentheses#LoadRound()
command! -nargs=0 RainbowParenthesesLoadBraces   call rainbow_parentheses#LoadBraces()
command! -nargs=0 RainbowParenthesesLoadChevrons call rainbow_parentheses#Chevrons()

finish
