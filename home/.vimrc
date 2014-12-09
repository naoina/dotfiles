syntax on

let g:author = "Naoya Inada"
let g:email  = "naoina@kuune.org"

let $VIMLOCAL = expand('~/.vim')
let s:cachedir = $VIMLOCAL . '/cache'

filetype off

if has('vim_starting')
  set nocompatible
  set runtimepath+=$VIMLOCAL/bundle/neobundle.vim

  call neobundle#begin($VIMLOCAL . '/bundle')
endif

" To avoid to the process time out in vimproc. See https://github.com/Shougo/neobundle.vim/issues/175
let g:neobundle#install_process_timeout = 300

NeoBundleFetch 'https://github.com/Shougo/neobundle.vim.git'

augroup MyAutoCmd
  au!
augroup End

" NeoBundle 'git://github.com/Shougo/neocomplcache.git'

" NeoBundle 'git://github.com/Shougo/neocomplete.vim.git'
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_auto_select = 1
let g:neocomplete#min_keyword_length = 4
let g:neocomplete#sources#syntax#min_keyword_length  = 4
let g:neocomplete#auto_completion_start_length = 1
let g:neocomplete#enable_ignore_case = 1
let g:neocomplete#enable_smart_case  = 1
let g:neocomplete#data_directory = s:cachedir
let g:neocomplete#enable_prefetch = 1
let g:neocomplete#force_overwrite_completefunc = 1
let g:neocomplete#enable_refresh_always = 1
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.python = '[^. \t]\.\w*'

NeoBundle 'git://github.com/Valloric/YouCompleteMe.git', {
        \ 'build': {
        \     'unix': 'git submodule update --init --recursive && ./install.sh --clang-completer --system-libclang',
        \     },
        \ }
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_key_list_select_completion = ['<Enter>']
let g:ycm_global_ycm_extra_conf = $VIMLOCAL . '/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_autoclose_preview_window_after_insertion = 1

NeoBundle 'https://github.com/SirVer/ultisnips.git'
let g:UltiSnipsSnippetsDir = $VIMLOCAL . '/snippet'
let g:UltiSnipsSnippetDirectories = [g:UltiSnipsSnippetsDir]
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-tab>'

" NeoBundle 'git://github.com/Shougo/neosnippet.git'
NeoBundle 'git://github.com/Shougo/vimproc.git', {
        \ 'build': {
        \     'windows': 'make -f make_mingw32.mak',
        \     'cygwin': 'make -f make_cygwin.mak',
        \     'mac': 'make -f make_mac.mak',
        \     'unix': 'make -f make_unix.mak',
        \     },
        \ }

NeoBundle 'https://github.com/kana/vim-smartinput.git'
let s:bundle = neobundle#get('vim-smartinput')
function! s:bundle.hooks.on_post_source(bundle)
  call smartinput#map_to_trigger('i', '#', '#', '#')
  call smartinput#map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')
  call smartinput#define_rule({
          \ 'at': '\({\|\<do\>\)\s*\%#',
          \ 'char': '<Bar>',
          \ 'input': '<Bar><Bar><Left>',
          \ 'filetype': ['ruby'],
          \ })
endfunction

NeoBundle 'https://github.com/kana/vim-altr.git'
let s:bundle = neobundle#get('vim-altr')
function! s:bundle.hooks.on_post_source(bundle)
  " Python
  call altr#define('views.py', 'views/__init__.py', 'tests/test_views.py')
  call altr#define('views/%.py', 'tests/views/test_%.py')
  call altr#define('models.py', 'models/__init__.py', 'tests/test_models.py')
  call altr#define('models/%.py', 'tests/models/test_%.py')
  call altr#define('forms.py', 'forms/__init__.py', 'tests/test_forms.py')
  call altr#define('forms/%.py', 'tests/forms/test_%.py')
  " JavaScript
  call altr#define('static/js/plog/components/%.js', 'tests/js/plog/components/test_%.js')
  " Go
  call altr#define('%.go', '%_test.go')
  command! An call altr#forward()
  command! Ap call altr#back()
endfunction

