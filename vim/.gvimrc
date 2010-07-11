set guifont=Menlo:h12
colorscheme molokai
set background=dark

set go-=T
set go-=l
set go-=L
set go-=r
set go-=R

if has("gui_macvim")
    macmenu &File.New\ Tab key=<nop>
    map <leader>t <Plug>PeepOpen
end

let g:sparkupExecuteMapping = '<D-e>'

highlight SpellBad term=underline gui=undercurl guisp=Orange

