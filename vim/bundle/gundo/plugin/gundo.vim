" if exists('loaded_gundo')
"   finish
" endif
" let loaded_gundo = 1

if !hasmapto('<Plug>Gundo')
    map <leader>u <Plug>GundoShowGraph
endif

noremap <unique> <script> <Plug>GundoShowGraph <SID>ShowGraph
noremap <SID>ShowGraph :call <SID>ShowGraph()<CR>

function s:ShowGraph()
    echo "Show the graph here plz"
endfunction
