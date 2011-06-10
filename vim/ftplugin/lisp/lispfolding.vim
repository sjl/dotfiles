if exists('loaded_lispfolding') || &cp
    finish
endif
let loaded_lispfolding=1

" ---------------------------------------------------------------------------
"  Automagic Lisp folding on defn's and defmacro's
"
function GetLispFold()
      if getline(v:lnum) =~ '^\s*(defun.*\s'
            return ">1"
      elseif getline(v:lnum) =~ '^\s*(defmacro.*\s'
            return ">1"
      elseif getline(v:lnum) =~ '^\s*(defparameter.*\s'
            return ">1"
      elseif getline(v:lnum) =~ '^\s*$'
            let my_lispnum = v:lnum
            let my_lispmax = line("$")

            while (1)
                  let my_lispnum = my_lispnum + 1
                  if my_lispnum > my_lispmax
                        return "<1"
                  endif

                  let my_lispdata = getline(my_lispnum)

                  " If we match an empty line, stop folding
                  if my_lispdata =~ '^$'
                        return "<1"
                  else
                        return "="
                  endif
            endwhile
      else
            return "="
      endif
endfunction

function TurnOnLispFolding()
      setlocal foldexpr=GetLispFold()
      setlocal foldmethod=expr
endfunction
