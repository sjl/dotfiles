set guifont=Menlo:h12
colorscheme molokai

set go-=T

if has("gui_macvim")
    macmenu &File.New\ Tab key=<nop>
    map <leader>t <Plug>PeepOpen
end

let g:sparkupExecuteMapping = '<D-e>'