NeoBundle 'git://github.com/scrooloose/nerdcommenter.git'
NeoBundle 'git://github.com/kana/vim-surround.git'
NeoBundle 'git://github.com/tpope/vim-fugitive.git', {'augroup': 'fugitive'}
NeoBundle 'https://github.com/gregsexton/gitv.git', {
      \ 'depends': ['tpope/vim-fugitive.git'],
      \ }
let s:bundle = neobundle#get('gitv')
function! s:bundle.hooks.on_source(bundle)
  let g:Gitv_DoNotMapCtrlKey = 1
  let g:Gitv_OpenHorizontal = 1
endfunction

NeoBundle 'git://github.com/phleet/vim-mercenary.git', {'augroup': 'mercenary'}
NeoBundle 'git://github.com/thinca/vim-template.git'
NeoBundle 'git://github.com/scrooloose/syntastic.git'
" let g:syntastic_auto_loc_list = 1
let g:syntastic_mode_map = {
    \ 'mode': 'active',
    \ 'passive_filetypes': ['java', 'html'],
    \ }
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_go_checkers = ['go', 'govet']
let g:syntastic_coffee_coffeelint_args = '--csv -f ~/.coffeelint.json'

NeoBundle 'https://bitbucket.org/anyakichi/vim-csutil'
NeoBundle 'git://github.com/mattn/webapi-vim.git'
NeoBundle 'git://github.com/rking/ag.vim.git'
NeoBundle 'git://github.com/tpope/vim-rails.git'  " should not be used the NeoBundleLazy
NeoBundle 'git://github.com/tpope/vim-markdown.git'
NeoBundle 'git://github.com/othree/html5.vim.git'
NeoBundle 'https://github.com/AndrewRadev/switch.vim.git'
nnoremap <silent>- :Switch<CR>
let s:bundle = neobundle#get('switch.vim')
function! s:bundle.hooks.on_post_source(bundle)
  let g:switch_definitions =
        \ [
        \   g:switch_builtins.ampersands,
        \   g:switch_builtins.capital_true_false,
        \   g:switch_builtins.true_false,
        \   ['==', '!='],
        \ ]
endfunction

NeoBundle 'https://github.com/kana/vim-textobj-user.git'
NeoBundle 'https://github.com/kana/vim-textobj-indent.git', {
      \ 'depends': [
      \     'kana/vim-textobj-user.git',
      \ ]}
NeoBundle 'https://github.com/cespare/vim-toml'
NeoBundle 'https://github.com/gf3/peg.vim'
NeoBundle 'https://github.com/wavded/vim-stylus.git'
NeoBundle 'https://github.com/digitaltoad/vim-jade.git'
NeoBundle 'https://github.com/rhysd/committia.vim.git'
NeoBundle 'https://github.com/haya14busa/incsearch.vim.git'
let s:bundle = neobundle#get('incsearch.vim')
function! s:bundle.hooks.on_source(bundle)
  map / <Plug>(incsearch-forward)
  map ? <Plug>(incsearch-backward)
  let g:incsearch#emacs_like_keymap = 1
  let g:incsearch#vim_cmdline_keymap = 0
endfunction

NeoBundle 'https://github.com/vim-scripts/diffchar.vim.git'
let s:bundle = neobundle#get('diffchar.vim')
function! s:bundle.hooks.on_post_source(bundle)
  let g:DiffUnit = 'Word3'
  function! s:enableDiffchar()
    if &diff
      %SDChar
    endif
  endfunction
  augroup EnableDiffchar
    autocmd!
    autocmd BufEnter * call s:enableDiffchar()
  augroup END
endfunction

NeoBundleLazy 'https://github.com/kien/ctrlp.vim.git', {
        \ 'autoload': {
        \     'commands': ['CtrlP'],
        \     },
        \ }
let s:bundle = neobundle#get('ctrlp.vim')
function! s:bundle.hooks.on_source(bundle)
  let g:ctrlp_map = '<nop>'
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_prompt_mappings = {
        \ 'PrtHistory(-1)': [],
        \ 'PrtHistory(1)': [],
        \ 'PrtSelectMove("j")': ['<C-n>'],
        \ 'PrtSelectMove("k")': ['<C-p>'],
        \ }
endfunction
nnoremap <C-e> :<C-u>CtrlP<CR>

