syntax on

let g:author = "Naoya Inada"
let g:email  = "naoina@kuune.org"

let $VIMLOCAL = expand('~/.config/nvim')
let s:cachedir = $VIMLOCAL . '/.cache'

filetype off

if has('vim_starting')
  set runtimepath+=$VIMLOCAL/bundle/neobundle.vim

  call neobundle#begin($VIMLOCAL . '/bundle')
endif

" To avoid to the process time out in vimproc. See https://github.com/Shougo/neobundle.vim/issues/175
let g:neobundle#install_process_timeout = 300

NeoBundleFetch 'https://github.com/Shougo/neobundle.vim'

NeoBundle 'https://github.com/Valloric/YouCompleteMe', {
      \ 'install_process_timeout': 1800,
      \ 'build': {
      \     'unix': './install.py --clang-completer --gocode-completer --tern-completer',
      \     }
      \ }
let s:bundle = neobundle#get('YouCompleteMe')
function! s:bundle.hooks.on_source(bundle)
  let g:ycm_min_num_of_chars_for_completion = 1
  let g:ycm_key_list_select_completion = ['<Enter>']
  let g:ycm_global_ycm_extra_conf = $VIMLOCAL . '/.ycm_extra_conf.py'
  let g:ycm_confirm_extra_conf = 0
  let g:ycm_complete_in_comments = 1
  let g:ycm_complete_in_strings = 1
  let g:ycm_collect_identifiers_from_comments_and_strings = 1
  let g:ycm_add_preview_to_completeopt = 1
  let g:ycm_autoclose_preview_window_after_completion = 0
  let g:ycm_autoclose_preview_window_after_insertion = 0
  let g:ycm_seed_identifiers_with_syntax = 1
  let g:ycm_filetype_blacklist = {
        \   'php': 1,
        \ }
endfunction

NeoBundle 'https://github.com/SirVer/ultisnips'
let s:bundle = neobundle#get('ultisnips')
function! s:bundle.hooks.on_source(bundle)
  let g:UltiSnipsSnippetsDir = $VIMLOCAL . '/snippet'
  let g:UltiSnipsSnippetDirectories = [g:UltiSnipsSnippetsDir]
  let g:UltiSnipsJumpForwardTrigger = '<tab>'
  let g:UltiSnipsJumpBackwardTrigger = '<S-tab>'
endfunction

NeoBundle 'https://github.com/Shougo/vimproc', {
      \ 'build': {
      \     'windows': 'make -f make_mingw32.mak',
      \     'cygwin': 'make -f make_cygwin.mak',
      \     'mac': 'make -f make_mac.mak',
      \     'unix': 'make -f make_unix.mak',
      \     }
      \ }

NeoBundle 'https://github.com/naoina/vim-smartinput'
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

NeoBundle 'https://github.com/kana/vim-altr'
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
  call altr#define('%.go', '%_test.go', '%_bench_test.go')

  call altr#define('lib/%/%.coffee', 'lib/%/%.js', 'test/%/%.coffee', 'test/%/%.js')
  call altr#define('routes/%.coffee', 'test/routes/%.coffee', 'test/routes/%.js')

  command! An call altr#forward()
  command! Ap call altr#back()
endfunction

NeoBundleLazy 'https://github.com/scrooloose/nerdcommenter', {
      \ 'on_map': ['<Plug>NERDCommenter'],
      \ 'on_func': ['NERDComment'],
      \ }
let s:bundle = neobundle#get('nerdcommenter')
function! s:bundle.hooks.on_source(bundle)
  let g:NERDCreateDefaultMappings = 0
  let g:NERDSpaceDelims = 1
  let g:NERDDefaultNesting = 0
endfunction
nmap <C-_> <Plug>NERDCommenterToggle
vmap <C-_> <Plug>NERDCommenterToggle
imap <C-_> <C-o><Plug>NERDCommenterToggle

NeoBundle 'https://github.com/kana/vim-surround'
NeoBundle 'https://github.com/tpope/vim-fugitive', {
      \ 'augroup': 'fugitive',
      \ }
