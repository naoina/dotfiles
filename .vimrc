syntax on

let g:author = "Naoya Inada"
let g:email  = "naoina@kuune.org"

let $VIMLOCAL = expand('~/.vim')

filetype off

if has('vim_starting')
  set runtimepath+=$VIMLOCAL/bundle/neobundle.vim

  call neobundle#rc($VIMLOCAL . '/bundle')
endif

" NeoBundle 'git://github.com/Shougo/neocomplcache.git'
NeoBundle 'git://github.com/naoina/neocomplcache.git', {'type': 'nosync'}
" NeoBundle 'git://github.com/Shougo/neocomplcache-snippets-complete.git'
NeoBundle 'git://github.com/naoina/neocomplcache-snippets-complete.git', {'type': 'nosync'}
NeoBundle 'git://github.com/Shougo/neobundle.vim.git'
NeoBundle 'git://github.com/Shougo/unite.vim.git'
NeoBundle 'git://github.com/ujihisa/unite-colorscheme.git'
NeoBundle 'git://github.com/h1mesuke/unite-outline.git'
NeoBundle 'git://github.com/Shougo/vimproc.git'
NeoBundle 'git://github.com/thinca/vim-quickrun.git'
NeoBundle 'git://github.com/scrooloose/nerdcommenter.git'
NeoBundle 'git://github.com/Shougo/vimshell.git'
NeoBundle 'git://github.com/kana/vim-surround.git'
NeoBundle 'git://github.com/tpope/vim-fugitive.git'
NeoBundle 'git://github.com/thinca/vim-template.git'
NeoBundle 'git://github.com/scrooloose/syntastic.git'
NeoBundle 'https://bitbucket.org/anyakichi/vim-csutil'
NeoBundle 'git://github.com/mattn/gist-vim.git'
NeoBundle 'git://github.com/cespare/mxml.vim.git'
NeoBundle 'git://github.com/kakkyz81/evervim.git'
NeoBundle 'git://github.com/othree/html5.vim.git'
NeoBundle 'git://github.com/Rykka/ColorV.git'
NeoBundle 'git://github.com/mattn/webapi-vim.git'
NeoBundle 'git://github.com/klen/python-mode.git'
NeoBundle 'git://github.com/tpope/vim-rails.git'
NeoBundle 'git://github.com/vim-scripts/mako.vim.git'
NeoBundle 'git://github.com/vim-scripts/mako.vim--Torborg.git'
NeoBundle 'git://github.com/alfredodeza/pytest.vim.git'
NeoBundle 'git://github.com/jiangmiao/simple-javascript-indenter.git'

" for colorschemes
NeoBundle 'git://github.com/godlygeek/csapprox.git'
NeoBundle 'git://github.com/altercation/vim-colors-solarized.git'
NeoBundle 'git://github.com/vim-scripts/Mahewincs.git'
NeoBundle 'git://github.com/vim-scripts/vombato-colorscheme.git'

filetype plugin indent on

set t_Co=256
colorscheme original

hi FullwidthAndEOLSpace guibg=#262626
match FullwidthAndEOLSpace "\(　\|\s\)\+$"

runtime macros/matchit.vim

set backupdir=$VIMLOCAL/backup
set directory=$VIMLOCAL/swap
let s:cachedir = $VIMLOCAL . '/cache'

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
set ignorecase
set smartcase
set laststatus=2
set nowrapscan
set showcmd
" set visualbell
set shortmess+=Iw
set iminsert=1
set cinkeys+=;
set ambiwidth=double
set foldopen=block,hor,jump,mark,percent,quickfix,search,tag,undo
set foldlevel=0
set browsedir=buffer
set grepprg=grep\ -nH
set writeany
set pastetoggle=<F9>
" set clipboard=unnamed
set tags=tags;

setlocal cursorline
au WinEnter,BufEnter * setlocal cursorline
au WinLeave,BufLeave * setlocal nocursorline
au QuickFixCmdPost vimgrep cw

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
au FileType * setlocal formatoptions+=cqmM

