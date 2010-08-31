" Vim indent file
" Language:     Haskell 98
" Maintainer:   Naoya Inada <naoina@kushinada.org>
" Last Changed: 2009-03-07

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal expandtab
setlocal nolisp
setlocal softtabstop=4 shiftwidth=4
setlocal nosmartindent
setlocal noautoindent
setlocal indentexpr=GetHaskellIndent()
setlocal indentkeys=o,0=else,0=where,0=let,0=in,0\|,0\],0),0}

function! s:FindPair(pstart, pmid, pend)
  call search(a:pend, 'bW')
  return indent(searchpair(a:pstart, a:pmid, a:pend, 'bW', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"'))
endfunction

function! s:FindLet(pstart, pmid, pend)
  call search(a:pend, 'bW')
  return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment" || getline(".") =~ "^\\s*let\\>.*=.*\\<in\\s*$" || getline(prevnonblank(".") - 1) =~ s:beflet'))
endfunction

function! GetHaskellIndent()
  " Find a non-blank line above the current line.
  let lnum = prevnonblank(v:lnum - 1)

  " At the start of the file use zero indent.
  if lnum == 0
    return 0
  endif

  let ind = indent(lnum)
  let lline = getline(lnum)  " At newline
  let line = getline(v:lnum) " At current line


  if line =~ '^\s*}'
    return s:FindPair('{', '', '}')

  elseif line =~ '^\s*\]'
    return s:FindPair('\[', '', '\]')

  elseif line =~ '^\s*)'
    return s:FindPair('(', '', ')')

  elseif line =~ '^\s*|'
    if lline !~ '\['
      return match(lline, '|')
    endif

  elseif line =~ '^\s*where\>'
    return ind + &sw

  elseif line =~ '^\s*in\>'
    if lline !~ '^\s*let\>'
      return s:FindPair('\<let\>', '', '\<in\>')
    endif

  elseif line =~ '^\s*else\>'
    return s:FindPair('\<then\>', '', '\<else\>')

  elseif line =~ '^\s*then\>'
    if lline !~ '^\s*\(if\|else\)\>'
      return s:FindPair('\<if\>', '', '\<then\>')
    endif

  elseif line =~ '^\s*\zs[,]'
    return ind + &sw

  endif


  if lline =~ '^\s*where\>'
    let ind = ind + &sw / 2

  elseif lline =~ '^\s*case\s\+.*\zsof'
    let ind = ind + &sw + 1

  elseif lline =~ '\<\(if\|else\|do\>\|\(module\s\+.*\)\@\<!where\|case\s\+.*\zsof\|let\|in\s*$\)\|\(=\|->\|(\)\s*$'
    let ind = ind + &sw

  elseif lline =~ '^\s*\(|.*=\|in\).*$'
    let ind = 0

  elseif lline =~ '\[' && lline !~ '\]'
      let ind = ind + &sw

  elseif lline =~ '{' && lline !~ '}'
      let ind = ind + &sw

  elseif lline =~ '\<in\s*$' && lline !~ '^\s*in\>'
    let ind = s:FindPair('\<let\>', '', '\<in\>')

  elseif lline =~ '}\s*$'
    let ind = s:FindPair('{', '', '}')

  elseif lline =~ '\]\s*$'
    let ind = s:FindPair('\[', '', '\]')

  elseif lline =~ '\-}\s*$'
    call search ('\-}', 'bW')
    let ind = indent(searchpair('{\-', '', '\-}', 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'))

  elseif lline =~ ')\s*$'
    let ind = s:FindPair('(', '', ')')

  elseif lline =~ '^\s*{-' && line =~ '^\s*-'
    let ind = ind + 1

  endif

  return ind

endfunction " End of GetHaskellIndent()
