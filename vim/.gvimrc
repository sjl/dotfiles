set guifont=Menlo:h12
colorscheme molokai

set go-=T

if has("gui_macvim")
    macmenu &File.New\ Tab key=<nop>
    map <leader>t <Plug>PeepOpen
end

let g:sparkupExecuteMapping = '<D-e>'

highlight SpellBad term=underline gui=undercurl guisp=Orange
highlight LongLine guibg=#343738

" Long lines suck.
match LongLine '\%>84v.\+'