NeoBundle 'https://github.com/gregsexton/gitv', {
      \ 'depends': ['https://github.com/tpope/vim-fugitive'],
      \ }
NeoBundle 'https://github.com/tpope/vim-rhubarb', {
      \ 'depends': ['https://github.com/tpope/vim-fugitive'],
      \ }

let s:bundle = neobundle#get('gitv')
function! s:bundle.hooks.on_source(bundle)
  let g:Gitv_DoNotMapCtrlKey = 1
  let g:Gitv_OpenHorizontal = 1
endfunction

NeoBundle 'https://github.com/phleet/vim-mercenary', {
      \ 'augroup': 'mercenary',
      \ }

NeoBundle 'https://github.com/thinca/vim-template'
let s:bundle = neobundle#get('vim-template')
function! s:bundle.hooks.on_source(bundle)
  let g:template_basedir = $VIMLOCAL . '/templates'
  let g:template_files = '**'
  let g:template_free_pattern = 'skel-\?'
  let g:comment_oneline_only_ft = {
      \ 'python': 1,
      \ 'ruby': 1,
      \ 'sh': 1,
      \ }
  au User plugin-template-loaded call s:template_keywords()
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
endfunction

NeoBundle 'https://github.com/w0rp/ale.git'
let s:bundle = neobundle#get('ale')
function! s:bundle.hooks.on_source(bundle)
  let g:ale_lint_on_enter = 1
  let g:ale_lint_on_save = 1
  let g:ale_lint_on_text_changed = 0
  let g:ale_linters = {
        \ 'javascript': ['eslint'],
        \ 'go': ['go build'],
        \ }
  let g:ale_python_mypy_options = '--ignore-missing-imports'
  let g:ale_fixers = {
        \ 'javascript': ['prettier'],
        \ 'python': ['autopep8', 'isort'],
        \ 'markdown': [
        \   {buffer, lines -> {'command': 'textlint -c ~/.config/textlintrc -o /dev/null --fix --no-color --quiet %t', 'read_temporary_file': 1}}
        \   ],
        \ }
  let g:ale_fix_on_save = 1
  let g:ale_javascript_prettier_options = '--print-width 80'
endfunction

NeoBundle 'https://github.com/mattn/webapi-vim'
NeoBundle 'https://github.com/rking/ag.vim'
NeoBundle 'https://github.com/tpope/vim-rails' " should not use NeoBundleLazy
NeoBundle 'https://github.com/othree/html5.vim'

NeoBundle 'https://github.com/plasticboy/vim-markdown', {
      \ 'depends': ['https://github.com/cespare/vim-toml'],
      \ }
let s:bundle = neobundle#get('vim-markdown')
function s:bundle.hooks.on_source(bundle)
  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_frontmatter = 1
  let g:vim_markdown_toml_frontmatter = 1
  let g:vim_markdown_new_list_item_indent = 0
endfunction

NeoBundle 'https://github.com/AndrewRadev/switch.vim'
let s:bundle = neobundle#get('switch.vim')
function! s:bundle.hooks.on_source(bundle)
  nnoremap <silent>- :Switch<CR>
endfunction
function! s:bundle.hooks.on_post_source(bundle)
  let g:switch_definitions =
        \ [
        \   g:switch_builtins.ampersands,
        \   g:switch_builtins.capital_true_false,
        \   g:switch_builtins.true_false,
        \   ['==', '!='],
        \ ]
endfunction

NeoBundle 'https://github.com/kana/vim-textobj-user'
NeoBundle 'https://github.com/kana/vim-textobj-indent', {
      \ 'depends': [
      \     'https://github.com/kana/vim-textobj-user',
      \ ]}

NeoBundle 'https://github.com/cespare/vim-toml'
NeoBundle 'https://github.com/gf3/peg.vim'
NeoBundle 'https://github.com/wavded/vim-stylus'
NeoBundle 'https://github.com/digitaltoad/vim-pug'
NeoBundle 'https://github.com/rhysd/committia.vim'
NeoBundle 'https://github.com/othree/yajs.vim.git'