set statusline=%<[%n]%{fugitive#statusline()}\ %F\ %h%r%m[%{&fenc}][%{&ff=='unix'?'LF':&ff=='dos'?'CRLF':'CR'}]\ %=[0x%B]\ %c,%l/%L\ %y

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,japan,sjis,utf-8
set fileformat=unix
set fileformats=unix,dos,mac

" reload with encoding.
command! EncUTF8      e ++enc=utf-8
command! EncSJIS      e ++enc=cp932
command! EncISO2022JP e ++enc=iso-2022-jp
command! EncEUCJP     e ++enc=euc-jp

function! s:do_vcs_diff_aware_gf(command)
  let target_path = expand('<cfile>')
  if target_path =~# '^[ab]/'  " with a peculiar prefix of diff of VCS
    if filereadable(target_path) || isdirectory(target_path)
      return a:command
    else
      " BUGS: Side effect - Cursor position is changed.
      let [_, c] = searchpos('\f\+', 'cenW')
      return c . '|' . 'v' . (len(target_path) - 2 - 1) . 'h' . a:command
    endif
  else
    return a:command
  endif
endfunction

function! s:mkdir(dir, perm)
  if !isdirectory(a:dir)
    call mkdir(a:dir, "p", a:perm)
  endif
endfunction

function! s:generate_all_tags()
  let answer = confirm("Does generate tags file?", "&yes\n&no", 2, "Question")
  let ctags_cmd = 'ctags ' . (&ignorecase ? '--sort=foldcase' : '')

  " terminate or no
  if answer == 0 || answer == 2
    echo 'Does not generate.'
    return
  endif

  if executable("ctags") != 1
    echo "ctags not found."
    return
  endif

  let b:tagsdir = tagfiles() == [] ? getcwd() : fnameescape(fnamemodify(get(tagfiles(), -1, ""), ":p:h"))

  " generate
  redraw! | echo 'Generating...'
  exec 'silent cd ' . b:tagsdir
  call vimproc#system(ctags_cmd . ' ' . (exists('g:ctags_opts') ? g:ctags_opts : '') . ' -R .')
  echo 'Done.'
endfunction

function! s:clear_undo()
  let old_undolevels = &undolevels
  setlocal undolevels=-1
  exec "normal a \<BS>\<Esc>"
  let &undolevels = old_undolevels
  unlet old_undolevels

  setlocal nomodified
endfunction

function! s:autocd()
    let dir = fnameescape(expand('%:p:h'))
    if isdirectory(dir)
        lcd `=dir`
    endif
endfunction

call s:mkdir(&directory, 0700)
call s:mkdir(&backupdir, 0700)
call s:mkdir(s:cachedir, 0700)

au BufReadPost * if &fenc=="sjis" || &fenc=="cp932" | silent! %s/¥/\\/g | call s:clear_undo() | endif

" Auto restore last cursor position.
au BufReadPost * normal '"

au BufEnter * call s:autocd()
au CursorMovedI * if pumvisible() == 0|pclose|endif

command! GenerateAllTags call s:generate_all_tags()

" For gist-vim
let [g:github_user, g:github_token] = readfile($VIMLOCAL . '/.github.token')
let g:gist_detect_filetype = 1
let g:gist_private = 0

" For csutil
let g:csutil_no_mappings = 1

" For syntastic.
" let g:syntastic_auto_loc_list = 1
let g:syntastic_quiet_warnings = 0
let g:syntastic_mode_map = {
  \ 'mode': 'active',
  \ 'passive_filetypes': ['java'],
\}

" For vim-template.
let g:template_basedir = $VIMLOCAL . '/templates'
let g:template_files = '**'
let g:template_free_pattern = 'skel-\?'
let g:comment_oneline_only_ft = {
    \ 'python': 1,
    \ 'ruby': 1,
    \ 'sh': 1,
    \ }
autocmd User plugin-template-loaded call s:template_keywords()
function! s:template_keywords()
  let firstline = search("@LICENSE@", "cnW")
  if firstline != 0
    let license = readfile(g:template_basedir . '/LICENSE')
    let lastline = firstline + len(license)
    let type = has_key(g:comment_oneline_only_ft, &ft) ? 'AlignLeft' : 'Sexy'

    %s/@LICENSE@/\=license/ge
    execute firstline . "," . lastline . 'call NERDComment("n", "' . type . '")'
    unlet license
  endif

  %s/@AUTHOR@/\=g:author/ge
  %s/@EMAIL@/\=g:email/ge
  %s/@YEAR@/\=strftime('%Y')/ge
  %s/@FILE@/\=expand('%:t:r')/ge

  call cursor(1, 0)
  if search('<CURSOR>', 'c')
    normal! "_da<zz
  endif

  " clear undo
  let old_undolevels = &undolevels
  setlocal undolevels=-1
  exec "normal a \<BS>\<Esc>"
  let &undolevels = old_undolevels
  unlet old_undolevels
  setlocal nomodified
endfunction

" For timestamp, script_id=923.
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[mM]odified)\s*:\s+)@<=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4}|TIMESTAMP'
let timestamp_rep    = '%F %T %z'

