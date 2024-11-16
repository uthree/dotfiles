"---------------------------------------
"  Forked from Yanorei32 .vimrc
"---------------------------------------

"\
"| Tips. 
"|  ':source ~/.vimrc' to reload .vimrc
"/

"---------------------------------------
" Init
"---------------------------------------

filetype off
filetype plugin indent off

"---------------------------------------
" Plugin
"---------------------------------------

let g:rustfmt_autosave = 1

" check status
if has('vim_starting')
	" add runtime path
	set rtp+=~/.vim/plugged/vim-plug
	
	" install if not installed
	if !isdirectory(expand('~/.vim/plugged/vim-plug'))
		echo 'install vim-plug'

		echo 'create directory...'
		call system('mkdir -p ~/.vim/plugged/vim-plug')

		echo 'clone repo...'
		call system('git clone https://github.com/junegunn/vim-plug.git ~/.vim/plugged/vim-plug/autoload')

	endif
endif

call plug#begin('~/.vim/plugged')

" plugin manager
Plug 'junegunn/vim-plug', { 'dir': '~/.vim/plugged/vim-plug/autoload' }

" color schemes
Plug 'w0ng/vim-hybrid'
Plug 'jacoborus/tender.vim'
Plug 'tomasr/molokai'
Plug 'wojciechkepka/vim-github-dark'

" Vim fugitive
Plug 'tpope/vim-fugitive'

" lightline.vim
Plug 'itchyny/lightline.vim'

" toggle comment
Plug 'tomtom/tcomment_vim'

" vim surround ( text -> visual select and type S' -> 'text' )
Plug 'tpope/vim-surround'

" nerdtree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'

" Emmet
Plug 'mattn/emmet-vim'

" syntax
Plug 'hail2u/vim-css3-syntax'
Plug 'jelera/vim-javascript-syntax'
Plug 'vim-scripts/ShaderHighLight'
Plug 'cespare/vim-toml'

" Tabular (:Tableformat wrap)
Plug 'godlygeek/tabular'

" Rust
Plug 'rust-lang/rust.vim'

" vim-markdown (:Tableformat)
Plug 'rcmdnk/vim-markdown'

" Open Browser
Plug 'tyru/open-browser.vim'

" Previm (Markdown Preview)
Plug 'kannokanno/previm', { 'for': 'markdown' }

Plug 'simeji/winresizer'

Plug 'embear/vim-localvimrc'

" Nerd fonts
Plug 'ryanoasis/vim-devicons'

" LSP
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/vim-lsp-icons'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'andys8/vim-elm-syntax'

" Rainbow Parentheses Improved
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

Plug 'w0rp/ale'
call plug#end()

"---------------------------------------
" LSP
"---------------------------------------

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <f2> <plug>(lsp-rename)
  inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')
set completeopt=menuone,noinsert,noselect
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 50
let g:lsp_text_edit_enabled = 1
inoremap <expr><CR>  pumvisible() ? "<C-y>" : "<CR>"

"---------------------------------------
" Lightline Plugin
"---------------------------------------

" StatusLine show
set laststatus=2

" Show Tabline
set showtabline=2

" Vim Default Status Bar Mode View
set noshowmode

function! LightlineModified()
	return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
	return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'RO' : ''
endfunction

function! LightlineFilename()
	return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
