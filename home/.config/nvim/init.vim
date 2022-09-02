scriptencoding utf-8
syntax on

let g:author = 'Naoya Inada'
let g:email  = 'naoina@kuune.org'

let $VIMLOCAL = expand('~/.config/nvim')
let s:cachedir = $VIMLOCAL . '/.cache'

filetype off

if has('vim_starting')
  set runtimepath+=$VIMLOCAL/plugged/vim-plug
  if !isdirectory(expand($VIMLOCAL . '/plugged/vim-plug'))
    call system('mkdir -p ' . $VIMLOCAL . '/plugged/vim-plug')
    call system('git clone https://github.com/junegunn/vim-plug ' . $VIMLOCAL . '/plugged/vim-plug/autoload')
  end
endif


call plug#begin($VIMLOCAL . '/plugged')
let g:plug_url_format = 'https://git::@github.com/%s'

Plug 'junegunn/vim-plug', { 'dir': $VIMLOCAL . '/plugged/vim-plug/autoload' }

let g:plug_timeout = 1800
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --js-completer' }
unlet g:plug_timeout
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

Plug 'SirVer/ultisnips'
let g:UltiSnipsSnippetsDir = $VIMLOCAL . '/snippet'
let g:UltiSnipsSnippetDirectories = [g:UltiSnipsSnippetsDir]
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-tab>'

Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'cohama/lexima.vim'

Plug 'Shougo/unite.vim', { 'on': 'Unite' }
let g:unite_data_directory = s:cachedir
let g:unite_update_time = 100
let g:unite_enable_split_vertically = 0
let g:unite_winwidth = 60
let g:unite_winheight = 10
let g:unite_split_rule = 'botright'
let g:unite_source_history_yank_enable = 1
let g:unite_enable_start_insert = 1
function! OnloadUnite() abort
  let md_img = {
        \ 'description': 'insert as markdown image syntax',
        \ }
  function! md_img.func(candidate) abort
    let a:candidate.word = '![' . fnamemodify(a:candidate.word, ':t:r') . '](/' . a:candidate.word . ')'
    call unite#take_action('insert', a:candidate)
  endfunction
  call unite#custom#action('file,word', 'markdown_image', md_img)
  call unite#custom#alias('file,word', 'md_img', 'markdown_image')
  unlet md_img
endfunction
augroup Unite
  au!
  au User unite.vim call OnloadUnite()
augroup END

function! s:unite_setting() abort
  nmap <buffer><Esc> <Plug>(unite_exit)
  imap <buffer><Esc> <Plug>(unite_exit)
  inoremap <buffer><expr> <C-o> unite#do_action('split')
  inoremap <buffer><expr> <C-v> unite#do_action('vsplit')
endfunction

Plug 'ujihisa/unite-colorscheme', { 'on': 'Unite' }
Plug 'Shougo/unite-outline', { 'on': 'Unite' }
Plug 'Shougo/neoyank.vim', { 'on': 'Unite' }
nnoremap <C-e> :Unite buffer file_rec/async:!<CR>
nnoremap <C-c>uh :Unite history/yank<CR>
nnoremap <C-c>uc :Unite colorscheme -auto-preview<CR>
nnoremap <C-c>uo :Unite -vertical outline<CR>

" Plug 'ctrlpvim/ctrlp.vim'
" let g:ctrlp_types = ['buf', 'mru', 'fil']
" let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:20,results:0'
" let g:ctrlp_custom_ignore = {
"      \ 'dir': '\v[\/](,|vendor|node_modules)$',
"      \ 'file': '\v\.(' . join([
"      \     'exe', 'so', 'dll', 'jpe?g', 'png', 'gif', 'ico', 'pdf', 'mp4',
"      \     'ttf', 'svg', 'otf', 'eot', 'woff2?', 'log', 'env(rc)?', 'map',
"      \     ], '|') . ')$'
"      \ }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
let g:fzf_layout = { 'down': '40%' }
if has('nvim')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
endif
let g:fzf_action = {
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit',
      \ }
let fzf_options = {'options': ['--layout=reverse-list']}
nnoremap <silent><C-p> :<C-u>call fzf#vim#files(finddir('.git/..', expand('%:p:h') . ';'), fzf_options)<CR>
nnoremap <silent><C-x><C-p><C-p> :<C-u>call fzf#vim#files('.', fzf_options)<CR>
nnoremap <silent><C-x><C-p><C-b> :<C-u>call fzf#vim#buffers('', fzf_options)<CR>
imap <C-x><C-f> <plug>(fzf-complete-path)