" For NERD_commenter, script_id=1218.
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDDefaultNesting = 0

" For xmledit, script_id=301.
let xml_use_xhtml = 1

" For autocomplpop, script_id=1879.
let g:acp_enableAtStartup = 0
let g:acp_behaviorKeywordLength = 2
let g:acp_ignorecaseOption = 0

" For neocomplcache, script_id=2620
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_auto_select = 1
let g:neocomplcache_min_keyword_length = 4
let g:neocomplcache_min_syntax_length  = 4
let g:neocomplcache_auto_completion_start_length = 1
let g:neocomplcache_enable_ignore_case = 1
let g:neocomplcache_enable_smart_case  = 1
let g:neocomplcache_temporary_dir = s:cachedir
let g:neocomplcache_snippets_dir  = $VIMLOCAL . '/snippet'
let g:neocomplcache_snippets_disable_runtime_snippets = 1
let g:neocomplcache_enable_prefetch = 1
let g:neocomplcache_force_overwrite_completefunc = 1
" let g:neocomplcache_enable_debug = 1

" For unite
let g:unite_data_directory = s:cachedir
let g:unite_update_time = 100
let g:unite_enable_split_vertically = 1
let g:unite_winwidth = 60
let g:unite_winheight = 8
let g:unite_split_rule = "botright"
let g:unite_source_history_yank_enable = 1
" let g:unite_enable_start_insert = 1

function! s:unite_setting()
  if exists("b:did_unite_setting") && b:did_unite_setting
    return
  endif
  let b:did_unite_setting = 1

  nmap <buffer><Esc> <Plug>(unite_exit)
  imap <buffer><Esc> <Plug>(unite_exit)
endfunction

" For vimshell
let g:vimshell_temporary_directory = s:cachedir
let g:vimshell_prompt = "[" . $USER . "@" . hostname() . "(" . substitute(system('uname -m'), "\n", "", "") . ")]% "
let g:vimshell_user_prompt = "'[' . substitute(getcwd(), $HOME, '~', '') . ']'"

function! s:vimshell_setting()
    if exists('b:did_vimshell_setting') && b:did_vimshell_setting
        return
    endif
    let b:did_vimshell_setting = 1
endfunction

" For quickfun
let g:quickrun_config = {
      \ '*': {
      \   'split': 'vertical 50',
      \ },
\}

" For python-mode
let g:pymode_run = 0
let g:pymode_doc = 0
let g:pymode_lint = 0
let g:pymode_folding = 0
let g:pymode_utils_whitespaces = 0

" For simple-javascript-indenter
let g:SimpleJsIndenter_BriefMode = 1

function! s:refresh()
  let save_ar = &autoread
  setlocal autoread
  redr! | checktime
  let &autoread = save_ar
  unlet save_ar
endfunction
command! Refresh :call s:refresh()

function! s:tohtml_and_browse()
  TOhtml
  let webbrowser = 'chromium'
  let tempfile = tempname()
  write `=tempfile`
  exec "!" . webbrowser . " " . tempfile
  bdelete!
  call delete(tempfile)
endfunction
command! TOhtmAndBrowse :call s:tohtml_and_browse()

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
  let &makeef = &directory . "/" . fnameescape(expand("%:t")) . ".makeef"

  if a:opt != ""
    exec a:opt
  endif

  hi ErrorLine ctermfg=white ctermbg=darkred

  exec "au BufWritePost <buffer> call s:flymake_run('silent make! | cw 3', '" . a:prg . "', '" . a:fmt . "')"
  au QuickFixCmdPost <buffer> call s:flymake_highlight()
  hi ErrorSign ctermfg=red cterm=bold
  sign define error_flymake text=!! texthl=ErrorLine
