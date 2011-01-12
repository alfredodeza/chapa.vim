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
let orig_line = line('.')
let orig_col = col('.')
  " Go to the object declaration
  normal $
  let go_to_obj = s:FindPythonObject(a:obj, a:direction, a:count)
  if (! go_to_obj)
    exec orig_line
    exe "normal " orig_col . "|"
    return
  endif

  " Sometimes, when we get a decorator we are not in the line we want 
  let has_decorator = s:HasPythonDecorator(line('.'))

  if has_decorator 
    let beg = has_decorator 
  else 
    let beg = line('.')
  endif

  let until = s:NextIndent(1)

  " go to the line we need
  exec beg
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

    " We look for the last non whitespace 
    " line (e.g. another function at same indent level
    " and then go back until we find an indent that 
    " matches what we are looking for
    while (line > 0 && line <= lastline)
        let line = line + stepvalue

        if (indent(line) <= indent && getline(line) !~ '^\s*$')
            let line = line -1 
            while (indent(line) <= indent)
                let line = line -1 
            endwhile
            return line 
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
let orig_line = line('.')
let orig_col = col('.')
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
    exec orig_line
    exe "normal " orig_col . "|"
    call s:Echo(message)
    return 
  endif
endfunction

function! s:HasPythonDecorator(line)
    " Get to the previous line where the decorator lives
    let line = a:line -1 
    while (getline(line) =~ '\v^(.*\@[a-zA-Z])')
        let line = line - 1
    endwhile

    " This is tricky but goes back and forth to 
    " correctly match the decorator without the 
    " possibility of selecting a blank line
    if (getline(line) =~ '\v^(.*\@[a-zA-Z])')
        return line
    elseif (getline(line+1) =~ '\v^(.*\@[a-zA-Z])')
        return line + 1
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
