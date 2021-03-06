Chapa
=====
Allows you to move to previous/next N class, function or method 

or visually select the next/previous N class, function or method 

or comment (or toggle) out the next/previous N class, function or method.

As this is a "file-type plugin", it currently supports both Python and Ruby.

Watch the screencast: http://vimeo.com/19016562

Install it from: http://www.vim.org/scripts/script.php?script_id=3395

Installation couldn't be easier: drop the ftplugin file in your vim ftplugin 
directory. For example, if you are using Python, this would be something like::

    ~/.vim/ftplugin/python/chapa.vim

I would highly recommend you use something like Pathogen though, it 
makes dealing with VIM plugins way easier.

1. Intro                                 
==============================================================================

After trying other plugins that were supposed to achieve this objective (and 
fail) I decided to write it on my own.  

No need to have VIM compiled with Python or Ruby support since this plugin uses 
pure VIM syntax.

2. Usage                                
==============================================================================

There are a couple of routes you can take: with or without default mappings.

If you want to define your own mappings then no need to do anything else other 
than know the actual plugin calls (listed below).

If you want the default mappings (also listed below) you need to add this to 
your vimrc::

    let g:chapa_default_mappings = 1

You can also make the repeat actions for the plugin optional. If the above 
variable is set but you don't like the repeat mappings, set the following 
in your vimrc::

    let g:chapa_no_repeat_mappings = 1

You can map those callables to anything you want, but below is how the 
defaults are mapped::

    " Repeat Mappings
    nmap <buffer> <C-h> <Plug>ChapaOppositeRepeat
    nmap <buffer> <C-l> <Plug>ChapaRepeat

    " Function Movement
    nmap <buffer> fnf <Plug>ChapaNextFunction
    nmap <buffer> fif <Plug>ChapaInFunction
    nmap <buffer> fpf <Plug>ChapaPreviousFunction

    " Class Movement
    nmap <buffer> fnc <Plug>ChapaNextClass
    nmap <buffer> fic <Plug>ChapaInClass
    nmap <buffer> fpc <Plug>ChapaPreviousClass

    " Method Movement
    nmap <buffer> fnm <Plug>ChapaNextMethod
    nmap <buffer> fim <Plug>ChapaInMethod
    nmap <buffer> fpm <Plug>ChapaPreviousMethod

    " Class Visual Select 
    nmap <buffer> vnc <Plug>ChapaVisualNextClass
    nmap <buffer> vic <Plug>ChapaVisualThisClass
    nmap <buffer> vpc <Plug>ChapaVisualPreviousClass

    " Method Visual Select
    nmap <buffer> vnm <Plug>ChapaVisualNextMethod
    nmap <buffer> vim <Plug>ChapaVisualThisMethod
    nmap <buffer> vpm <Plug>ChapaVisualPreviousMethod

    " Function Visual Select
    nmap <buffer> vnf <Plug>ChapaVisualNextFunction
    nmap <buffer> vif <Plug>ChapaVisualThisFunction
    nmap <buffer> vpf <Plug>ChapaVisualPreviousFunction

    " Comment Class
    nmap <buffer> cic <Plug>ChapaCommentThisClass
    nmap <buffer> cnc <Plug>ChapaCommentNextClass
    nmap <buffer> cpc <Plug>ChapaCommentPreviousClass

    " Comment Method 
    nmap <buffer> cim <Plug>ChapaCommentThisMethod
    nmap <buffer> cnm <Plug>ChapaCommentNextMethod
    nmap <buffer> cpm <Plug>ChapaCommentPreviousMethod

    " Comment Function 
    nmap <buffer> cif <Plug>ChapaCommentThisFunction
    nmap <buffer> cnf <Plug>ChapaCommentNextFunction
    nmap <buffer> cpf <Plug>ChapaCommentPreviousFunction

    " Folding Method
    nmap <buffer> zim <Plug>ChapaFoldThisMethod
    nmap <buffer> znm <Plug>ChapaFoldNextMethod
    nmap <buffer> zpm <Plug>ChapaFoldPreviousMethod

    " Folding Class
    nmap <buffer> zic <Plug>ChapaFoldThisClass
    nmap <buffer> znc <Plug>ChapaFoldNextClass
    nmap <buffer> zpc <Plug>ChapaFoldPreviousClass

    " Folding Function
    nmap <buffer> zif <Plug>ChapaFoldThisFunction
    nmap <buffer> znf <Plug>ChapaFoldNextFunction
    nmap <buffer> zpf <Plug>ChapaFoldPreviousFunction


Since these should only be defined for buffers of the supported filetypes, if
you don't enable the default mappings you'll want to define your own through e.g.
``~/.vim/after/ftplugin/python.vim`` or with ``autocmd``\s.

If the requested search (function, class or method) is not found, the call simply 
returns and nothing should happen. However, there is an error message that should 
display by default, explaining what it was supposed to search and in what 
direction.

You can disable this by adding a chapa-specific variable in your vimrc::

  let g:chapa_messages = 0

You can also add a "count" to repeat the match N times. So if you want to go 
to the 3rd previous class you would (with the mappings above) do something like::

  3fpc

The same applies for visual selections. If you want to visually select the 3rd
next method, you would do it like::

  3vnm

You can also toggle comments of a given class, method or function. To comment
the next class::

  cnc 

If the class is already commented, the command above will remove the comments.

If you are moving around, the plugin allows you to repeat the forward or
reverse (opposite to the original) move. For example, if you searched for the 
next function like::

   fpf 

Then ``<C-l>`` repeats that same command for you and moves you in the same 
direction. If you want to go in the opposite movement, then ``<C-h>`` is your
friend.


3. License                             
==============================================================================

MIT
Copyright (c) 2010-2011 Alfredo Deza <alfredodeza [at] gmail [dot] com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

4. Bugs                               
==============================================================================

If you find a bug please post it on the issue tracker:
https://github.com/alfredodeza/chapa.vim/issues

5. Credits                           
==============================================================================

A lot of the code for this plugin was adapted/copied from python.vim 
and python_fn.vim authored by Jon Franklin and Mikael Berthe. 