Plug 'kana/vim-altr', { 'on': ['An', 'Ap'] }
function! OnloadVimAltr() abort
  " Python
  call altr#define('views.py', 'views/__init__.py', 'tests/test_views.py')
  call altr#define('views/%.py', 'tests/views/test_%.py')
  call altr#define('models.py', 'models/__init__.py', 'tests/test_models.py')
  call altr#define('models/%.py', 'tests/models/test_%.py')
  call altr#define('forms.py', 'forms/__init__.py', 'tests/test_forms.py')
  call altr#define('forms/%.py', 'tests/forms/test_%.py')
  " JavaScript
  call altr#define('static/js/plog/components/%.js', 'tests/js/plog/components/test_%.js')
  call altr#define('%.go', '%_test.go', '%_bench_test.go')
  call altr#define('lib/%/%.js', 'test/%/%.js')
  call altr#define('routes/%.js', 'test/routes/%.js')
  command! An call altr#forward()
  command! Ap call altr#back()
endfunction
augroup VimAltr
  au! User vim-altr call OnloadVimAltr()
augroup END

Plug 'tyru/caw.vim'
nmap <C-_> <Plug>(caw:hatpos:toggle)
vmap <C-_> <Plug>(caw:hatpos:toggle)

Plug 'kana/vim-surround'

Plug 'tpope/vim-fugitive'
set statusline=%<[%n]%{fugitive#statusline()}\ %F\ %h%r%m[%{&fenc}][%{&ff=='unix'?'LF':&ff=='dos'?'CRLF':'CR'}]\ %=[0x%B]\ %c,%l/%L\ %y

Plug 'tpope/vim-rhubarb'

Plug 'thinca/vim-template'
let g:template_basedir = $VIMLOCAL . '/templates'
let g:template_files = '**'
let g:template_free_pattern = 'skel-\?'
let g:comment_oneline_only_ft = {
    \ 'python': 1,
    \ 'ruby': 1,
    \ 'sh': 1,
    \ }
augroup vimtemplate
  au!
  au User plugin-template-loaded call s:template_keywords()
augroup END
function! s:template_keywords() abort
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

Plug 'w0rp/ale'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'go': ['go build', 'go vet'],
      \ 'review': ['review-compile'],
      \ 'graphql': ['gqlint'],
      \ }
let g:ale_python_mypy_options = '--ignore-missing-imports'
let text_linters = [
      \ {buffer -> {'command': 'textlint -c ~/.config/textlintrc -o /dev/null --fix --no-color --quiet %t', 'read_temporary_file': 1}},
      \ {buffer -> {'command': 'prh --rules ~/.config/prh.default.yml --stdout %t'}},
      \ ]
