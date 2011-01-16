" File:        chapa.vim
" FileType:    ruby
" Description: Go to or visually select the next/previous class, method or
"              function in ruby.
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"
"============================================================================

if exists("g:loaded_chapa") || &cp 
  finish
endif

"{{{ Default Mappings 
if (exists('g:chapa_default_mappings'))
    " Function Movement
    nmap fnf <Plug>ChapaNextFunction
    nmap fpf <Plug>ChapaPreviousFunction

    " Class Movement
    nmap fnc <Plug>ChapaNextClass
    nmap fpc <Plug>ChapaPreviousClass

    " Method Movement
    nmap fnm <Plug>ChapaNextMethod
    nmap fpm <Plug>ChapaPreviousMethod

    " Module Movement 
    nmap fnM <Plug>ChapaNextModule
    nmap fpM <Plug>ChapaPreviousModule

    " Class Visual Select 
    nmap vnc <Plug>ChapaVisualNextClass
    nmap vic <Plug>ChapaVisualThisClass 
    nmap vpc <Plug>ChapaVisualPreviousClass

    " Method Visual Select
    nmap vnm <Plug>ChapaVisualNextMethod
    nmap vim <Plug>ChapaVisualThisMethod
    nmap vpm <Plug>ChapaVisualPreviousMethod

    " Function Visual Select
    nmap vnf <Plug>ChapaVisualNextFunction
    nmap vif <Plug>ChapaVisualThisFunction
    nmap vpf <Plug>ChapaVisualPreviousFunction

    " Module Visual Select
    nmap vnM <Plug>ChapaVisualNextModule
    nmap viM <Plug>ChapaVisualThisModule
    nmap vpM <Plug>ChapaVisualPreviousModule

    " Comment Class
    nmap cic <Plug>ChapaCommentThisClass
    nmap cnc <Plug>ChapaCommentNextClass
    nmap cpc <Plug>ChapaCommentPreviousClass

    " Comment Method 
    nmap cim <Plug>ChapaCommentThisMethod 
    nmap cnm <Plug>ChapaCommentNextMethod 
    nmap cpm <Plug>ChapaCommentPreviousMethod 

    " Comment Function 
    nmap cif <Plug>ChapaCommentThisFunction
    nmap cnf <Plug>ChapaCommentNextFunction
    nmap cpf <Plug>ChapaCommentPreviousFunction

    " Comment Module
    nmap ciM <Plug>ChapaCommentThisModule
    nmap cnM <Plug>ChapaCommentNextModule
    nmap cpM <Plug>ChapaCommentPreviousModule

    " Repeat Mappings
    nmap <C-h> <Plug>ChapaOppositeRepeat
    nmap <C-l> <Plug>ChapaRepeat
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

" Wouldn't it be nice if you could just repeat the effing Movements
" instead of typing mnemonics to keep going forward or backwards?
" Exactly.
function! s:Repeat()
    if (exists('g:chapa_last_action'))
        let cmd = "call " . g:chapa_last_action 
        exe cmd
    else 
        echo "No command to repeat"
    endif 
endfunction

function! s:BackwardRepeat()
    let act_map = {'s:NextClass(0)' : 's:PreviousClass(0)',
                \'s:PreviousClass(0)' : 's:NextClass(0)',
                \'s:NextMethod(0)' : 's:PreviousMethod(0)',
                \'s:PreviousMethod(0)' : 's:NextMethod(0)',
                \'s:NextFunction(0)' : 's:PreviousFunction(0)',
                \'s:PreviousFunction(0)' : 's:NextFunction(0)',
                \'s:NextModule(0)' : 's:PreviousModule(0)',
                \'s:PreviousModule(0)' : 's:NextModule(0)'}
    if (exists('g:chapa_last_action'))
        let fwd = g:chapa_last_action 
        let cmd = "call " . act_map[fwd]
        exe cmd
    else 
        echo "No opposite command to repeat"
    endif