NeoBundle 'https://github.com/haya14busa/incsearch.vim'
let s:bundle = neobundle#get('incsearch.vim')
function! s:bundle.hooks.on_source(bundle)
  map / <Plug>(incsearch-forward)
  map ? <Plug>(incsearch-backward)
  let g:incsearch#emacs_like_keymap = 1
  let g:incsearch#vim_cmdline_keymap = 0
endfunction

" NeoBundleLazy 'https://github.com/kien/ctrlp.vim', {
      " \ 'on_cmd': ['CtrlP'],
      " \ }
" let s:bundle = neobundle#get('ctrlp.vim')
" function! s:bundle.hooks.on_source(bundle)
  " let g:ctrlp_map = '<nop>'
  " let g:ctrlp_show_hidden = 1
  " let g:ctrlp_regexp = 1
  " let g:ctrlp_use_migemo = 1
  " let g:ctrlp_prompt_mappings = {
        " \ 'PrtHistory(-1)': [],
        " \ 'PrtHistory(1)': [],
        " \ 'PrtSelectMove("j")': ['<C-n>'],
        " \ 'PrtSelectMove("k")': ['<C-p>'],
        " \ 'ToggleType(1)': ['<C-f>'],
        " \ 'ToggleType(-1)': ['<C-b>'],
        " \ }
" endfunction
" nnoremap <C-e> :<C-u>CtrlPBuffer<CR>

NeoBundleLazy 'https://github.com/Shougo/unite.vim', {
      \ 'on_cmd': ['Unite'],
      \ 'depends': [
      \   'https://github.com/ujihisa/unite-colorscheme',
      \   'https://github.com/Shougo/unite-outline',
      \   'https://github.com/Shougo/neoyank.vim',
      \ ]
      \ }
let s:bundle = neobundle#get('unite.vim')
function! s:bundle.hooks.on_source(bundle)
  let g:unite_data_directory = s:cachedir
  let g:unite_update_time = 100
  let g:unite_enable_split_vertically = 0
  let g:unite_winwidth = 60
  let g:unite_winheight = 10
  let g:unite_split_rule = "botright"
  let g:unite_source_history_yank_enable = 1
  let g:unite_enable_start_insert = 1

  let md_img = {
        \ 'description': "insert as markdown image syntax",
        \ }
  function! md_img.func(candidate)
    let a:candidate.word = '![' . fnamemodify(a:candidate.word, ':t:r') . '](/' . a:candidate.word . ')'
    call unite#take_action('insert', a:candidate)
  endfunction
  call unite#custom#action('file,word', 'markdown_image', md_img)
  call unite#custom#alias('file,word', 'md_img', 'markdown_image')
  unlet md_img

  function! s:unite_setting()
    nmap <buffer><Esc> <Plug>(unite_exit)
    imap <buffer><Esc> <Plug>(unite_exit)
    inoremap <buffer><expr> <C-o> unite#do_action('split')
    inoremap <buffer><expr> <C-v> unite#do_action('vsplit')
  endfunction
endfunction

NeoBundleLazy 'https://github.com/ujihisa/unite-colorscheme'
NeoBundleLazy 'https://github.com/Shougo/unite-outline'
NeoBundleLazy 'https://github.com/Shougo/neoyank.vim'
nnoremap <C-e> :Unite buffer file_rec/async:!<CR>
nnoremap <C-c>uh :Unite history/yank<CR>
nnoremap <C-c>uc :Unite colorscheme -auto-preview<CR>
nnoremap <C-c>uo :Unite -vertical outline<CR>

NeoBundle 'https://github.com/thinca/vim-quickrun'
let s:bundle = neobundle#get('vim-quickrun')
function! s:bundle.hooks.on_source(bundle)
  let g:quickrun_config = {
        \   '_': {
        \       'split': 'vertical 50',
        \   },
        \   'mongo': {
        \       'command': 'mongo',
        \       'cmdopt': '--quiet',
        \       'exec': ['%c %o < %s'],
        \   },
        \   'sql': {
        \       'type': executable('mysql') ? 'sql/mysql' : 'sql/postgres',
        \   },
        \   'sql/mysql': {
        \       'command': 'mysql',
        \       'cmdopt': '-u root',
        \       'exec': ['%c %o < %s'],
        \   },
        \   'javascript': {
        \       'type': 'javascript/nodejs',
        \   },
        \ }