function! s:protocol_markdown(buffer) abort
  let l:executable = ale#Escape('protocol')
  let l:new_lines = []
  let l:protocol_definition_line = 0
  let l:in_code_block = 0

  for l:line in getbufline(a:buffer, 1, '$')
    if l:in_code_block && match(l:line, '\v^```$') >= 0
      let l:in_code_block = 0
    endif
    if l:in_code_block && l:protocol_definition_line
      call add(l:new_lines, l:line)
      call add(l:new_lines, '')
      let l:figure = system(l:executable . ' ' . ale#Escape(l:line))
      call extend(l:new_lines, split(l:figure, '\n'))
      let l:protocol_definition_line = 0
      continue
    endif
    if l:in_code_block
      continue
    endif
    if match(l:line, '\v^```protocol$') >= 0
      let l:protocol_definition_line = 1
      let l:in_code_block = 1
    endif
    call add(l:new_lines, l:line)
  endfor

  return l:new_lines
endfunction
let g:ale_fixers = {
      \ 'go': ['goimports'],
      \ 'javascript': ['prettier', 'eslint'],
      \ 'typescript': ['prettier', 'eslint'],
      \ 'python': ['autopep8', 'isort'],
      \ 'markdown': text_linters + [funcref('s:protocol_markdown')],
      \ 'review': text_linters,
      \ 'vue': ['prettier', 'eslint'],
      \ 'proto': ['clang-format'],
      \ 'sh': ['shfmt'],
      \ 'terraform': ['terraform'],
      \ 'typescriptreact': ['prettier'],
      \ 'css': ['prettier'],
      \ 'graphql': ['prettier'],
      \ }
let g:ale_fix_on_save = 1

Plug 'naoina/ale-linter-review'
Plug 'naoina/ale-solidity'
let g:ale_fixers['solidity'] = ['solium']
let g:ale_linters['solidity'] = ['truffle', 'solhint', 'solium']

Plug 'mattn/webapi-vim'
Plug 'tpope/vim-rails'
Plug 'othree/html5.vim'
Plug 'moro/vim-review'
Plug 'cespare/vim-toml'

Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_new_list_item_indent = 0

Plug 'AndrewRadev/switch.vim', { 'on': 'Switch' }
let g:switch_mapping = ''
nnoremap - :Switch<CR>
function! OnloadSwitch() abort
  let g:switch_definitions =
        \ [
        \   g:switch_builtins.ampersands,
        \   g:switch_builtins.capital_true_false,
        \   g:switch_builtins.true_false,
        \   ['==', '!='],
        \ ]
endfunction
augroup SwitchVim
  au!
  au User switch.vim call OnloadSwitch()
augroup END

Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'

Plug 'daisuzu/rainbowcyclone.vim'
map * <Plug>(rc_highlight_with_cursor_complete)

Plug 'gf3/peg.vim'
Plug 'wavded/vim-stylus'
Plug 'digitaltoad/vim-pug'
Plug 'rhysd/committia.vim'
Plug 'othree/yajs.vim'

Plug 'haya14busa/incsearch.vim'
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
let g:incsearch#emacs_like_keymap = 1
let g:incsearch#vim_cmdline_keymap = 0

Plug 'haya14busa/incsearch-migemo.vim'
map m/ <Plug>(incsearch-migemo-/)
map m? <Plug>(incsearch-migemo-?)

Plug 'thinca/vim-quickrun'
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
nnoremap <silent><leader>r :QuickRun<CR>

Plug 'mattn/gist-vim', { 'on': 'Gist' }
let g:gist_detect_filetype = 1
let g:gist_private = 0

let g:colorv_filetypes = [
      \ 'css', 'scss', 'stylus', 'less', 'sass',
      \ 'html', 'xhtml', 'xml', 'gohtmltmpl', 'mako', 'erb', 'htmldjango',
      \ 'vim',
      \ ]
Plug 'Rykka/colorv.vim', { 'for': g:colorv_filetypes }
let g:colorv_no_global_map = 1
let g:colorv_preview_ftype = join(g:colorv_filetypes, ',')

Plug 'mattn/emmet-vim', {
      \ 'for': ['html', 'xhtml', 'xml', 'htmldjango', 'mako', 'eruby', 'php', 'smarty', 'vue', 'gohtmltmpl', 'typescriptreact'],
      \ }

Plug 'klen/python-mode', { 'for': ['python'] }
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

Plug 'jmcantrell/vim-virtualenv', { 'for': ['python'] }

Plug 'kchmck/vim-coffee-script'
let g:coffee_compile_vert = 1

Plug 'mustache/vim-mustache-handlebars'

" Plug 'fatih/vim-go'
let g:go_fmt_fail_silently = 1
let g:go_fmt_autosave = 0
let g:go_highlight_extra_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_format_strings = 1
let g:go_fmt_command = 'goimports'
let g:go_snippet_engine = 'ultisnipts'
let g:go_def_mapping_enabled = 0
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let g:go_gocode_unimported_packages = 1
let g:go_template_autocreate = 0
let g:go_gocode_propose_source = 0

Plug 'buoto/gotests-vim'
let g:gotests_template_dir = expand('~/.config/gotests/templates')

Plug '110y/vim-go-expr-completion', { 'do': 'go get -u github.com/110y/go-expr-completion' }

function! s:asyncomplete_register_source(name, options) abort
  exec 'augroup' 'Asyncomplete_' . a:name
    exec 'au! User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#' . a:name . '#get_source_options(' . string(extend({
          \ 'name': a:name,
          \ 'whitelist': ['*'],
          \ 'completor': function('asyncomplete#sources#' . a:name . '#completor'),
          \}, a:options)) . '))'
  augroup END
endfunction
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
call s:asyncomplete_register_source('buffer', {
      \ 'config': {
      \     'max_buffer_size': -1,
      \ }})
Plug 'prabirshrestha/asyncomplete-file.vim'
call s:asyncomplete_register_source('file', {
      \ 'priority': 10,
      \ })
Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
call s:asyncomplete_register_source('ultisnips', {})
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
let g:lsp_text_edit_enabled = 1
let g:lsp_signature_help_enabled = 0
let g:lsp_highlight_references_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_document_code_action_signs_enabled = 0
highlight link LspErrorText Error
highlight link LspWarningText Error
highlight link LspInformationText Error
highlight link LspHintText Error
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gi <plug>(lsp-implementation)
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
let g:lsp_settings = {
      \ 'gopls': {
        \ 'initialization_options': {
          \ 'completeUnimported': v:true,
          \ 'matcher': 'fuzzy',
          \ 'usePlaceholders': v:true,
          \ 'staticcheck': v:true,
        \ }
      \ }
    \ }
Plug 'thomasfaingnaert/vim-lsp-snippets'
Plug 'thomasfaingnaert/vim-lsp-ultisnips'

Plug 'sebdah/vim-delve', { 'for': ['go'] }
Plug 'buoto/gotests-vim'
" Plug 'tcnksm/gotests', { 'rtp': 'editor/vim' }
Plug 'vim-scripts/Align', { 'on': ['Align'] }
Plug 'tpope/vim-repeat'
Plug 'editorconfig/editorconfig-vim'

Plug 'Yggdroot/indentLine', { 'for': ['coffee', 'python', 'jade', 'pug', 'stylus', 'haml'] }
let g:indentLine_enabled = 0

Plug 'junegunn/vader.vim.git', { 'on': ['Vader'], 'for': ['vader'] }

Plug 'naoina/previm', { 'for': ['markdown'] }
let g:previm_open_cmd = 'xdg-open'
let g:previm_show_header = 0

Plug 'posva/vim-vue'
Plug 'tpope/vim-unimpaired'

Plug 'rupurt/vim-mql5'
augroup VimMQL5
  au! BufNewFile,BufReadPost *.mq4 set filetype=mql5
augroup END

Plug 'tomlion/vim-solidity'
Plug 'jparise/vim-graphql'
Plug 'hashivim/vim-terraform'

call plug#helptags()
call plug#end()

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
set display=lastline
set mouse=n

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,japan,cp932,utf-16,utf-8
set fileformats=unix,dos,mac
set nofixendofline
set updatetime=500

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
    call mkdir(a:dir, 'p', a:perm)
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
  if line("'\"") > 1 && line("'\"") <= line('$')
    normal! g`"
  endif
endfunction

function! s:refresh()
  setlocal autoread
  redr!
  set autoread<
  if exists(':RCReset')
    RCReset
  endif
endfunction

function! s:tohtml_and_browse()
  TOhtml
  let webbrowser = 'chromium'
  let tempfile = tempname()
  write `=tempfile`
  exec '!' . webbrowser . ' ' . tempfile
  bdelete!
  call delete(tempfile)
endfunction
command! TOhtmAndBrowse :call s:tohtml_and_browse()

function! s:to_xxd()
  silent %!xxd -g 1
  setlocal filetype=xxd
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

  let b:switch_definitions =
        \ [
        \   ['===', '!=='],
        \ ]
endfunction

function! s:typescript_setting()
  call s:javascript_setting()
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
  if exists(':DlvToggleBreakpoint')
    nnoremap <silent><buffer><leader>b :DlvToggleBreakpoint<CR>
  endif
  nnoremap <silent><buffer>ge :<C-u>call go#expr#complete()<CR>
endfunction

function! s:gotexttmpl_setting()
  call s:go_setting()
endfunction

function! s:gohtmltmpl_setting()
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
  if exists('*' . a:funcname)
    exec 'call ' . a:funcname
  endif
endfunction

function! s:setting()
  let prefix = 's:' . &filetype

  let f = prefix . '_setting()'
  call s:call_if_exists(f)

  " For surround of kana's version.
  if exists('*SurroundRegister')
    let g:surround_indent = 1

    let f = prefix . '_surround()'
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
  au BufNewFile,BufRead *.tpl      setlocal filetype=gotexttmpl
  au BufNewFile,BufRead *.html.tpl setlocal filetype=gohtmltmpl

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
" nnoremap <silent><expr><C-p> len(filter(range(1, winnr('$')), 'getbufvar(winbufnr(v:val), "&buftype") == "quickfix"')) ? ":\<C-u>cN\<CR>" : ":\<C-u>bN\<CR>"
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
imap <C-h> <BS>

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