endfunction
"}}}

"{{{ Main Functions 
" Range for commenting 
function! s:RubyCommentObject(obj, direction, count)
    let orig_line = line('.')
    let orig_col = col('.')

    " Go to the object declaration
    normal $
    let go_to_obj = s:FindRubyObject(a:obj, a:direction, a:count)
        
    if (! go_to_obj)
        exec orig_line
        exe "normal " orig_col . "|"
        return
    endif

    let beg = line('.')

    let until = s:NextEnd(1, a:obj)

    " go to the line we need
    exec beg
    let line_moves = until - beg

    " check if we have comments or not 
    let has_comments = s:HasComments(beg, until)
    if (has_comments == 1)
        let regex = " s/^#//"
        let until = s:LastComment(beg)
    else
        let regex = " s/^/#/"
    endif
        
    if line_moves > 0
        execute beg . "," . until . regex
    else
        execute "%" . regex
    endif
    let @/ = ""
    return 1
endfunction

" Find if a Range has comments or not 
function! s:HasComments(from, until)
    let regex =  's/^#//gn'
    try 
        silent exe a:from . "," . a:until . regex
        return 1
    catch /^Vim\%((\a\+)\)\=:E/
        return 0
    endtry
endfunction

" Find the last commented line 
function! s:LastComment(from_line)
    let line = a:from_line
    while ((getline(line) =~ '^\s*#') && (line <= line('$')))
        let line = line+1
    endwhile 
    return line 
endfunction

" Select an object ("class"/"function")
function! s:RubySelectObject(obj, direction, count)
    let orig_line = line('.')
    let orig_col = col('.')

    " Go to the object declaration
    normal $
    let go_to_obj = s:FindRubyObject(a:obj, a:direction, a:count)
        
    if (! go_to_obj)
        exec orig_line
        exe "normal " orig_col . "|"
        return
    endif

    let beg = line('.')

    let until = s:NextEnd(1, a:obj)

    " go to the line we need
    exec beg
    let line_moves = until - beg

    if line_moves > 0
        execute "normal V" . line_moves . "j"
    else
        execute "normal VG" 
    endif
endfunction


function! s:NextEnd(fwd, obj)
    let line = line('.')
    let column = col('.')
    let lastline = line('$')
    let stepvalue = a:fwd ? 1 : -1
    
    if (a:obj == "class")
        let c_class = 1 
    else
        let c_class = 0
    endif

    if (a:obj == "method")
        let c_method = 1
    else
        let c_method = 0
    endif

    if (a:obj == "function")
        let c_function = 1 
    else
        let c_function = 0
    endif

    if (a:obj == "module")
        let c_module = 1
    else 
        let c_module = 0
    endif

    let c_end = 0
    let found = 0
    let matched = 0
    while ((line > 0) && (line <= lastline) && (found == 0))
        let line = line + 1
        if (getline(line) =~ '\v^\s*(.*class)\s+(\w+)\s*&(.*end)@!')
            let c_class = c_class + 1
        elseif (getline(line) =~ '\v^\s*(.*def)\s+(self*)\s*&(.*end)@!')
            let c_method = c_method + 1
        elseif (getline(line) =~ '\v^\s*(.*module)\s+(\w+)\s*&(.*end)@!')
            let c_module = c_module + 1
        elseif (getline(line) =~ '\v^\s*(.*def)\s+&(.*self)@!&(.*end)@!')
            let c_function = c_function + 1

        " Match keywords that trigger `end` in Ruby 
        " if else while until do for 
    "elseif (getline(line) =~ '\v^\s+(if|else|while|until|do|for)\s+')
    elseif (getline(line) =~ '\v^\s+if\s+')
            let c_end = c_end -1
    elseif (getline(line) =~ '\v^\s+unless\s+')
            let c_end = c_end -1
    elseif (getline(line) =~ '\v\s+do\s+')
            let c_end = c_end -1
        endif            


        if (getline(line) =~ '\v^\s*(.*end)\s*')
            let c_end = c_end + 1
            if (c_class + c_method + c_function + c_module == c_end)
                return line 
                let found = 1 
            endif 
        endif
    endwhile