endfunction

NeoBundle 'https://github.com/remyoudompheng/go-misc', {
      \ 'rtp': 'vim-template-syntax',
      \ }

NeoBundleLazy 'https://github.com/mattn/gist-vim', {
      \ 'on_cmd': 'Gist',
      \ }
let s:bundle = neobundle#get('gist-vim')
function! s:bundle.hooks.on_source(bundle)
  let g:gist_detect_filetype = 1
  let g:gist_private = 0
endfunction

NeoBundleLazy 'https://github.com/cespare/mxml.vim', {
      \ 'on_ft': ['mxml'],
      \ }

let g:colorv_filetypes = [
      \ 'css', 'scss', 'stylus', 'less', 'sass',
      \ 'html', 'xhtml', 'xml', 'gotplhtml', 'mako', 'erb', 'htmldjango',
      \ 'vim',
      \ ]
NeoBundleLazy 'https://github.com/Rykka/colorv.vim', {
      \ 'on_ft': g:colorv_filetypes,
      \ }
let s:bundle = neobundle#get('colorv.vim')
function! s:bundle.hooks.on_source(bundle)
  let g:colorv_no_global_map = 1
  let g:colorv_preview_ftype = join(g:colorv_filetypes, ',')
endfunction

NeoBundleLazy 'https://github.com/mattn/emmet-vim', {
      \ 'on_ft': ['html', 'xhtml', 'xml', 'htmldjango', 'mako', 'eruby', 'php', 'smarty'],
      \ }

NeoBundle 'https://github.com/vim-scripts/mako.vim'  " should not use the NeoBundleLazy

NeoBundleLazy 'https://github.com/vim-scripts/mako.vim--Torborg', {
      \ 'on_ft': ['mako'],
      \ }

NeoBundleLazy 'https://github.com/alfredodeza/pytest.vim', {
      \ 'on_ft': ['python'],
      \ }

NeoBundleLazy 'https://github.com/klen/python-mode', {
      \ 'on_ft': ['python'],
      \ }
let s:bundle = neobundle#get('python-mode')
function! s:bundle.hooks.on_source(bundle)
  let g:pymode_run = 0
  let g:pymode_doc = 0
  let g:pymode_lint = 0
  let g:pymode_folding = 0
  let g:pymode_indent = 0
  let g:pymode_utils_whitespaces = 0
  let g:pymode_rope = 0
  let g:pymode_syntax = 0
  let g:pymode_breakpoint = 1
  let g:pymode_options_max_line_length = 100
endfunction

NeoBundleLazy 'https://github.com/jmcantrell/vim-virtualenv', {
      \ 'on_ft': ['python'],
      \ }

NeoBundleLazy 'https://github.com/OmniSharp/omnisharp-vim', {
      \ 'on_ft': ['cs'],
      \ 'depends': ['https://github.com/tpope/vim-dispatch'],
      \ 'build': {
      \     'windows': 'MSBuild.exe server/OmniSharp.sln /p:Platform="Any CPU"',
      \     'mac': 'xbuild server/OmniSharp.sln',
      \     'linux': 'xbuild server/OmniSharp.sln',
      \     }
      \ }
let s:bundle = neobundle#get('omnisharp-vim')
function! s:bundle.hooks.on_source(bundle)
  let g:OmniSharp_selector_ui = 'unite'
  nnoremap <silent><buffer>gd :OmniSharpGotoDefinition<CR>
  nnoremap <silent><buffer><leader><space> :OmniSharpGetCodeAction<CR>
  vnoremap <silent><buffer><leader><space> call OmniSharp#GetCodeAction('visual')<CR>
  nnoremap <silent><buffer><leader>p :OmniSharpNavigateUp<CR>
  nnoremap <silent><buffer><leader>n :OmniSharpNavigateDown<CR>
  augroup omnisharp
    au!
    au BufWritePre *.cs OmniSharpCodeFormat
    au CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()
  augroup END
endfunction

