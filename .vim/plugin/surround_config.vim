" This file is to define user-defined surrounding objects, especially for the
" objects which contain multibyte characters.  Originally I put these
" definitions in ~/.vimrc, but multibyte strings will be broken whenever
" 'encoding' is changed.  So I moved the definitions into this file.
scriptencoding utf-8  " for &encoding != 'utf-8' environments
if !(exists('g:loaded_surround') && exists('*SurroundRegister'))
  " Skip if the loaded plugin is not a modified version of the following:
  " http://github.com/kana/config/tree/master/vim/dot.vim/plugin/surround.vim
  finish
endif

let g:surround_indent = 1

" for XML.
call SurroundRegister('g', '&', "&lt;\r&gt;")
call SurroundRegister('g', 'C', "<![CDATA[\r]]>")

" for C like languages.
call SurroundRegister('g', 'if', "if (/*cond*/) {\n\r\n}")
call SurroundRegister('g', 'while', "while (/*cond*/) {\n\r\n}")
call SurroundRegister('g', 'for', "for (/*cond*/) {\n\r\n}")
call SurroundRegister('g', 'tc', "try {\n\r\n} catch (/*Exception*/) {\n// TODO\n}")
call SurroundRegister('g', 'tf', "try {\n\r\n} finally {\n// TODO\n}")


" __END__