\		(&ft == 'vimfiler' ? vimfiler#get_status_string() :
\		&ft == 'unite' ? unite#get_status_string() :
\		&ft == 'vimshell' ? vimshell#get_status_string() :
\		'' != expand('%:t') ? expand('%:t') : '[No Name]') .
\		('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

function! LightlineFugitive()
	if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
		let g:a = fugitive#head()
		if g:a != ''
			return ''.fugitive#head()
		else
			return 'No git'
		endif
	else
		return ''
	endif
endfunction

function! LightlineFileformat()
	return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
	return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
	return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightlineMode()
	return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

let g:lightline = {
\		'colorscheme': 'wombat',
\		'mode_map': { 'c': 'NORMAL' },
\		'active': {
\			'left': [
\				[ 'mode', 'paste' ],
\				[ 'fugitive', 'filename' ]
\			]
\		},
\		'component_function': {
\			'modified':			'LightlineModified',
\			'filename':			'LightlineFilename',
\			'readonly':			'LightlineReadonly',
\			'fileformat':		'LightlineFileformat',
\			'fugitive':			'LightlineFugitive',
\			'filetype':			'LightlineFiletype',
\			'fileencoding':	'LightlineFileencoding',
\			'mode':					'LightlineMode'
\		}
\	}

"---------------------------------------
" Minimap
"---------------------------------------
let g:minimap_width = 24
let g:minimap_auto_start = 0
let g:minimap_auto_start_win_enter = 1

map <C-m> <plug>MinimapToggle<CR>

highlight minimapCursor ctermbg=darkgray ctermfg=white

"---------------------------------------
" Other Plugins
"---------------------------------------

let g:vim_markdown_folding_disabled = 1
let g:localvimrc_persistent = 1

let g:NERDTreeGitStatusIndicatorMapCustom = {
\		"Modified"  : "✹",
\		"Staged"    : "✚",
\		"Untracked" : "✭",
\		"Renamed"   : "➜",
\		"Unmerged"  : "═",
\		"Deleted"   : "✖",
\		"Dirty"     : "✗",
\		"Clean"     : "✓",
\		"Unknown"   : "?"
\	}

map <C-n> <plug>NERDTreeTabsToggle<CR>

let g:ale_linters = {}
let g:ale_linters.markdown = ['textlint']
let g:ale_completion_enabled = 1

"---------------------------------------
" Language / Encoding
"---------------------------------------

" internal encoding
set encoding=utf-8

" terminal encoding
set termencoding=utf-8

set fileformats=unix,dos,mac
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,utf-16le,utf-16,default

"---------------------------------------
" Tab Short cut
"---------------------------------------

" set [Tag] key
nnoremap [Tag] <Nop>
nmap t [Tag]

" change tab shortcut <t-N>
for n in range(1,9)
	execute 'nnoremap <silent> [Tag]'.n ':<C-u>tabnext'.n.'<CR>'
endfor

nnoremap <silent> [Tag]c :tabnew<CR>
nnoremap <silent> [Tag]x :tabclose<CR>
nnoremap <silent> [Tag]n :tabnext<CR>
nnoremap <silent> [Tag]p :tabprevious<CR>

"---------------------------------------
" Syntax
"---------------------------------------

syntax on
set t_Co=256
set number
set numberwidth=8
set nowrap
set background=dark
set cursorline
set list
set listchars=tab:>\ ,trail:-,eol:¬,extends:»,precedes:«


" SYNTAX: ghdark
" colorscheme ghdark

" SYNTAX: hybrid
colorscheme hybrid 
let g:hybrid_reduced_contrast = 1

" " SYNTAX: molokai
" colorscheme molokai

" " SYNTAX: tender
" colorscheme tender

" cursor
set cursorline
hi clear cursorLine
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

"---------------------------------------
" Python F-String
"---------------------------------------

syn match pythonEscape +{{+ contained containedin=pythonfString,pythonfDocstring
syn match pythonEscape +}}+ contained containedin=pythonfString,pythonfDocstring

syn region pythonfString matchgroup=pythonQuotes
      \ start=+[fF]\@1<=\z(['"]\)+ end="\z1"
      \ contains=@Spell,pythonEscape,pythonInterpolation
syn region pythonfDocstring matchgroup=pythonQuotes
      \ start=+[fF]\@1<=\z('''\|"""\)+ end="\z1" keepend
      \ contains=@Spell,pythonEscape,pythonSpaceError,pythonInterpolation,pythonDoctest

syn region pythonInterpolation contained
      \ matchgroup=SpecialChar
      \ start=+{{\@!+ end=+}}\@!+ skip=+{{+ keepend
      \ contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue,pythonDoctest

syn match pythonStringModifier /:\(.[<^=>]\)\?[-+ ]\?#\?0\?[0-9]*[_,]\?\(\.[0-9]*\)\?[bcdeEfFgGnosxX%]\?/ contained containedin=pythonInterpolation
syn match pythonStringModifier /![sra]/ contained containedin=pythonInterpolation
syn match pythonStringModifier /\zs *= *\ze[}:!]/ contained containedin=pythonInterpolation

hi link pythonfString String
hi link pythonfDocstring String
hi link pythonStringModifier PreProc

"---------------------------------------
" Basic
"---------------------------------------

set nocompatible
set backspace=2

set tabstop=4
set shiftwidth=4
set autoindent
set smartindent

" Fast
set synmaxcol=300
set lazyredraw
set ttyfast
set re=1
set timeoutlen=1000 ttimeoutlen=0

set incsearch
set hlsearch

" search word display center
nmap n nzz
nmap N Nzz

" clear highlight after ctrl-l
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Disable multi-line comment
autocmd FileType * setlocal formatoptions-=ro

" Don't break select after ctrl-a and ctrl-x
vnoremap <c-a> <c-a>gv
vnoremap <c-x> <c-x>gv

" lsp key-bind, copy from nvim repo
nnoremap ==      :LspDocumentFormat<CR>
nnoremap <c-]>   :LspDefinition<CR>
nnoremap K       :LspHover<CR>
nnoremap gD      :LspImplementation<CR>
nnoremap <c-k>   :LspSignatureHelp<CR>
nnoremap 1gD     :LspTypeDefinition<CR>
nnoremap gr      :LspReferences<CR>
nnoremap g0      :LspDocumentSymbol<CR>
nnoremap gW      :LspWorkspaceSymbol<CR>
nnoremap gd      :LspDeclaration<CR>
nnoremap ]e      :LspNextError<CR>
nnoremap [e      :LspPreviousError<CR>

nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up>   gk

"---------------------------------------
" Mouse & Scroll
"---------------------------------------
set mouse=a
set ttymouse=sgr

"---------------------------------------
" Language configure
"---------------------------------------

autocmd FileType html,ruby,vim setlocal tabstop=2 shiftwidth=2

autocmd FileType python setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

autocmd FileType html setlocal matchpairs& matchpairs+=<:>

autocmd FileType cpp setlocal path=.,/usr/include/c++/6/

"---------------------------------------
" Rainbow Parentheses Improved
"---------------------------------------
let g:rainbow_conf = {
\	'ctermfgs': ['magenta', 'cyan', 'yellow'],
\ 'separately': {'nerdtree': 0}
\}


"---------------------------------------
" Nerd Fonts
"---------------------------------------
set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete\ 12
set encoding=utf-8

let g:WebDevIconsNerdTreeBeforeGlyphPadding = ""
let g:WebDevIconsUnicodeDecorateFolderNodes = v:true
" after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif


"---------------------------------------
" Terminal Settings
"---------------------------------------
"tnoremap <Esc> <C-\><C-n>
command T bo terminal

"---------------------------------------
" finalize
"---------------------------------------

filetype plugin indent on
filetype on