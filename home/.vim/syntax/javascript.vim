syn match   myJavaScriptOperator  '\(==\|!=\|>=\|<=\|>\|<\|=\)' skipwhite
syn match   myJavaScriptParen  '[()]' skipwhite
hi def link myJavaScriptOperator  Operator

hi link javaScriptParens    Delimiter
hi link javaScriptFunction      Keyword
hi link javaScriptIdentifier    Function
hi link javaScriptValue         Number