endfunction

function! s:flymake_highlight()
  let offset = 10032
  if exists("b:flymakematchids")
    for matchid in b:flymakematchids
      call matchdelete(matchid)
      exec "sign unplace " . (offset + matchid)
    endfor
    unlet b:flymakematchids
  endif

  let b:flymakematchids = []
  for line in readfile(&makeef)
    " hilight error line
    let lno = s:flymake_take_by_regex(line, "l", '\\d\\+')
    let matchid = matchadd("ErrorLine", '\%' . lno . "l.*")
    call add(b:flymakematchids, matchid)

    " put error sign
    let fname = s:flymake_take_by_regex(line, "f", '.*')
    exec "sign place " . (offset + matchid) . " line=" . lno . " name=error_flymake file=" . fname
  endfor
endfunction

function! s:flymake_take_by_regex(line, c, regex)
  let fmt = substitute(&errorformat, '%[^' . a:c . ']', '\\%(.*\\)', "g")
  return substitute(a:line, substitute(fmt, "%" . a:c, '\\(' . a:regex . '\\)', ""), '\1', "")
endfunction

function! s:colorv_autopreview()
  if exists(':ColorVAutoPreview')
    ColorVAutoPreview
  endif
endfunction

augroup MyAutoCmd
  au!
augroup End

" au MyAutoCmd FileType ruby call s:flymake_make('ruby\ -c\ %', "%f:%l:%m", 'setlocal shellpipe=1>/dev/null\ 2>')
" au MyAutoCmd FileType php  call s:flymake_make('php\ -lq\ %', '%s\ error:\ %m\ in\ %f\ on\ line\ %l', 'setlocal shellpipe=1>/dev/null\ 2>')


function! s:to_xxd()
  silent %!xxd -g 1
  setlocal ft=xxd
endfunction

function! s:from_xxd()
  %!xxd -r
endfunction

augroup BinaryMode
  au!
  au BufReadPost * if &binary | call s:to_xxd() | endif
  au BufWrite * if &binary | call s:from_xxd() | endif
  au BufWritePost * if &binary | call s:to_xxd() | setlocal nomodified | endif
augroup END


" Filetypes setting
au BufNewFile,BufRead *.as      setlocal filetype=actionscript
au BufNewFile,BufRead *.mxml    setlocal filetype=mxml

au BufNewFile,BufRead *.inc     setlocal filetype=php
au BufNewFile,BufRead *.snip    setlocal filetype=snippet
au BufNewFile,BufRead *.wsgi    setlocal filetype=python
au BufNewFile,BufRead *.mayaa   setlocal filetype=xml
au BufNewFile,BufRead *.scala   setlocal filetype=scala
au BufNewFile,BufRead *.mako    setlocal filetype=mako

function! s:txt_setting()
  setlocal textwidth=78
endfunction

function! s:help_setting()
  setlocal textwidth=78
  setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
  setlocal nosmarttab
endfunction

function! s:python_setting()
  setlocal tabstop=8 softtabstop=4 shiftwidth=4
  setlocal textwidth=79
  setlocal expandtab
  setlocal omnifunc=pythoncomplete#Complete
  nnoremap <silent><buffer>K :RopeShowDoc<CR>
  nnoremap <silent><buffer><C-]> :RopeGotoDefinition<CR>
  nnoremap <silent><buffer>F :RopeFindOccurrences<CR>

  if executable('py.test') && exists(':Pytest')
      nnoremap <silent><buffer><leader>f :Pytest method<CR>
      nnoremap <silent><buffer><leader>c :Pytest class<CR>
  endif

  " if executable("pep8")
    " call s:flymake_make('pep8\ -r\ %', '%f:%l:%c:\ %m', '')
  " endif
endfunction

function! s:mako_setting()
    call s:html_setting()
endfunction

function! s:php_setting()
  setlocal include=
  let g:ctags_opts = '--langmap=PHP:.php.inc.php4'
endfunction

function! s:html_setting()
  call s:xml_setting()
  call s:colorv_autopreview()