NeoBundle 'https://github.com/kchmck/vim-coffee-script'
let s:bundle = neobundle#get('vim-coffee-script')
function! s:bundle.hooks.on_source(bundle)
  let g:coffee_compile_vert = 1
endfunction

NeoBundle 'https://github.com/mustache/vim-mustache-handlebars'

NeoBundle 'https://github.com/fatih/vim-go'
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

NeoBundleLazy 'https://github.com/rhysd/vim-go-impl', {
        \ 'on_ft': ['go'],
        \ 'build': {
        \     'windows': 'go get -u github.com/josharian/impl',
        \     'cygwin': 'go get -u github.com/josharian/impl',
        \     'mac': 'go get -u github.com/josharian/impl',
        \     'unix': 'go get -u github.com/josharian/impl',
        \     },
        \ }

NeoBundleLazy 'https://github.com/vim-scripts/Align', {
      \ 'on_cmd': ['Align'],
      \ }

NeoBundle 'https://github.com/tpope/vim-repeat'

NeoBundleLazy 'https://github.com/Yggdroot/indentLine', {
      \ 'on_ft': ['coffee', 'python', 'jade', 'pug', 'stylus', 'haml'],
      \ }
let s:bundle = neobundle#get('indentLine')
function! s:bundle.hooks.on_source(bundle)
  let g:indentLine_enabled = 0
endfunction

NeoBundleLazy 'https://github.com/junegunn/vader.vim.git', {
      \ 'on_ft': ['vader'],
      \ }

NeoBundle 'https://github.com/haya14busa/vim-asterisk'
let s:bundle = neobundle#get('vim-asterisk')
function! s:bundle.hooks.on_source(bundle)
  map * <Plug>(asterisk-z*)
  map g* <Plug>(asterisk-gz*)
  map # <Plug>(asterisk-z#)
  map g# <Plug>(asterisk-gz#)
endfunction

NeoBundle 'https://github.com/tpope/vim-unimpaired'
NeoBundle 'https://github.com/rupurt/vim-mql5'
let s:bundle = neobundle#get('vim-mql5')
function! s:bundle.hooks.on_source(bundle)
  augroup mql5
    au!
    au BufNewFile,BufReadPost *.mq4 set filetype=mql5
  augroup END
endfunction

" for colorschemes
NeoBundle 'https://github.com/flazz/vim-colorschemes'
NeoBundle 'https://github.com/mattn/yamada2-vim'

call neobundle#end()

filetype plugin indent on