NeoBundleLazy 'git://github.com/Shougo/unite.vim.git', {
        \ 'autoload': {
        \     'commands': ['Unite'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/ujihisa/unite-colorscheme.git', {
        \ 'autoload': {
        \     'unite_sources': ['colorscheme'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/Shougo/unite-outline.git', {
        \ 'autoload': {
        \     'unite_sources': ['outline'],
        \     },
        \ }

NeoBundle 'git://github.com/thinca/vim-quickrun.git'
let s:bundle = neobundle#get('vim-quickrun')
function! s:bundle.hooks.on_source(bundle)
  let g:quickrun_config = {
        \ '_': {
        \     'split': 'vertical 50',
        \     },
        \ 'mongo': {
        \     'command': 'mongo',
        \     'cmdopt': '--quiet',
        \     'exec': ['%c %o < %s'],
        \     },
        \ 'sql': {
        \     'type': executable('mysql') ? 'sql/mysql' : 'sql/postgres',
        \     },
        \ 'sql/mysql': {
        \     'command': 'mysql',
        \     'cmdopt': '-u root',
        \     'exec': ['%c %o < %s'],
        \     },
        \ }
endfunction

NeoBundle 'https://github.com/cespare/vim-go-templates.git'

NeoBundleLazy 'git://github.com/nathanaelkane/vim-indent-guides.git', {
        \ 'autoload': {
        \     'commands': ['IndentGuidesToggle', 'IndentGuidesEnable'],
        \     },
        \ }
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 1
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_exclude_filetypes = ['help']
nnoremap <silent><C-g> :<C-u>IndentGuidesToggle<CR>
inoremap <silent><C-g> <C-o>:<C-u>IndentGuidesToggle<CR>

NeoBundleLazy 'git://github.com/mattn/gist-vim.git', {
        \ 'autoload': {
        \     'commands': 'Gist',
        \     },
        \ }
NeoBundleLazy 'git://github.com/cespare/mxml.vim.git', {
        \ 'autoload': {
        \     'filetypes': ['mxml'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/Rykka/colorv.vim.git', {
        \ 'autoload': {
        \     'filetypes': ['html', 'htmldjango', 'mako', 'erb', 'css', 'vim'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/mattn/emmet-vim.git', {
        \ 'autoload': {
        \     'filetypes': ['html', 'xhtml', 'xml', 'htmldjango', 'mako', 'eruby', 'php', 'smarty'],
        \     },
        \ }
NeoBundle 'git://github.com/vim-scripts/mako.vim.git'  " should not be used the NeoBundleLazy
NeoBundleLazy 'git://github.com/vim-scripts/mako.vim--Torborg.git', {
        \ 'autoload': {
        \     'filetypes': ['mako'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/jiangmiao/simple-javascript-indenter.git', {
        \ 'autoload': {
        \     'filetypes': ['javascript'],
        \     },
        \ }
NeoBundleLazy 'https://github.com/marijnh/tern_for_vim.git', {
        \ 'build': {
        \     'unix': 'npm update',
        \     'mac': 'npm update',
        \     },
        \ 'autoload': {
        \     'filetypes': ['javascript'],
        \     },
        \ }

NeoBundleLazy 'git://github.com/alfredodeza/pytest.vim.git', {
        \ 'autoload': {
        \     'filetypes': ['python'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/klen/python-mode.git', {
      \ 'autoload': {
      \     'filetypes': ['python'],
      \     },
      \ }
" NeoBundleLazy 'git://github.com/davidhalter/jedi-vim.git', {
        " \ 'build': {
        " \     'unix': 'git submodule update --init',
        " \     },
        " \ 'autoload': {
        " \     'filetypes': ['python'],
        " \     },
        " \ }
" let s:bundle = neobundle#get('jedi-vim')
" function! s:bundle.hooks.on_source(bundle)
  " let g:jedi#auto_initialization = 1
  " let g:jedi#get_definition_command = '<C-]>'
  " let g:jedi#rename_command = '<leader>n'
  " let g:jedi#use_tabs_not_buffers = 0
  " let g:jedi#popup_on_dot = 0
  " let g:jedi#auto_vim_configuration = 0
" endfunction

NeoBundleLazy 'git://github.com/jmcantrell/vim-virtualenv.git', {
        \ 'autoload': {
        \     'filetypes': ['python'],
        \     },
        \ }
NeoBundleLazy 'git://github.com/kchmck/vim-coffee-script.git', {
        \ 'autoload': {
        \     'filetypes': ['coffee'],
        \     },
        \ }
let g:coffee_compile_vert = 1

" NeoBundleLazy 'git://github.com/Rip-Rip/clang_complete.git', {
        " \ 'autoload': {
        " \     'filetypes': ['c', 'cpp', 'objc'],
        " \     },
        " \ }

NeoBundleLazy 'https://github.com/fatih/vim-go.git', {
        \ 'autoload': {
        \     'filetypes': ['go'],
        \     },
        \ }
let s:bundle = neobundle#get('vim-go')
function! s:bundle.hooks.on_source(bundle)
  let g:go_fmt_fail_silently = 1
  let g:go_fmt_autosave = 1
  let g:go_highlight_extra_types = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_methods = 1
  let g:go_highlight_structs = 1
  let g:go_fmt_command = "goimports"
  let g:go_snippet_engine = "ultisnipts"
  let g:go_bin_path = expand('$GOROOT/bin/')
endfunction
NeoBundleLazy 'https://github.com/rhysd/vim-go-impl.git', {
        \ 'autoload': {
        \     'filetypes': ['go'],
        \     },
        \ 'build': {
        \     'windows': 'go get -u github.com/josharian/impl',
        \     'cygwin': 'go get -u github.com/josharian/impl',
        \     'mac': 'go get -u github.com/josharian/impl',
        \     'unix': 'go get -u github.com/josharian/impl',
        \     },
        \ }


" for colorschemes
NeoBundle 'git://github.com/godlygeek/csapprox.git'
NeoBundle 'git://github.com/flazz/vim-colorschemes.git'
NeoBundle 'https://github.com/mattn/yamada2-vim.git'

call neobundle#end()

filetype plugin indent on

set t_Co=256
set background=light
colorscheme naoina

hi FullwidthAndEOLSpace guibg=#ffafd7
au WinEnter,BufEnter * match FullwidthAndEOLSpace "\(　\|\s\)\+$"

runtime macros/matchit.vim

set backupdir=$VIMLOCAL/backup
set directory=$VIMLOCAL/swap
set noswapfile

set backup
set nowritebackup
set viminfo='1000,<500,f1
set backspace=indent,eol,start
set list
set listchars=tab:>-,eol:$
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
set fileencodings=ucs-bom,utf-8,japan,sjis,utf-16,utf-8
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
function! s:restore_cursor()
  if line("'\"") > 1 && line("'\"") <= line("$")
    normal! g`"
  endif
endfunction
au BufReadPost * call s:restore_cursor()

au BufEnter * call s:autocd()

" For gist-vim
let g:gist_detect_filetype = 1
let g:gist_private = 0

" For csutil
let g:csutil_no_mappings = 1

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
  %s/@DIRNAME@/\=expand('%:p:h:t')/ge

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

" For neocomplcache, script_id=2620
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_auto_select = 1
let g:neocomplcache_min_keyword_length = 4
let g:neocomplcache_min_syntax_length  = 4
let g:neocomplcache_auto_completion_start_length = 1
let g:neocomplcache_enable_ignore_case = 1
let g:neocomplcache_enable_smart_case  = 1
let g:neocomplcache_temporary_dir = s:cachedir
let g:neocomplcache_enable_prefetch = 1
let g:neocomplcache_force_overwrite_completefunc = 1
let g:neocomplcache_enable_fuzzy_completion = 1
" let g:neocomplcache_enable_debug = 1
" if !exists('g:neocomplcache_omni_functions')
    " let g:neocomplcache_force_omni_patterns = {}
" endif
" let g:neocomplcache_force_omni_patterns.python = '[^. \t]\.\w*'

" For neosnippet
let g:neosnippet#snippets_directory = $VIMLOCAL . '/snippet'
let g:neosnippet#disable_runtime_snippets = {
      \ '_': 1,
      \ }

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

" For python-mode
let g:pymode_run = 0
let g:pymode_doc = 0
let g:pymode_lint = 0
let g:pymode_folding = 0
let g:pymode_indent = 1
let g:pymode_utils_whitespaces = 0
let g:pymode_rope = 0
let g:pymode_syntax = 0

" For simple-javascript-indenter
let g:SimpleJsIndenter_BriefMode = 1

function! s:refresh()
  setlocal autoread
  redr!
  set autoread<
endfunction

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
au BufNewFile,BufRead .bowerrc  setlocal filetype=javascript

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

  inoreabbrev slef self
  inoreabbrev slf self

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
  setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  let g:ctags_opts = '--langmap=PHP:.php.inc.php4'
  iab true TRUE
  iab false FALSE
endfunction

function! s:html_setting()
  call s:xml_setting()
  call s:colorv_autopreview()
endfunction

function! s:htmldjango_setting()
  call s:html_setting()
endfunction

function! s:snippet_setting()
  setlocal noexpandtab
  snoremap <buffer><Tab> <Tab>
  inoremap <buffer><Tab> <Tab>
endfunction

function! s:javascript_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal foldmethod=indent foldminlines=1 foldlevel=1

  inoreabbrev tihs this
  inoreabbrev htis this

  let g:jscomplete_use = ['dom', 'moz']
  setlocal omnifunc=jscomplete#CompleteJS
  let b:switch_definitions =
        \ [
        \   ['===', '!=='],
        \ ]
endfunction

function! s:actionscript_setting()
  setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  setlocal foldmethod=indent foldminlines=1 foldlevel=1
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
      " au BufWritePost <buffer> JavaImportOrganize
    augroup End
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
  setlocal foldmethod=indent
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

function! s:coffee_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setlocal foldmethod=indent

  nnoremap <silent><buffer><C-c><C-c> :CoffeeCompile<CR>
  call s:jump_next_indent_map()
endfunction

function! s:haml_setting()
  call s:jump_next_indent_map()
endfunction

function! s:go_setting()
  setlocal tabstop=4 softtabstop=4 shiftwidth=4
  setlocal foldmethod=indent
  setlocal noexpandtab
  inoremap {<CR> {<CR>}<C-o>O
  inoremap (<CR> (<CR>)<C-o>O
  let b:switch_definitions =
        \ [
        \   {
        \     'for\s\+.\{-}\s*,\s*\k\+\s*:=\s*range\s\+\(.\{-}\)\s*{': 'for i = 0; i < len(\1); i++ {',
        \     'for\s\+\k\+\s*=\s*.\{-};\s*\k\+\s*<\s*len(\(.\{-}\));\s*\k\+++\s*{': 'for _, v := range \1 {',
        \   },
        \   {
        \     'err\s*!=\s*nil': '!ok',
        \     '!ok': 'err != nil',
        \   },
        \ ]
endfunction

function! s:gotplhtml_setting()
  setlocal tabstop=4 softtabstop=4 shiftwidth=4
  setlocal noexpandtab
  setlocal autoindent
endfunction

function! s:gitconfig_setting()
  setlocal tabstop=4 softtabstop=4 shiftwidth=4
  setlocal noexpandtab
endfunction

function! s:toml_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  setlocal autoindent
endfunction

function! s:yacc_setting()
  setlocal noexpandtab autoindent
endfunction

function! s:jade_setting()
  call s:html_setting()
endfunction

function! s:mongo_setting()
  call s:javascript_setting()
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

function! s:jump_next_indent_map()
  nnoremap <silent><buffer>%n :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<CR>
  nnoremap <silent><buffer>%N :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<CR>
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

au MyAutoCmd FileType * call s:setting()
au MyAutoCmd InsertEnter * set nohlsearch
au MyAutoCmd InsertLeave * set hlsearch

" Mappings.
noremap Q <Nop>
noremap <silent>j  gj
noremap <silent>k  gk
noremap <silent>gj j
noremap <silent>gk k
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
noremap  <C-j> <C-w>w
noremap  <C-k> <C-w>W
nnoremap <silent><C-l> :<C-u>nohls<CR>:<C-u>call <SID>refresh()<CR>
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

" imap <expr><Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
" smap <expr><Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"

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