endfunction
 

" Go to previous (-1) or next (1) class/function definition
" return a line number that matches either a class or a function
" to call this manually:
" Backwards:
"     :call FindRubyObject("class", -1)
" Forwards:
"     :call FindRubyObject("class")
" Functions Backwards:
"     :call FindRubyObject("function", -1)
" Functions Forwards:
"     :call FindRubyObject("function")
function! s:FindRubyObject(obj, direction, count)
    let orig_line = line('.')
    let orig_col = col('.')
    if (a:obj == "class")
        let objregexp  = '\v^\s*(.*class)\s+(\w+)\s*&(.*end)@!'
    elseif (a:obj == "method")
        let objregexp = '\v^\s*(.*def)\s+(self*)\s*&(.*end)@!'
    elseif (a:obj == "module")
        let objregexp = '\v^\s*(.*module)\s+(\w+)\s*&(.*end)@!'
    else
        let objregexp = '\v^\s*(.*def)\s+&(.*self)@!&(.*end)@!'
    endif
    let flag = "W"
    if (a:direction == -1)
        let flag = flag."b"
    endif
    let _count = a:count
    let matched_search = 0
    if (_count == 0)
        let result = search(objregexp, flag)
        if result 
            let matched_search = result 
        endif
    else    
        while _count > 0
            let result = search(objregexp, flag)
            if result 
                let matched_search = result 
            endif
            let _count = _count - 1
        endwhile
    endif
    if (matched_search != 0)
        return matched_search
    endif
endfunction


function! s:IsInside(object)
    let beg = line('.')
    let column = col('.')
    " Verifies you are actually inside 
    " of the object you are referring to 
    exe beg 
    let class = s:PreviousObjectLine("class")
    exe beg 
    let method = s:PreviousObjectLine("method")
    exe beg 
    let function = s:PreviousObjectLine("function")
    exe beg 
    let module = s:PreviousObjectLine("module")
    exe beg
    exe "normal " column . "|"

    if (a:object == "function")
        if (function == -1)
            return -1
        elseif ((class < function) && (method < function))
            return 1
        else 
            return 0 
        endif 
    elseif (a:object == "class")
        if (class == -1)
            return -1
        elseif ((function < class) && (method < class))
            return 1
        else 
            return 0 
        endif 
    elseif (a:object == "method")
        if (method == -1)
            return -1
        elseif ((function < method) && (class < method))
            return 1
        else 
            return 0
        endif 
    elseif (a:object == "module")
        if (module == -1)
            return -1
        elseif ((function < module) && (class < module))
            return 1
        else 
            return 0
        endif
    endif 
endfunction 

function! s:PreviousObjectLine(obj)
    let beg = line('.')
    if (a:obj == "class")
        let objregexp  = '\v^\s*(.*class)\s+(\w+)\s*'
    elseif (a:obj == "module")
        let objregexp = '\v^\s*(.*module)\s+(\w+)\s*'
    elseif (a:obj == "method")
        let objregexp = '\v^\s*(.*def)\s+(self*)\s*'
    else
        let objregexp = '\v^\s*(.*def)&(.*self)@!'
    endif

    let flag = 'Wb' 

    " are we on THE actual beginning of the object? 
    if (getline('.') =~ objregexp)
        return -1
    else
        let result = search(objregexp, flag)
        if (line('.') == beg)
            return 0
        endif
        if result
            return line('.')
        else 
            return 0
        endif
    endif

endfunction
"}}}

"{{{ Proxy Functions 
"
" Commenting Selections
"
" Comment Class Selections:
"
function! s:CommentPreviousClass()
    let inside = s:IsInside("class")
    let times = v:count1+inside
    if (! s:RubyCommentObject("class", -1, times))
        call s:Echo("Could not match previous class for commenting")
    endif 