endfunction

function! s:snippet_setting()
  setlocal noexpandtab
  snoremap <buffer><Tab> <Tab>
  inoremap <buffer><Tab> <Tab>
endfunction

function! s:javascript_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal foldmethod=indent foldminlines=2
endfunction

function! s:actionscript_setting()
  setlocal dictionary=$VIMLOCAL/dict/actionscript3.dict
endfunction

function! s:c_setting()
  setlocal foldmethod=indent foldminlines=2 foldnestmax=1
endfunction

function! s:cpp_setting()
  setlocal foldmethod=indent foldminlines=2 foldnestmax=2
endfunction

function! s:java_setting()
  setlocal textwidth=100

  if exists(':EclimEnable')
    augroup EclimGroup
      au!
      au BufNewFile,BufRead <buffer> EclimEnable
    augroup End
    au BufWrite <buffer> JavaImportMissing
    au BufWritePost <buffer> JavaImportClean
    au BufWritePost <buffer> JavaImportSort
  else
    " javacomplete, script_id=1785
    setlocal omnifunc=javacomplete#Complete
    " conflict with neocomplcache.
    " setlocal completefunc=javacomplete#CompleteParamsInfo
  endif

  setlocal foldmethod=indent foldlevel=1 foldnestmax=2
endfunction

function! s:xml_setting()
  let g:xml_syntax_folding = 1
  setlocal foldmethod=syntax foldlevel=1
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal expandtab
endfunction

function! s:css_setting()
  setlocal foldmethod=indent
  call s:colorv_autopreview()
endfunction

function! s:scss_setting()
  call s:css_setting()
endfunction

function! s:mvn_pom_setting()
  augroup eclim_xml
    au!
  augroup End
endfunction

function! s:ruby_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  inoremap <Bar> <Bar><Bar><LEFT>
endfunction

function! s:eruby_setting()
  call s:ruby_setting()
endfunction

function! s:vim_setting()
  setlocal shiftwidth=2
  call s:colorv_autopreview()
endfunction

function! s:scala_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal cindent
endfunction

function! s:rst_setting()
  setlocal tabstop=3 softtabstop=3 shiftwidth=3
  setlocal cindent
endfunction

function! s:yaml_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal autoindent
endfunction

" For surround of kana's version.
function! s:c_surround()
  " For C like languages.
  call SurroundRegister('g', 'if', "if (/* cond */) {\n\r\n}")
  call SurroundRegister('g', 'while', "while (/*cond*/) {\n\r\n}")
  call SurroundRegister('g', 'for', "for (/*cond*/) {\n\r\n}")
  call SurroundRegister('g', 'tc', "try {\n\r\n} catch (/*Exception*/) {\n// TODO\n}")
  call SurroundRegister('g', 'tf', "try {\n\r\n} finally {\n// TODO\n}")
endfunction

function! s:cpp_surround()
  call s:c_surround()
endfunction

function! s:java_surround()
  call s:c_surround()
endfunction

function! s:php_surround()
  call s:c_surround()
endfunction

function! s:actionscript_surround()
  call s:c_surround()
endfunction

function! s:javascript_surround()
  call s:c_surround()
endfunction

function! s:python_surround()
  " template string must be double-quote.
  call SurroundRegister('b', 'te', "try:\n\r\nexcept Exception:\npass")
  call SurroundRegister('b', 'tf', "try:\n\r\nexcept Exception:\npass\nfinally:\npass")
  call SurroundRegister('b', 'if', "if cond:\n\r")
endfunction

function! s:mako_surround()
  call SurroundRegister('b', 'd', "<%def name=\"\">\n\r\n</%def>")
  call SurroundRegister('b', 'b', "<%block name=\"\">\n\r\n</%block>")
  call SurroundRegister('b', 'if', "% if cond:\n\r\n% endif")
  call SurroundRegister('b', 'for', "% for i in L:\n\r\n% endfor")
endfunction

function! s:call_if_exists(funcname)
  if exists("*" . a:funcname)
    exec "call " . a:funcname
  endif
endfunction

function! s:setting()
  let prefix = "s:" . &ft

  let f = prefix . "_setting()"
  call s:call_if_exists(f)

  " For surround of kana's version.
  if exists("*SurroundRegister")
    let g:surround_indent = 1

    let f = prefix . "_surround()"
    call s:call_if_exists(f)
  endif
