" be iMproved, required by vundle
set nocompatible
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" other Plugins
Plugin 'vim-airline/vim-airline'		" powerline
Plugin 'thomwiggers/vim-colors-solarized'	" solarized colors
Plugin 'benekastah/neomake'			" async. syntax checker
Plugin 'davidhalter/jedi-vim'			" python completion
Plugin 'hynek/vim-python-pep8-indent'		" python pep8
Plugin 'LaTeX-Box-Team/LaTeX-Box'		" Lightweight Toolbox for LaTeX
Plugin 'airblade/vim-gitgutter'		" git changes in gutter
Plugin 'tpope/vim-fugitive'			" git commit/diff/...
Plugin 'scrooloose/nerdcommenter'		" comments
Plugin 'kshenoy/vim-signature'			" display,toggle and iterate marks
Plugin 'kien/ctrlp.vim'			" ctrl p filebrowser
Plugin 'SirVer/ultisnips'			" sniplets engine
Plugin 'honza/vim-snippets'			" sniplets
"Plugin 'ivanov/vim-ipython'			" communication with ipython kernels
Plugin 'rust-lang/rust.vim'			" vim rust ftplugin

" All of your Plugins must be added before the following line
call vundle#end()				" required
filetype plugin indent on			" required

" DISPLAY OPTIONS
colorscheme solarized
set background=dark
set display+=lastline			" display last edited line
set showmode				" display current mode
set laststatus=2			" show last status
set nu					" line numbers
set matchpairs=(:),[:],{:},<:>		" set matching brackets, etc.
set list listchars=tab:»·,trail:·	" display tabs and trailing spaces
set list

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
set history=500

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
" keep selection when re-indenting
vnoremap < <gv
vnoremap > >gv

" airline config
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" ultisnips
let g:UltiShipsSnippetsDir="~/.config/nvim/plugged/vim-snippets/snippets"
let g:UltiSnipsExpandTrigger="<tab>"
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
autocmd! BufWritePost * call Run_neomake()