set t_Co=256
set background=light
set termguicolors
colorscheme naoina

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
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set formatoptions+=cqmM
set statusline=%<[%n]%{fugitive#statusline()}\ %F\ %h%r%m[%{&fenc}][%{&ff=='unix'?'LF':&ff=='dos'?'CRLF':'CR'}]\ %=[0x%B]\ %c,%l/%L\ %y
set display=lastline
set mouse=n

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,japan,cp932,utf-16,utf-8
set fileformats=unix,dos,mac
set nofixendofline

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

" Auto restore last cursor position.
function! s:restore_cursor()
  if line("'\"") > 1 && line("'\"") <= line("$")
    normal! g`"
  endif
endfunction

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
  setlocal textwidth=100
  setlocal expandtab

  inoreabbrev slef self
  inoreabbrev slf self

  if executable('py.test') && exists(':Pytest')
      nnoremap <silent><buffer><leader>f :Pytest method<CR>
      nnoremap <silent><buffer><leader>c :Pytest class<CR>
  endif
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
    augroup END
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
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
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

function! s:pug_setting()
  call s:html_setting()
  setl foldmethod=indent
  setl tabstop=2 softtabstop=2 shiftwidth=2 expandtab
endfunction

function! s:jade_setting()
  call s:pug_setting()
endfunction

function! s:mongo_setting()
  call s:javascript_setting()
  ru! syntax/javascript.vim
endfunction

function! s:stylus_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  setl foldmethod=indent
endfunction

function! s:json_setting()
  call s:javascript_setting()
endfunction

function! s:markdown_setting()
  setlocal tabstop=2 softtabstop=2 shiftwidth=2
  let b:switch_definitions = [
        \ {
        \   '/\?\<[\w.-_/]\{-\}\.\(jpe\?g\|png\|gif\|svg\)\>': '\="![".fnamemodify(submatch(0), ":t:r")."](".submatch(0).")"',
        \   '!\[.\{-\}\](\(.\{-\}\))': '\1',
        \ }
        \ ]
endfunction

function! s:mql5_setting()
  call s:cpp_setting()
  setlocal tabstop=3 softtabstop=3 shiftwidth=3
  setlocal cindent
  setlocal dictionary=$VIMLOCAL/dict/mql5.dict
  setlocal complete+=k
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

hi FullwidthAndEOLSpace guibg=#ffafd7
augroup vimrc
  au!

  au BufNewFile,BufRead *.as        setlocal filetype=actionscript
  au BufNewFile,BufRead *.mxml      setlocal filetype=mxml
  au BufNewFile,BufRead *.inc       setlocal filetype=php
  au BufNewFile,BufRead *.snip      setlocal filetype=snippet
  au BufNewFile,BufRead *.wsgi      setlocal filetype=python
  au BufNewFile,BufRead *.mayaa     setlocal filetype=xml
  au BufNewFile,BufRead *.scala     setlocal filetype=scala
  au BufNewFile,BufRead *.mako      setlocal filetype=mako
  au BufNewFile,BufRead .bowerrc    setlocal filetype=javascript
  au BufNewFile,BufRead *.tmpl      setlocal filetype=gotpl
  au BufNewFile,BufRead *.html.tmpl setlocal filetype=gotplhtml

  au WinEnter,BufEnter * match FullwidthAndEOLSpace "\(　\|\s\)\+$"
  au WinEnter,BufEnter * setlocal cursorline
  au WinLeave,BufLeave * setlocal nocursorline
  au QuickFixCmdPost vimgrep cw

  au FileType * call s:setting()
  au InsertEnter * set nohlsearch
  au InsertLeave * set hlsearch

  au BufReadPost * if &fenc=="sjis" || &fenc=="cp932" | silent! %s/¥/\\/g | call s:clear_undo() | endif
  au BufReadPost * call s:restore_cursor()
  au BufEnter * call s:autocd()
augroup END

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
nnoremap <F6> :<C-u>exec 'normal i' . substitute(system('date ' . shellescape('+%Y-%m-%dT%H:%M:%S%:z')), '[\r\n]\+$', '', '')<CR>
inoremap <F6> <C-r>=substitute(system('date ' . shellescape('+%Y-%m-%dT%H:%M:%S%:z')), '[\r\n]\+$', '', '')<CR>
noremap  <silent><C-j> <C-w>w
noremap  <silent><C-k> <C-w>W
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
nnoremap <silent><C-g> :<C-u>setl cursorcolumn!<CR>

" for snippet's select mode
snoremap j j
snoremap k k

" diff mode mappings.
if &diff
  nmap <silent><C-l> :diffupdate<CR>
  nmap <silent><C-g> :diffget<CR>
  nmap <silent><C-n> ]czz
  nmap <silent><C-p> [czz
  nmap <silent>ZZ    :xa!<CR>
  nmap <silent>QQ    :cq!<CR>
endif

" VCS aware(mercurial, git, etc...) version of gf commands
nnoremap <expr> gf  <SID>do_vcs_diff_aware_gf('gf')
nnoremap <expr> gF  <SID>do_vcs_diff_aware_gf('gF')
nnoremap <expr> <C-w>f  <SID>do_vcs_diff_aware_gf('<C-w>f')
nnoremap <expr> <C-w><C-f>  <SID>do_vcs_diff_aware_gf('<C-w><C-f>')
nnoremap <expr> <C-w>F  <SID>do_vcs_diff_aware_gf('<C-w>F')
nnoremap <expr> <C-w>gf  <SID>do_vcs_diff_aware_gf('<C-w>gf')
nnoremap <expr> <C-w>gF  <SID>do_vcs_diff_aware_gf('<C-w>gF')

" vim: set ft=vim sw=2 :
