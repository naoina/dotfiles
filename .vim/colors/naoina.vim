hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'naoina'

if &background == "light"
  hi! Normal       guifg=#000000   guibg=#ffffff
  hi! LineNr       guifg=#ff005f
  hi! String       guifg=#d70000
  hi! Identifier   guifg=#00afaf
  hi! CursorLine                   guibg=#d7ffff gui=none
  hi! Pmenu        guifg=#a8a8a8   guibg=#eeeeee
  hi! PmenuSel     guifg=#8700af   guibg=#eeeeee gui=bold
  hi! Visual                                     gui=reverse
  hi! SpecialKey   guifg=#0000d7
  hi! NonText      guifg=#87ffff
  hi! Search       guifg=#e4e4e4   guibg=fg      gui=bold
  hi! Todo         guifg=#080808   guibg=#ffff00 gui=bold
  hi! Comment      guifg=#00afd7
  hi! Statement    guifg=#000087
  hi! Constant     guifg=#00d700                 gui=bold
  hi! Type         guifg=#00d700                 gui=none
  hi! Function     guifg=#005fff
  hi! Folded       guifg=#c6c6c6   guibg=bg      gui=bold
  hi! Include      guifg=#8700af
  hi! Special      guifg=#8700af
  hi! Delimiter    guifg=#8700af
  hi! Define       guifg=#8700af
  hi! Structure    guifg=#00af5f                 gui=none
  hi! StatusLine   guifg=#949494                 gui=bold
  hi! StatusLineNC guifg=gray                    gui=reverse,bold
  hi! SignColumn                   guibg=bg

  hi! link Number      String
  hi! link Boolean     Keyword
  hi! link Operator    Statement
  hi! link Conditional Statement

  " for vim-indent-guides
  hi! IndentGuidesOdd              guibg=#eeeeee
  hi! IndentGuidesEven             guibg=#dadada
else  " background == 'dark'
  hi! Normal       guifg=gray      guibg=#000000
  hi! LineNr       guifg=#ff005f
  hi! String       guifg=#af0000
  hi! Identifier   guifg=#00afaf
  hi! CursorLine                   guibg=#1c1c1c gui=none
  hi! Pmenu                        guibg=#1c1c1c
  hi! PmenuSel                     guibg=#303030 gui=bold
  hi! Visual                                     gui=reverse
  hi! SpecialKey   guifg=#0000d7
  hi! NonText      guifg=#262626
  hi! Search       guifg=gray      guibg=#5f00af gui=bold
  hi! Todo         guifg=#080808   guibg=#ffff00 gui=bold
  hi! Comment      guifg=#00afd7
  hi! Statement    guifg=#00d700                 gui=bold
  hi! Constant     guifg=#00d700                 gui=bold
  hi! Type         guifg=#00d700                 gui=none
  hi! Function     guifg=#afd75f                 gui=none
  hi! Folded       guifg=#6c6c6c   guibg=bg      gui=bold
  hi! Include      guifg=#af00af
  hi! Special      guifg=#af00af
  hi! Delimiter    guifg=#af00af
  hi! Define       guifg=#af00af                 gui=none
  hi! Structure    guifg=#00af5f                 gui=none
  hi! StatusLine                                 gui=reverse
  hi! StatusLineNC                               gui=reverse,bold
  hi! SignColumn                   guibg=#000000

  hi! link Number      String
  hi! link Boolean     Keyword
  hi! link Operator    Statement
  hi! link Conditional Statement

  " for vim-indent-guides
  hi! IndentGuidesOdd              guibg=#303030
  hi! IndentGuidesEven             guibg=#121212
endif
