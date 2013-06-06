syn match   myPythonOperator  '\(==\|!=\|>=\|<=\|>\|<\|=\|+=\|-=\|/=\|*=\|&=\|\^=\||=\)' skipwhite
syn match   myPythonParen     '\((\|)\|{\|}\|\[\|\]\)' skipwhite
hi def link myPythonOperator  Operator
hi def link myPythonParen     Delimiter
hi def link myPythonSelf      Identifier
hi link pythonBuiltin Statement

" for python-mode
hi link pythonPreCondit Include
syn keyword pythonStatement with as
syn keyword myPythonSelf self cls