endfunction

function! s:CommentNextClass()
    if (! s:RubyCommentObject("class", 1, v:count1))
        call s:Echo("Could not match next class for commenting")
    endif 
endfunction

function! s:CommentThisClass()
    if (! s:RubyCommentObject("class", -1, 1))
        call s:Echo("Could not match inside of class for commenting")
    endif 
endfunction

"
" Comment Method Selections:
"
function! s:CommentPreviousMethod()
    let inside = s:IsInside("method")
    let times = v:count1+inside
    if (! s:RubyCommentObject("method", -1, times))
        call s:Echo("Could not match previous method for commenting")
    endif 
endfunction

function! s:CommentNextMethod()
    if (! s:RubyCommentObject("method", 1, v:count1))
        call s:Echo("Could not match next method for commenting")
    endif 
endfunction

function! s:CommentThisMethod()
    if (! s:RubyCommentObject("method", -1, 1))
        call s:Echo("Could not match inside of method for commenting")
    endif 
endfunction

"
" Comment Function Selections:
"
function! s:CommentPreviousFunction()
    let inside = s:IsInside("function")
    let times = v:count1+inside
    if (! s:RubyCommentObject("function", -1, times))
        call s:Echo("Could not match previous function for commenting")
    endif 
endfunction

function! s:CommentNextFunction()
    if (! s:RubyCommentObject("function", 1, v:count1))
        call s:Echo("Could not match next function for commenting")
    endif 
endfunction

function! s:CommentThisFunction()
    if (! s:RubyCommentObject("function", -1, 1))
        call s:Echo("Could not match inside of function for commenting")
    endif 
endfunction

"
" Comment Module Selections:
"
function! s:CommentPreviousModule()
    let inside = s:IsInside("module")
    let times = v:count1+inside
    if (! s:RubyCommentObject("module", -1, times))
        call s:Echo("Could not match previous module for commenting")
    endif 
endfunction

function! s:CommentNextModule()
    if (! s:RubyCommentObject("module", 1, v:count1))
        call s:Echo("Could not match next module for commenting")
    endif 
endfunction

function! s:CommentThisModule()
    if (! s:RubyCommentObject("module", -1, 1))
        call s:Echo("Could not match inside of module for commenting")
    endif 
endfunction


"
" Visual Selections:
"
" Visual Class Selections:
function! s:VisualNextClass()
    if (! s:RubySelectObject("class", 1, v:count1))
        call s:Echo("Could not match next class for visual selection")
    endif
endfunction

function! s:VisualPreviousClass()
    let inside = s:IsInside("class")
    let times = v:count1+inside
    if (! s:RubySelectObject("class", -1, times))
        call s:Echo("Could not match previous class for visual selection")
    endif 
endfunction

function! s:VisualThisClass()
    if (! s:RubySelectObject("class", -1, 1))
        call s:Echo("Could not match inside of class for visual selection")
    endif 
endfunction


" Visual Function Selections:
function! s:VisualNextFunction()
    if (! s:RubySelectObject("function", 1, v:count1))
        call s:Echo("Could not match next function for visual selection")
    endif
endfunction

function! s:VisualPreviousFunction()
    let inside = s:IsInside("function")
    let times = v:count1+inside
    if (! s:RubySelectObject("function", -1, times))
        call s:Echo("Could not match previous function for visual selection")
    endif 
endfunction

function! s:VisualThisFunction()
    if (! s:RubySelectObject("function", -1, 1))
        call s:Echo("Could not match inside of function for visual selection")
    endif 
endfunction

" Visual Method Selections:
function! s:VisualNextMethod()
    if (! s:RubySelectObject("method", 1, v:count1))
        call s:Echo("Could not match next method for visual selection")
    endif
endfunction

