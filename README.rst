Chapa
=====
A very simple VIM plugin to visually select a Function or a Class

Simple approach to visual selection of Python blocks.

Installation couldn't be easier: drop the plugin file in your vim plugin 
directory.

I would highly recommend you use something like Pathogen though, it 
makes dealing with VIM plugins way easier.

1. Intro                                 
==============================================================================

After trying other plugins that were supposed to achieve this objective (and 
fail) I decided to write it on my own. 

The initial approach is to be able to simply have a visual selection of a 
Python Class or Function.

No need to have VIM compiled with Python support since this plugin uses 
pure VIM syntax.

2. Usage                                
==============================================================================

Straightforward (for now). Chapa has 8 public calls that you can map to 
anything you want. 

You can map those callables to anything you want, but below is how the 
author maps them (better mnemonics)::

  " Function Movement
  nnoremap fpf <Esc>:ChapaNextFunction<CR>
  nnoremap Fpf <Esc>:ChapaPreviousFunction<CR>

  " Class Movement
  nnoremap fpc <Esc>:ChapaNextClass<CR>
  nnoremap Fpc <Esc>:ChapaPreviousClass<CR>

  " Method Movement
  nnoremap fpm <Esc>:ChapaNextMethod<CR>
  nnoremap Fpm <Esc>:ChapaPreviousMethod<CR>

  " Class Visual Select
  nnoremap vapf <Esc>:ChapaVisualNextFunction<CR>
  nnoremap vapF <Esc>:ChapaVisualPreviousFunction<CR>

  " Method Visual Select
  nnoremap vapm <Esc>:ChapaVisualNextMethod<CR>
  nnoremap vapM <Esc>:ChapaVisualPreviousMethod<CR>


If the requested search (function, class or method) is not found, the call simply 
returns and nothing should happen. However, there is an error message that should 
display by default, explaining what it was supposed to search and in what 
direction.

You can disable this by adding a chapa-specific variable in your vimrc::

  let g:chapa_messages = 0


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

