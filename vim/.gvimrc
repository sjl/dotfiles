set guifont=Menlo:h12
colorscheme molokai

set go-=T

if has("gui_macvim")
    macmenu &File.New\ Tab key=<nop>
    map <D-t> <Plug>PeepOpen
end

"Invisible character colors
highlight NonText    guifg=#444444 guibg=#1a1c1d
highlight SpecialKey guifg=#444444 guibg=#1a1c1d

