syntax on
filetype plugin indent on

let $VIMLOCAL = $HOME . '/.vim'

colorscheme desert

set t_Co=256

hi LineNr     ctermfg=197
hi Constant   ctermfg=3
hi String     ctermfg=darkred
hi Identifier ctermfg=37
hi Pmenu      ctermbg=234
hi PmenuSel   ctermbg=236 cterm=bold
hi Function   ctermfg=yellow
hi Visual     cterm=reverse
hi SpecialKey ctermfg=darkblue
hi NonText    ctermfg=235
hi CursorLine ctermbg=233 cterm=none
hi Search     ctermfg=grey ctermbg=55 cterm=bold

hi link Number  String
hi link Boolean keyword

hi xmlTag ctermfg=37 cterm=bold
hi link xmlTagName xmlTag
hi link xmlEndTag  xmlTag
hi link htmlTag    xmlTag

hi FullwidthSpace ctermbg=235

match FullwidthSpace /　/

runtime macros/matchit.vim
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()


set backupdir=$VIMLOCAL/backup
set directory=$VIMLOCAL/swap

set backup
set viminfo='1000,<500,f1
set backspace=indent,eol,start
set list
set listchars=tab:>-,eol:$
set nocompatible
set number
set hidden
set hlsearch
" set incsearch
set ignorecase smartcase
set laststatus=2
set nowrapscan
set showcmd
" set visualbell
set shortmess+=Iw
set iminsert=1
set cinkeys+=;
set ambiwidth=double
set foldopen=block,hor,jump,mark,percent,quickfix,search,tag,undo
set foldlevel=99
set browsedir=buffer
set grepprg=grep\ -nH
set writeany

setlocal cursorline
au WinEnter,BufEnter * setlocal cursorline
au WinLeave,BufLeave * setlocal nocursorline
au QuickFixCmdPost vimgrep cw

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
au FileType * setlocal formatoptions+=cqmM

set statusline=%<[%n]\ %F\ %h%r%m[%{&fenc}][%{&ff=='unix'?'LF':&ff=='dos'?'CRLF':'CR'}]\ %=[0x%B]\ %c,%l/%L\ %y

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,japan,sjis,utf-8
set fileformat=unix
set fileformats=unix,dos,mac

