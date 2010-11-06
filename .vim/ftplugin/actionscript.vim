if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo-=C

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

let b:undo_ftplugin = "setl fo< com< cms<"

let &cpo = s:cpo_save
unlet s:cpo_save
