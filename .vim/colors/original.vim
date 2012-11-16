set background=dark

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'original'

hi Normal       guifg=gray      guibg=black
hi LineNr       guifg=#ff005f
hi String       guifg=#af0000
hi Identifier   guifg=#00afaf
hi CursorLine                   guibg=#1c1c1c gui=none
hi Pmenu                        guibg=#1c1c1c
hi PmenuSel                     guibg=#303030 gui=bold
hi Visual                                     gui=reverse
hi SpecialKey   guifg=#0000d7
hi NonText      guifg=#262626
hi Search       guifg=gray      guibg=#5f00af gui=bold
hi Todo         guifg=#080808   guibg=#ffff00 gui=bold
hi Comment      guifg=#00afd7
hi Statement    guifg=#00d700                 gui=bold
hi Constant     guifg=#00d700                 gui=bold
hi Type         guifg=#00d700                 gui=none
hi Function     guifg=#afd75f                 gui=none
hi Folded       guifg=#6c6c6c   guibg=bg      gui=bold
hi Include      guifg=#af00af
hi Special      guifg=#af00af
hi Delimiter    guifg=#af00af
hi Define       guifg=#af00af                 gui=none
hi Structure    guifg=#00af5f                 gui=none
hi StatusLine                                 gui=reverse
hi StatusLineNC                               gui=reverse,bold
hi SignColumn                   guibg=black

hi link Number      String
hi link Boolean     Keyword
hi link Operator    Statement
hi link Conditional Statement
