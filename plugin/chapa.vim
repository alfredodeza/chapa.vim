"============================================================================
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
function! s:Echo(msg)
  let x=&ruler | let y=&showcmd
  set noruler noshowcmd
  redraw
  echo a:msg
  let &ruler=x | let &showcmd=y
endfun

"}}}

"{{{ Main Functions 

" Select an object ("class"/"function")
function! s:PythonSelectObject(obj)
  " Go to the object declaration
  normal $
  let rev = s:FindPythonObject(a:obj, -1)
  if (! rev)
    let fwd = s:FindPythonObject(a:obj, 1)
    if (! fwd)
      return
     endif
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
function! s:FindPythonObject(obj, direction)
  if (a:obj == "class")
    let objregexp = "^\\s*class\\s\\+[a-zA-Z0-9_]\\+"
        \ . "\\s*\\((\\([a-zA-Z0-9_,. \\t\\n]\\)*)\\)\\=\\s*:"
  else
    let objregexp = "^\\s*def\\s\\+[a-zA-Z0-9_]\\+\\s*(\\_[^:#]*)\\s*:"
  endif
  let flag = "W"
  if (a:direction == -1)
    let flag = flag."b"
  endif
  let result = search(objregexp, flag)
  if result
      return line('.') 
  else 
      return 
  endif
endfunction
"}}}

"{{{ Misc 
command! -nargs=0 ChapaVisualFunction call s:PythonSelectObject("function")
command! -nargs=0 ChapaVisualClass call s:PythonSelectObject("class")
"}}}
