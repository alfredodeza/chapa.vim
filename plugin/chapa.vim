" File:        chapa.vim
" Description: vim plugin to visually select Python functions or classes
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
" Notes:       A lot of the code within was adapted/copied from python.vim 
"              and python_fn.vim authored by Jon Franklin and Mikael Berthe
"
"============================================================================

if exists("g:loaded_chapa") || &cp 
  finish
endif

"{{{ Helpers

" In certain situations, it allows you to echo something without 
" having to hit Return again to do exec the command.
" It looks if the global message variable is set or set to 0 or set to 1
function! s:Echo(msg)
  if (! exists('g:chapa_messages') || exists('g:chapa_messages') && g:chapa_messages)
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    redraw
    echo a:msg
    let &ruler=x | let &showcmd=y
  endif
endfun

"}}}

"{{{ Main Functions 

" Select an object ("class"/"function")
function! s:PythonSelectObject(obj, direction, count)
  " Go to the object declaration
  normal $
  let go_to_obj = s:FindPythonObject(a:obj, a:direction, a:count)
  if (! go_to_obj)
    return
  endif

  let beg = line('.')
  exec beg

  let until = s:NextIndent(1)
  let line_moves = until - beg
  
  if line_moves > 0
    execute "normal V" . line_moves . "j"
  else
    execute "normal VG" 
  endif
endfunction


function! s:NextIndent(fwd)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1

  while (line > 0 && line <= lastline)
    let line = line + stepvalue

    if (indent(line) <= indent && strlen(getline(line)) > 0)
      return line - 1
    endif
  endwhile
endfunction
 

" Go to previous (-1) or next (1) class/function definition
" return a line number that matches either a class or a function
" to call this manually:
" Backwards:
"     :call FindPythonObject("class", -1)
" Forwards:
"     :call FindPythonObject("class")
" Functions Backwards:
"     :call FindPythonObject("function", -1)
" Functions Forwards:
"     :call FindPythonObject("function")
function! s:FindPythonObject(obj, direction, count)
  if (a:obj == "class")
    let objregexp = "^\\s*class\\s\\+[a-zA-Z0-9_]\\+"
        \ . "\\s*\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*:"
  elseif (a:obj == "method")
    let objregexp = "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\s*self\\_[^:#]*)\\s*:"
  else
    " Relaxes the original RegExp to be able to match a bit more easier 
    " looks for a line starting with def (with space) that does not include 
    " a `self` in it.
    " orig regexp:  "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*:"
    let objregexp = '\v^(.*def )&(.*self)@!'
  endif
  let flag = "W"
  if (a:direction == -1)
    let flag = flag."b"
  endif
  let _count = a:count
  while _count > 0
    let result = search(objregexp, flag)
    let _count = _count - 1
  endwhile
  if result
    return line('.') 
  else 
    if (a:direction == -1)
      let movement = "previous "
    else
      let movement = "next "
    endif
    let message = "Match not found for " . movement . a:obj
    call s:Echo(message)
    return 
  endif
endfunction
"}}}

"{{{ Misc 
" Visual Select Class 
nnoremap <silent> <Plug>ChapaVisualNextClass :<C-U>call <SID>PythonSelectObject("class", 1, v:count1)<CR>
nnoremap <silent> <Plug>ChapaVisualPreviousClass :<C-U>call <SID>PythonSelectObject("class", -1, v:count1)<CR>

" Visual Select Function 
nnoremap <silent> <Plug>ChapaVisualNextFunction :<C-U>call <SID>PythonSelectObject("function", 1, v:count1)<CR>
nnoremap <silent> <Plug>ChapaVisualPreviousFunction :<C-U>call <SID>PythonSelectObject("function", -1, v:count1)<CR>

" Visual Select Method
nnoremap <silent> <Plug>ChapaVisualNextMethod :<C-U>call <SID>PythonSelectObject("method", 1, v:count1)<CR>
nnoremap <silent> <Plug>ChapaVisualPreviousMethod :<C-U>call <SID>PythonSelectObject("method", -1, v:count1)<CR>

" Method movement
nnoremap <silent> <Plug>ChapaPreviousMethod :<C-U>call <SID>FindPythonObject("method", -1, v:count1)<CR>
nnoremap <silent> <Plug>ChapaNextMethod :<C-U>call <SID>FindPythonObject("method", 1, v:count1)<CR>

" Class movement
nnoremap <silent> <Plug>ChapaPreviousClass :<C-U>call <SID>FindPythonObject("class", -1, v:count1)<CR>
nnoremap <silent> <Plug>ChapaNextClass :<C-U>call <SID>FindPythonObject("class", 1, v:count1)<CR>

" Function movement
nnoremap <silent> <Plug>ChapaPreviousFunction :<C-U>call <SID>FindPythonObject("function", -1, v:count1)<CR>
nnoremap <silent> <Plug>ChapaNextFunction :<C-U>call <SID>FindPythonObject("function", 1, v:count1)<CR>
"}}}