" Mappings.
noremap j  gj
noremap k  gk
noremap gj j
noremap gk k
" noremap 0  ^
" noremap ^  0
noremap '  `
noremap `  '
" noremap J  gJ
" noremap gJ J
nnoremap gc `[v`]
vnoremap gc :<C-u>normal gc<CR>
onoremap gc :<C-u>normal gc<CR>
nnoremap <C-s> <Nop>
inoremap <C-s> <Nop>
noremap  <C-o> o<ESC><UP>
noremap  <C-j> <C-w>w
noremap  <C-k> <C-w>W
nnoremap <silent><C-l> :nohl<CR>:redr!<CR>
inoremap <silent><C-l> <C-o>:nohl<CR><C-o>:redr!<CR>
nnoremap <SPACE> za
nnoremap <silent><C-n> :bn<CR>
nnoremap <silent><C-p> :bN<CR>
nnoremap <silent><C-d> :bw!<CR>
noremap! <C-a> <HOME>
noremap! <C-e> <END>
noremap! <C-f> <RIGHT>
noremap! <C-b> <LEFT>
nnoremap ,t :!(cd %:p:h;ctags *)<CR>
nnoremap <C-]> g<C-]>
nnoremap <silent>yu :%y +<CR>

" reload with encoding.
command! EncUTF8      e ++enc=utf-8
command! EncSJIS      e ++enc=cp932
command! EncISO2022JP e ++enc=iso-2022-jp
command! EncEUCJP     e ++enc=euc-jp

" diff mode mappings.
if &diff
  nmap     <silent><C-l> :diffupdate<CR>
  nnoremap <silent><C-d> :diffget<CR>
  nnoremap <silent><C-n> ]czz
  nnoremap <silent><C-p> [czz
  nnoremap <silent>ZZ    :wqall!<CR>
  nnoremap <silent>ZQ    :qall!<CR>
endif

" Auto restore last cursor position.
au BufReadPost * if &fenc=="sjis" || &fenc=="cp932" | silent! %s/¥/\\/g | endif
au BufReadPost * normal '"

au BufEnter * exec "lcd " . expand("%:p:h")

"actionscript,mxml setting.
au BufNewFile,BufRead *.as      setlocal filetype=actionscript
au BufNewFile,BufRead *.mxml    setlocal filetype=mxml

au BufNewFile,BufRead *.inc     setlocal filetype=php
au BufNewFile,BufRead *.snip    setlocal filetype=snippet

" For timestamp, script_id=923.
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[mM]odified)\s*:\s+)@<=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4}|TIMESTAMP'
let timestamp_rep    = '%F %T %z'

" For NERD_commenter, script_id=1218.
" let NERDCreateDefaultMappings = 0
let NERDSpaceDelims = 1
nmap <C-_> <Plug>NERDCommenterInvert
vmap <C-_> <Plug>NERDCommenterInvert
imap <C-_> <C-o><Plug>NERDCommenterInvert

" For xmledit, script_id=301.
let xml_use_xhtml = 1

" For autocomplpop, script_id=1879.
let g:acp_enableAtStartup = 0
let g:acp_behaviorKeywordLength = 2
let g:acp_ignorecaseOption = 0

" For neocomplcache, script_id=2620
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_min_keyword_length = 4
let g:neocomplcache_min_syntax_length  = 4
let g:neocomplcache_auto_completion_start_length = 1
let g:neocomplcache_enable_ignore_case = 1
let g:neocomplcache_enable_smart_case  = 1
let g:neocomplcache_temporary_dir = $VIMLOCAL . '/cache'
let g:neocomplcache_snippets_dir  = $VIMLOCAL . '/snippet'
imap <expr><Tab> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<Tab>"
smap <expr><Tab> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<Tab>"

" For unite
let g:unite_temporary_directory = $VIMLOCAL . '/cache'

" For yankring, script_id=1234.
let g:yankring_history_dir    = $VIMLOCAL . '/cache'
let g:yankring_history_file   = "yankring_history"
let g:yankring_replace_n_pkey = ''
let g:yankring_replace_n_nkey = ''
noremap <Leader>p :YRShow<CR>

" For ShowMarks, script_id=152
let g:showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
hi SignColumn   ctermbg=NONE guibg=NONE
hi ShowMarksHLl cterm=bold ctermfg=20
hi ShowMarksHLu cterm=bold ctermfg=20
hi ShowMarksHLo cterm=bold ctermfg=20
hi ShowMarksHLm cterm=bold ctermfg=20

" For quickfun
let g:quickrun_config = {
      \ '*': {
      \   'split': 'vertical 50',
      \ },
\}

" For ctags.
set tags=tags;

" For qbuf, script_id=1910
let g:qb_hotkey = ",<SPACE>"
au VimEnter * exec "cunmap " . g:qb_hotkey

" Simplicity flymake.
function! s:flymake_run(cmd, prg, fmt)
  let save_mp  = &makeprg
  let save_efm = &errorformat

  exec "set makeprg=" . a:prg
  exec "set errorformat=" . a:fmt

  exec a:cmd

  let &makeprg = save_mp
  let &errorformat = save_efm
  unlet save_mp
  unlet save_efm
endfunction

function! s:flymake_make(prg, fmt, opt)
  let &makeef = &directory . "/" . expand("%:t") . ".makeef"

  if a:opt != ""
    exec a:opt
  endif

  exec "au BufWritePost <buffer> call s:flymake_run('silent make! | cw 3', '" . a:prg . "', '" . a:fmt . "')"
  au QuickFixCmdPost <buffer> call s:flymake_highlight()
endfunction

function! s:flymake_highlight()
  hi ErrorLine ctermfg=white ctermbg=darkred

  if exists("b:flymakematchid")
    call matchdelete(b:flymakematchid)
    unlet b:flymakematchid
  endif

  let ignore_fmt = ["m", "f", "s"]

  for line in readfile(&makeef)
    let fmt = &errorformat
    for c in ignore_fmt
      let fmt = substitute(fmt, "%" . c, '\\%(.*\\)', "g")
    endfor

    let fmt = substitute(fmt, "%l", '\\(\\d\\+\\)', "")
    let lno = substitute(line, fmt, '\1', "")

    let b:flymakematchid = matchadd("ErrorLine", '\%' . lno . "l.*")
  endfor
endfunction

augroup MyAutoCmd
  au!
augroup End

au MyAutoCmd FileType ruby call s:flymake_make('ruby\ -c\ %', "%f:%l:%m", 'setlocal shellpipe=1>/dev/null\ 2>')
au MyAutoCmd FileType php  call s:flymake_make('php\ -lq\ %', '%s\ error:\ %m\ in\ %f\ on\ line\ %l', 'setlocal shellpipe=1>/dev/null\ 2>')


" Filetypes setting
function! s:python_setting()
  setlocal tabstop=8 softtabstop=4 shiftwidth=4
  setlocal textwidth=80
  setlocal expandtab
endfunction

function! s:php_setting()
  setlocal include=
endfunction

function! s:html_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal expandtab
endfunction

function! s:snippet_setting()
  setlocal noexpandtab
  sunmap <Tab>
  iunmap <Tab>
endfunction

function! s:setting()
  let f = "s:" . &ft . "_setting()"
  if exists("*" . f)
    exec "call " . f
  endif
endfunction

au MyAutoCmd FileType * call s:setting()

" vim: set ft=vim sw=2 :
