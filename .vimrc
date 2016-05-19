" be iMproved, required by vundle
set nocompatible

" init vim-plug
call plug#begin('~/.vim/plugged')

Plug 'bling/vim-airline'		" powerline
Plug 'thomwiggers/vim-colors-solarized'	" solarized colors
Plug 'Valloric/YouCompleteMe'		" code completion (incl. jedi python completion)
Plug 'benekastah/neomake'		" async. syntax checker
Plug 'davidhalter/jedi-vim'		" python completion
Plug 'hynek/vim-python-pep8-indent'	" python pep8
Plug 'LaTeX-Box-Team/LaTeX-Box'		" Lightweight Toolbox for LaTeX
Plug 'airblade/vim-gitgutter'		" git changes in gutter
Plug 'tpope/vim-fugitive'		" git commit/diff/...
Plug 'scrooloose/nerdcommenter'		" comments
Plug 'kshenoy/vim-signature'		" display,toggle and iterate marks
Plug 'kien/ctrlp.vim'			" ctrl p filebrowser
Plug 'SirVer/ultisnips'			" sniplets engine
Plug 'honza/vim-snippets'		" sniplets
"Plug 'ivanov/vim-ipython'		" communication with ipython kernels
Plug 'rust-lang/rust.vim'		" vim rust ftplugin

call plug#end()

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

" YouCompleteMe
nnoremap <leader>jd :YcmCompleter GoTo<CR>