endfunction

function! s:setting4like_c()
  inoremap {<CR> {<CR>}<C-o><S-o>
endfunction

au MyAutoCmd FileType c,cpp,java,javascript,php,actionscript call s:setting4like_c()
au MyAutoCmd FileType * call s:setting()

" Mappings.
noremap Q <Nop>
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
" noremap  <C-m> o<ESC><UP>
noremap  <C-j> <C-w>w
noremap  <C-k> <C-w>W
nnoremap <silent><C-l> :nohls<CR>:Refresh<CR>
inoremap <silent><C-l> <C-o>:nohls<CR><C-o>:Refresh<CR>
nnoremap <SPACE> za
nnoremap <silent><expr><C-n> len(filter(range(1, winnr('$')), 'getbufvar(winbufnr(v:val), "&buftype") == "quickfix"')) ? ":\<C-u>cn\<CR>" : ":\<C-u>bn\<CR>"
nnoremap <silent><expr><C-p> len(filter(range(1, winnr('$')), 'getbufvar(winbufnr(v:val), "&buftype") == "quickfix"')) ? ":\<C-u>cN\<CR>" : ":\<C-u>bN\<CR>"
nnoremap <silent><expr><C-d> ":e #\<CR>:bw! #\<CR>"
nnoremap QQ :q!<CR>
noremap! <C-a> <HOME>
noremap! <C-e> <END>
noremap! <C-f> <RIGHT>
noremap! <C-b> <LEFT>
nnoremap <C-]> g<C-]>
nnoremap <silent>yu :%y +<CR>
cnoremap <C-p> <UP>
cnoremap <C-n> <DOWN>

" for snippet's select mode
snoremap j j
snoremap k k

nnoremap <silent><C-g> :<C-u>GenerateAllTags<CR>

" diff mode mappings.
if &diff
  nmap     <silent><C-l> :diffupdate<CR>
  nnoremap <silent><C-g> :diffget<CR>
  nnoremap <silent><C-n> ]czz
  nnoremap <silent><C-p> [czz
  nnoremap <silent>ZZ    :xa!<CR>
  nnoremap <silent>QQ    :cq!<CR>
endif

" VCS aware(mercurial, git, etc...) version of gf commands
nnoremap <expr> gf  <SID>do_vcs_diff_aware_gf('gf')
nnoremap <expr> gF  <SID>do_vcs_diff_aware_gf('gF')
nnoremap <expr> <C-w>f  <SID>do_vcs_diff_aware_gf('<C-w>f')
nnoremap <expr> <C-w><C-f>  <SID>do_vcs_diff_aware_gf('<C-w><C-f>')
nnoremap <expr> <C-w>F  <SID>do_vcs_diff_aware_gf('<C-w>F')
nnoremap <expr> <C-w>gf  <SID>do_vcs_diff_aware_gf('<C-w>gf')
nnoremap <expr> <C-w>gF  <SID>do_vcs_diff_aware_gf('<C-w>gF')

nmap <C-_> <Plug>NERDCommenterToggle
vmap <C-_> <Plug>NERDCommenterToggle
imap <C-_> <C-o><Plug>NERDCommenterToggle

imap <expr><Tab> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<CR>" : "\<Tab>"
smap <expr><Tab> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_jump)" : pumvisible() ? "\<CR>" : "\<Tab>"

nnoremap <C-c>ub :Unite -horizontal buffer file file_mru<CR>
nnoremap <C-c>uh :Unite history/yank<CR>
nnoremap <C-c>uc :Unite colorscheme -auto-preview<CR>
nnoremap <C-c>uo :Unite outline<CR>

nmap <C-c>vs <Plug>(vimshell_switch)
nmap <C-c>vc <Plug>(vimshell_create)
nmap <C-c>vp <Plug>(vimshell_split_create)

nnoremap gst :<C-u>Gstatus<CR>
nnoremap gb :<C-u>Gblame<CR>
vnoremap gb :<C-u>Gblame<CR>

nmap <C-]>c <Plug>(csutil-find-c)

" vim: set ft=vim sw=2 :
