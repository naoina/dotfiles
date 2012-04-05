syn match   myPythonOperator  '\(==\|!=\|>=\|<=\|>\|<\|=\)' skipwhite
syn match   myPythonParen     '\((\|)\|{\|}\|\[\|\]\)' skipwhite
hi def link myPythonOperator  Operator
hi def link myPythonParen     Delimiter
hi link pythonBuiltin Statement
