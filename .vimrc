" be iMproved, required by vundle
set nocompatible
filetype off					" required (vundle)

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'			" required (vundle)

" OTHER PLUGINS
Plugin 'vim-airline/vim-airline'		" powerline
Plugin 'thomwiggers/vim-colors-solarized'	" solarized colors
Plugin 'benekastah/neomake'			" async. syntax checker
Plugin 'davidhalter/jedi-vim'			" python completion
Plugin 'hynek/vim-python-pep8-indent'		" python pep8
Plugin 'LaTeX-Box-Team/LaTeX-Box'		" Lightweight Toolbox for LaTeX
Plugin 'airblade/vim-gitgutter'			" git changes in gutter
Plugin 'tpope/vim-fugitive'			" git commit/diff/...
Plugin 'scrooloose/nerdcommenter'		" comments
Plugin 'kshenoy/vim-signature'			" display,toggle and iterate marks
Plugin 'kien/ctrlp.vim'				" ctrl p filebrowser
Plugin 'SirVer/ultisnips'			" sniplets engine
Plugin 'honza/vim-snippets'			" sniplets
"Plugin 'ivanov/vim-ipython'			" communication with ipython kernels
Plugin 'rust-lang/rust.vim'			" vim rust ftplugin
Plugin 'Valloric/YouCompleteMe'			" completion for several languages

" all plugins must be added before this line
call vundle#end()				" required (vundle)
filetype plugin indent on			" required (vundle)

" DISPLAY OPTIONS
colorscheme solarized
set background=dark
set display+=lastline			" display last edited line
set showmode				" display current mode
set laststatus=2			" show last status
set nu					" line numbers
set matchpairs=(:),[:],{:},<:>		" set matching brackets, etc.
set list listchars=tab:»·,trail:·	" display tabs and trailing spaces

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
" keep selection when re-indenting
vnoremap < <gv
vnoremap > >gv

" PLUGIN CONFIGURATION
" airline config
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" YouCompleteMe options
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'
" let g:ycm_path_to_python_interpreter='/usr/bin/python/'

" use omnicomplete whenever there's no completion engine
set omnifunc=syntaxcomplete#Complete
let g:ycm_key_list_select_completion = ['<Tab>']
let g:ycm_key_list_previous_completion = ['<S-Tab>']

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
autocmd! BufWritePost * call Run_neomake()
