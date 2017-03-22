" be iMproved, required by vundle
set nocompatible

" set the runtime path to include Vundle and initialize
"set rtp+=~/.vim/bundle/Vundle.vim
call plug#begin('~/.vim/bundle')
filetype off					" required (pluginmanager)

" OTHER PLUGINS
Plug 'vim-airline/vim-airline'		" powerline
Plug 'thomwiggers/vim-colors-solarized'	" solarized colors
Plug 'morhetz/gruvbox'			" gruvbox colors
Plug 'benekastah/neomake'			" async. syntax checker
Plug 'davidhalter/jedi-vim'			" python completion
Plug 'hynek/vim-python-pep8-indent'		" python pep8
Plug 'LaTeX-Box-Team/LaTeX-Box'		" Lightweight Toolbox for LaTeX
Plug 'airblade/vim-gitgutter'			" git changes in gutter
Plug 'tpope/vim-fugitive'			" git commit/diff/...
Plug 'scrooloose/nerdcommenter'		" comments
Plug 'kshenoy/vim-signature'			" display,toggle and iterate marks
Plug 'kien/ctrlp.vim'				" ctrl p filebrowser
Plug 'SirVer/ultisnips'			" sniplets engine
Plug 'honza/vim-snippets'			" sniplets
"Plug 'ivanov/vim-ipython'			" communication with ipython kernels
Plug 'rust-lang/rust.vim'			" vim rust ftplugin
Plug 'chase/vim-ansible-yaml'			" vim ansible ftplugin
"Plug 'Valloric/YouCompleteMe'			" completion for several languages
Plug 'ajh17/VimCompletesMe'			" very simple completion
Plug 'editorconfig/editorconfig-vim'		" EditorConfig File support
Plug 'dbeniamine/todo.txt-vim'		" todo.txt support

" all plugins must be added before this line
call plug#end()				" required (pluginmanager)
filetype plugin indent on			" required (vundle)

" DISPLAY OPTIONS
let g:gruvbox_italic=1
colorscheme solarized
"colorscheme gruvbox
set background=dark
set display+=lastline					" display last edited line
set showmode						" display current mode
let &showbreak = ' ↳  '					" show linebreak
set laststatus=2					" show last status
set nu							" line numbers
set matchpairs=(:),[:],{:},<:>				" set matching brackets, etc.
set list
set listchars=tab:▸\ ,trail:·,precedes:«,extends:»	" display tabs and trailing spaces

" be quiet
set noerrorbells
set novisualbell

" always report on changes
set report=0

" redefine vim settings
if !has('nvim')
	set syntax			" highlight syntax
	set nobackup			" dont create ~-files
	set showmatch			" show matching brackets etc.
endif

" SEARCH OPTIONS
set ignorecase				" ignore case-sensitivity
set smartcase				" same except for patterns containing upper case
set hlsearch				" highlight search

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
" load and write folds automatical
autocmd BufWrite *.* mkview
autocmd BufRead *.* silent! loadview

" WRITING
set autowrite				" write all files when calling :make
set hidden				" dont close changed window
" write as sudo
cmap w!! %!sudo tee > /dev/null %

" COMPLETION
set wildchar=<TAB>			" type to start wildcard expansion in the command-line
set wildmenu				" nicer autocompletion
set wildmode=full			" alternative: longest,list

" ignore pattern for files: ignore that TeX crap
set wildignore+=*.*~,*.acn,*.acr,*.alg,*.aux,*.bbl,*.bcf,*.blg,*.dvi,*.fdb_latexmk,*.fls,
set wildignore+=*.glg,*.glo,*.gls,*.ist,*.latexmain,*.log,*.nav,*.nlo,*.out,*.pdf*,
set wildignore+=*.run.xml,*.slg,*.snm,*.syg,*.syi,*.synctex.gz,*.tdo,*.toc,*/tmp/*

" keep selection when re-indenting
vnoremap < <gv
vnoremap > >gv

" LaTeX: latex instead of plain-tex
let g:tex_flavor = "latex"

" PLUGIN CONFIGURATION
" airline config
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" YouCompleteMe options
"let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'
" let g:ycm_path_to_python_interpreter='/usr/bin/python/'

" use omnicomplete whenever there's no completion engine
"set omnifunc=syntaxcomplete#Complete
"let g:ycm_key_list_select_completion = ['<Tab>']
"let g:ycm_key_list_previous_completion = ['<S-Tab>']

" ultisnips
let g:UltiShipsSnippetsDir="~/.config/nvim/plugged/vim-snippets/snippets"
let g:UltiSnipsExpandTrigger="<s-enter>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" run Neomake when writing a file if it is installed
" as plugins are only loaded after the vimrc is processed,
" if_exists(':Neomake') will always be false if called from within
" the vimrc
function Run_neomake()
	if exists(':Neomake')
		Neomake
	endif
endfunction

" activate live substitution
if exists('&inccommand')
	set inccommand=split
endif
autocmd! BufWritePost * call Run_neomake()
