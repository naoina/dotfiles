syn match   myJavaScriptOperator  '\(==\|!=\|>=\|<=\|>\|<\|=\)' skipwhite
syn match   myjavaScriptParens  '[()]'
hi def link myJavaScriptOperator  Operator

hi link myJavaScriptParens      Delimiter
hi link javaScriptFunction      Keyword
hi link javaScriptIdentifier    Function
hi link javaScriptValue         Number