function! s:VisualPreviousMethod()
    let inside = s:IsInside("method")
    let times = v:count1+inside
    if (! s:RubySelectObject("method", -1, times))
        call s:Echo("Could not match previous method for visual selection")
    endif 
endfunction

function! s:VisualThisMethod()
    if (! s:RubySelectObject("method", -1, 1))
        call s:Echo("Could not match inside of method for visual selection")
    endif 
endfunction

" Visual Module Selections:
function! s:VisualNextModule()
    if (! s:RubySelectObject("module", 1, v:count1))
        call s:Echo("Could not match next module for visual selection")
    endif
endfunction

function! s:VisualPreviousModule()
    let inside = s:IsInside("module")
    let times = v:count1+inside
    if (! s:RubySelectObject("module", -1, times))
        call s:Echo("Could not match previous module for visual selection")
    endif 
endfunction

function! s:VisualThisModule()
    if (! s:RubySelectObject("module", -1, 1))
        call s:Echo("Could not match inside of module for visual selection")
    endif 
endfunction


" 
" Movements:
" 
" Class:
function! s:PreviousClass(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:PreviousClass(0)"
    endif
    let inside = s:IsInside("class")
    let times = v:count1+inside
    if (! s:FindRubyObject("class", -1, times))
        call s:Echo("Could not match previous class")
    endif 
endfunction 

function! s:NextClass(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:NextClass(0)"
    endif
    if (! s:FindRubyObject("class", 1, v:count1))
        call s:Echo("Could not match next class")
    endif 
endfunction 

" Method:
function! s:PreviousMethod(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:PreviousMethod(0)"
    endif
    let inside = s:IsInside("method")
    let times = v:count1+inside
    if (! s:FindRubyObject("method", -1, times))
        call s:Echo("Could not match previous method")
    endif 
endfunction 

function! s:NextMethod(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:NextMethod(0)"
    endif
    if (! s:FindRubyObject("method", 1, v:count1))
        call s:Echo("Could not match next method")
    endif 
endfunction 

" Function:
function! s:PreviousFunction(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:PreviousFunction(0)"
    endif
    let inside = s:IsInside("function")
    let times = v:count1+inside
    if (! s:FindRubyObject("function", -1, times))
        call s:Echo("Could not match previous function")
    endif 
endfunction
        
function! s:NextFunction(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:NextFunction(0)"
    endif
    if (! s:FindRubyObject("function", 1, v:count1))
        call s:Echo("Could not match next function")
    endif 
endfunction

" Module:
function! s:PreviousModule(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:PreviousModule(0)"
    endif
    let inside = s:IsInside("module")
    let times = v:count1+inside
    if (! s:FindRubyObject("module", -1, times))
        call s:Echo("Could not match previous module")
    endif 
endfunction
        
function! s:NextModule(record)
    if (a:record == 1)
        let g:chapa_last_action = "s:NextModule(0)"
    endif
    if (! s:FindRubyObject("module", 1, v:count1))
        call s:Echo("Could not match next module")
    endif 
endfunction
"}}}

"{{{ Misc 
" Comment Class: 
nnoremap <silent> <Plug>ChapaCommentPreviousClass   :<C-U>call <SID>CommentPreviousClass() <CR>
nnoremap <silent> <Plug>ChapaCommentNextClass       :<C-U>call <SID>CommentNextClass()     <CR>
nnoremap <silent> <Plug>ChapaCommentThisClass       :<C-U>call <SID>CommentThisClass()     <CR>

" Comment Method: 
nnoremap <silent> <Plug>ChapaCommentPreviousMethod   :<C-U>call <SID>CommentPreviousMethod()<CR>
nnoremap <silent> <Plug>ChapaCommentNextMethod       :<C-U>call <SID>CommentNextMethod()    <CR>
nnoremap <silent> <Plug>ChapaCommentThisMethod       :<C-U>call <SID>CommentThisMethod()    <CR>

" Comment Function: 
nnoremap <silent> <Plug>ChapaCommentPreviousFunction   :<C-U>call <SID>CommentPreviousFunction()  <CR>
nnoremap <silent> <Plug>ChapaCommentNextFunction       :<C-U>call <SID>CommentNextFunction()      <CR>
nnoremap <silent> <Plug>ChapaCommentThisFunction       :<C-U>call <SID>CommentThisFunction()      <CR>

" Comment Module: 
nnoremap <silent> <Plug>ChapaCommentPreviousModule   :<C-U>call <SID>CommentPreviousModule()  <CR>
nnoremap <silent> <Plug>ChapaCommentNextModule       :<C-U>call <SID>CommentNextModule()      <CR>
nnoremap <silent> <Plug>ChapaCommentThisModule       :<C-U>call <SID>CommentThisModule()      <CR>

" Visual Select Class:
nnoremap <silent> <Plug>ChapaVisualNextClass        :<C-U>call <SID>VisualNextClass()       <CR>
nnoremap <silent> <Plug>ChapaVisualPreviousClass    :<C-U>call <SID>VisualPreviousClass()   <CR>
nnoremap <silent> <Plug>ChapaVisualThisClass        :<C-U>call <SID>VisualThisClass()       <CR>

" Visual Select Method:
nnoremap <silent> <Plug>ChapaVisualNextMethod       :<C-U>call <SID>VisualNextMethod()      <CR>
nnoremap <silent> <Plug>ChapaVisualPreviousMethod   :<C-U>call <SID>VisualPreviousMethod()  <CR>
nnoremap <silent> <PLug>ChapaVisualThisMethod       :<C-U>call <SID>VisualThisMethod()      <CR>

" Visual Select Function:
nnoremap <silent> <Plug>ChapaVisualNextFunction     :<C-U>call <SID>VisualNextFunction()    <CR>
nnoremap <silent> <Plug>ChapaVisualPreviousFunction :<C-U>call <SID>VisualPreviousFunction()<CR>
nnoremap <silent> <Plug>ChapaVisualThisFunction     :<C-U>call <SID>VisualThisFunction()    <CR>

" Visual Select Module:
nnoremap <silent> <Plug>ChapaVisualNextModule       :<C-U>call <SID>VisualNextModule()      <CR>
nnoremap <silent> <Plug>ChapaVisualPreviousModule   :<C-U>call <SID>VisualPreviousModule()  <CR>
nnoremap <silent> <Plug>ChapaVisualThisModule       :<C-U>call <SID>VisualThisModule()      <CR>

" Class Movement:
nnoremap <silent> <Plug>ChapaPreviousClass          :<C-U>call <SID>PreviousClass(1)        <CR>
nnoremap <silent> <Plug>ChapaNextClass              :<C-U>call <SID>NextClass(1)            <CR>

" Method Movement:
nnoremap <silent> <Plug>ChapaPreviousMethod         :<C-U>call <SID>PreviousMethod(1)       <CR>
nnoremap <silent> <Plug>ChapaNextMethod             :<C-U>call <SID>NextMethod(1)           <CR>

" Function Movement:
nnoremap <silent> <Plug>ChapaPreviousFunction       :<C-U>call <SID>PreviousFunction(1)     <CR>
nnoremap <silent> <Plug>ChapaNextFunction           :<C-U>call <SID>NextFunction(1)         <CR>

" Module Movement:
nnoremap <silent> <Plug>ChapaPreviousModule         :<C-U>call <SID>PreviousModule(1)       <CR>
nnoremap <silent> <Plug>ChapaNextModule             :<C-U>call <SID>NextModule(1)           <CR>

" Repeating Movements:
nnoremap <silent> <Plug>ChapaOppositeRepeat         :<C-U>call <SID>BackwardRepeat()        <CR>
nnoremap <silent> <Plug>ChapaRepeat                 :<C-U>call <SID>Repeat()                <CR>
"}}}
