" be iMproved, required by vundle
set nocompatible

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
" alternatively, pass a path where Vundle should install plugins
"let path = '~/some/path/here'
"call vundle#rc(path)

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'

" Plugins
Plugin 'Lokaltog/vim-powerline'             " powerline
"Plugin 'bling/vim-airline'                  " powerline
Plugin 'syntastic'                          " syntax checker
Plugin 'ervandew/supertab'                  " smart tab key
Plugin 'Valloric/YouCompleteMe'             " code completion (incl. jedi python completion)
Plugin 'davidhalter/jedi-vim'               " python completion
Plugin 'hynek/vim-python-pep8-indent'       " python pep8
Plugin 'LaTeX-Box-Team/LaTeX-Box'           " Lightweight Toolbox for LaTeX
Plugin 'airblade/vim-gitgutter'             " git changes in gutter
Plugin 'tpope/vim-fugitive'                 " git commit/diff/...
Plugin 'scrooloose/nerdcommenter'           " comments
Plugin 'thomwiggers/vim-colors-solarized'   " solarized colors
Plugin 'kshenoy/vim-signature'              " display,toggle and iterate marks
Plugin 'kien/ctrlp.vim'                     " ctrl p filebrowser
Plugin 'tpope/vim-surround'                 " parentheses, brackets, ...
"Plugin 'Raimondi/delimitMate'               " insert pairs of brackets automatically
Plugin 'SirVer/ultisnips'                   " sniplets engine
Plugin 'honza/vim-snippets'                 " sniplets
"Plugin 'terryma/vim-multiple-cursors'       " multiple cursors :)
Plugin 'ivanov/vim-ipython'                 " communication with ipython kernels

set nu              " Zeilen nummerieren
set autoindent      " Auto Einrückung
set smartindent     " Aktiviert inteliggente C-Syntax rkennung und Einrückung

set enc=utf-8
set nobackup          " Erstellt ein Backup (file~) von jeder Datei

set matchpairs=(:),[:],{:},<:>  " Klammer-Paare kennzeichnen
set showmatch       " zeigt kurz öffnende/schließende Klammer an

" persistent undo in vim 7.3:
if v:version >= 703
    set undofile    " save undo files after close
    set undodir=$HOME/.vim/undo
    if !isdirectory($HOME.'/.vim/undo')
        call mkdir($HOME.'/.vim/undo', "p")
    endif
endif

" TABSTOPS
set tabstop=4       " Anzahl der Zeichen, die ein Tab breit dargestellt wird
set shiftwidth=4    " Autoeinrückung: 4 Leerzeichen einrücken zum Zeilenbeginn, sonst tab
set softtabstop=4   " Anzahl der Leerzeichen, die einem Tab entsprechen
"set cindent         " Setzt shiftwidth Leerzeichen am Zeilenanfang und tabstop / softtabstop sonst
set expandtab       " Tabs are 4 Spaces and Spaces are Spaces!

" mouse and gui
" system clipboard verwenden
if has('gui')
    set clipboard=unnamed
endif

"" mouse: scrolling and selecting with mouse
"set mouse=a
"" menu on right-click im gvim
"set mousemodel=popup
""hide cursor when typing
"set mousehide


" Colors? Plugins? Sure ..
syntax enable
set background=dark
colorscheme solarized

" Dateispezifische einstellungen laden?
filetype on
filetype plugin on
filetype indent on

" display control chars
set list listchars=tab:»·,trail:·
set list

"highlight the cursor line
set cursorline

" powerline:
let g:Powerline_symbols = 'fancy'

" modeline
"set modeline

" keep selection when re-indenting
vnoremap < <gv
vnoremap > >gv

" toggle paste mode
set pastetoggle=<F12>

" 2 is much smarter
set backspace=2

" Willkommensnachricht
"autocmd VimEnter * echo "Welcome back Hensing :)"
"autocmd VimLeave * echo "Cya in Hell."

" auto folds schreiben und laden
autocmd BufWrite *.* mkview
autocmd BufRead *.* silent loadview

" falten an markern als default
set foldmethod=marker

" be quiet
set noerrorbells
set novisualbell

" the mindestheight for ':help'
set helpheight=20

" dont close changed window
set hidden

" make the history longer
set history=500

" Stop the highlighting for the 'hlsearch' option.
set hlsearch

" ignore case-sensitive while search
" allow no-case-sensitive-search
set noignorecase

" show statusline
set laststatus=2

" Set 'magic' patterns ;)
" Examples:
"  \v       \m       \M       \V         matches ~
"  $        $        $        \$         matches end-of-line
"  .        .        \.       \.         matches any character
"  *        *        \*       \*         any number of the previous atom
"  ()       \(\)     \(\)     \(\)       grouping into an atom
"  |        \|       \|       \|         separating alternatives
"  \a       \a       \a       \a         alphabetic character
"  \\       \\       \\       \\         literal backslash
"  \.       \.       .        .          literal dot
"  \{       {        {        {          literal '{'
"  a        a        a        a          literal 'a'
set magic

" always report changes
set report=0

" Execute ':!<command>' with Zsh. I use Zsh, Ksh and Sh. In this
" order! No Bash, no Tcsh and no other toys.
" -l is equivalent to --login (See zsh --help for details)
set shell=zsh\ -l

" display current mode
set showmode

" :help tags Read it + understand it = add it!
set tags=./tags,tags

" break the line
" type to start wildcard expansion in the command-line
set wildchar=<TAB>

" When 'wildmenu' is on, command-line completion operates in an
" enhanced mode.
set wildmenu
set wildmode=longest,list

" omnicompletion keybinding
"inoremap <C-Space> <C-x><C-o>
"inoremap <C-@> <C-Space>
"if !has("gui_running")
"    inoremap <C-@> <C-x><C-o>
"endif

" terminal stuff
if &term=="rxvt"
	set term=xterm
endif
if &term=="xterm" || &term=="rxvt"
	set t_Co=8
	set t_Sf=[3%dm
	set t_Sb=[4%dm
	if !has("xterm_save")
		set t_ti=[?47h
		set t_te=[?47l
	endif
endif


" list files in current directory.
map ,ls :!ls <CR>
" write as sudo
cmap w!! %!sudo tee > /dev/null %

" Hilfe Texte navigieren:
map <F11> <C-]>
map <F10> <C-T>

" Vorlagen für neue Dateien verwenden:
au BufNewFile *.py 0r ~/.vim/skeleton/skeleton.py | normal | Gdd

" YouCompleteMe

" tab via supertab
let g:SuperTabDefaultCompletionType = '<C-n>'

" ycm via Ctrl-n == tab via supertab
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<UP>']
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

" disable jedi completion and popups:
let g:jedi#completions_command = ""
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
let g:jedi#use_tabs_not_buffers = 0

" jedi goto, docu etc...
let g:jedi#goto_assignments_command = "<leader>ja"
let g:jedi#goto_definitions_command = "<leader>jd"
let g:jedi#documentation_command = "<leader>jh"
let g:jedi#rename_command = "<leader>jr"
let g:jedi#usages_command = "<leader>js"    " show similar commands

" ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" ftdetect for ultisnip
autocmd FileType * call UltiSnips#FileTypeChanged()
autocmd BufNewFile,BufRead *.snippets setf snippets

