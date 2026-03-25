" Plain vim fallback config — nvim uses ~/.config/nvim/init.lua
" vim-plug manages plugins for vim only
set nocompatible

call plug#begin('~/.vim/bundle')

Plug 'thomwiggers/vim-colors-solarized'	" solarized (vim fallback)
Plug 'neomake/neomake'			" async syntax checker
Plug 'davidhalter/jedi-vim'		" python completion
Plug 'Vimjas/vim-python-pep8-indent'	" python pep8
Plug 'lervag/vimtex'			" LaTeX
Plug 'airblade/vim-gitgutter'		" git changes in gutter
Plug 'tpope/vim-fugitive'		" git commit/diff/...
Plug 'preservim/nerdcommenter'		" comments
Plug 'kshenoy/vim-signature'		" display,toggle and iterate marks
Plug 'ctrlpvim/ctrlp.vim'		" ctrl p filebrowser
Plug 'SirVer/ultisnips'			" snippet engine
Plug 'honza/vim-snippets'		" snippets
Plug 'rust-lang/rust.vim'		" vim rust ftplugin
Plug 'pearofducks/ansible-vim'		" ansible ftplugin
Plug 'editorconfig/editorconfig-vim'	" EditorConfig file support
Plug 'dbeniamine/todo.txt-vim'		" todo.txt support

call plug#end()
filetype plugin indent on

" DISPLAY OPTIONS
colorscheme solarized
set background=dark
set display+=lastline
set showmode
let &showbreak = ' ↳  '
set laststatus=2
set nu
set matchpairs=(:),[:],{:},<:>
set list
set listchars=tab:▸\ ,trail:·,precedes:«,extends:»
set mouse=a

" be quiet
set noerrorbells
set novisualbell

" always report on changes
set report=0

" vim-only settings
if !has('nvim')
	set syntax
	set nobackup
	set showmatch
endif

" SEARCH OPTIONS
set ignorecase
set smartcase
set hlsearch

" make the history longer
set history=1000

" save undo history
set undofile
set undodir=$HOME/.vim/undo
if !isdirectory($HOME.'/.vim/undo')
	call mkdir($HOME.'/.vim/undo', "p")
endif

" use own skeletons for new files
au BufNewFile *.py 0r ~/.vim/skeleton/skeleton.py | normal | Gdd

" FOLDS
set foldmethod=marker
autocmd BufWrite *.* mkview
autocmd BufRead  *.* silent! loadview

" WRITING
set autowrite
set hidden
cmap w!! %!sudo tee > /dev/null %

" COMPLETION
set wildchar=<TAB>
set wildmenu
set wildmode=full
set wildignore+=*.*~,*.acn,*.acr,*.alg,*.aux,*.bbl,*.bcf,*.blg,*.dvi,*.fdb_latexmk,*.fls,
set wildignore+=*.glg,*.glo,*.gls,*.ist,*.latexmain,*.log,*.nav,*.nlo,*.out,*.pdf*,
set wildignore+=*.run.xml,*.slg,*.snm,*.syg,*.syi,*.synctex.gz,*.tdo,*.toc,*/tmp/*

" keep selection when re-indenting
vnoremap < <gv
vnoremap > >gv

" LaTeX: latex instead of plain-tex
let g:tex_flavor = "latex"

" tikz is tex
autocmd Bufread,BufNewFile *.tikz set filetype=tex

" PLUGIN CONFIGURATION
" ultisnips
let g:UltiSnipsSnippetsDir="~/.vim/bundle/vim-snippets/UltiSnips"
let g:UltiSnipsExpandTrigger="<s-enter>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" run Neomake when writing a file
function! Run_neomake()
	if exists(':Neomake')
		Neomake
	endif
endfunction

" activate live substitution
if exists('&inccommand')
	set inccommand=split
	set incsearch
endif
autocmd! BufWritePost * call Run_neomake()
