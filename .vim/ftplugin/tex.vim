set tabstop=4       " Anzahl der Zeichen, die ein Tab breit dargestellt wird
set expandtab       " Tabs are 4 Spaces and Spaces are Spaces!
set shiftwidth=4    " Autoeinrückung: 4 Leerzeichen einrücken zum Zeilenbeginn, sonst tab
set softtabstop=4   " Anzahl der Leerzeichen, die einem Tab entsprechen
"set nocindent         " Setzt shiftwidth Leerzeichen am Zeilenanfang und tabstop / softtabstop sonst

set smartindent
set formatoptions=tcqn

set wrap
set wrapmargin=0
set textwidth=0
set linebreak
set nolist
set virtualedit=
set display+=lastline

" navigieren wie angezeigt:
noremap  <buffer> <silent> <Up>   gk
noremap  <buffer> <silent> <Down> gj
noremap  <buffer> <silent> <Home> g<Home>
noremap  <buffer> <silent> <End>  g<End>
inoremap <buffer> <silent> <Up>   <C-o>gk
inoremap <buffer> <silent> <Down> <C-o>gj
inoremap <buffer> <silent> <Home> <C-o>g<Home>
inoremap <buffer> <silent> <End>  <C-o>g<End>

" latexbox:
imap <buffer> [[     \begin{
imap <buffer> ]]     <Plug>LatexCloseCurEnv
nmap <buffer> <F5>   <Plug>LatexChangeEnv
vmap <buffer> <F7>   <Plug>LatexWrapSelection
vmap <buffer> <S-F7> <Plug>LatexEnvWrapSelection
imap <buffer> ((     \eqref{
" don't jump to quickfix when error occurs
let g:LatexBox_quickfix = 2
