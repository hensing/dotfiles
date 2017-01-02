" TABSTOPS
set tabstop=4       " Anzahl der Zeichen, die ein Tab breit dargestellt wird
set shiftwidth=4    " Autoeinrückung: 4 Leerzeichen einrücken zum Zeilenbeginn, sonst tab
set softtabstop=4   " Anzahl der Leerzeichen, die einem Tab entsprechen
set cindent         " Setzt shiftwidth Leerzeichen am Zeilenanfang und tabstop / softtabstop sonst
set expandtab       " Tabs are 4 Spaces and Spaces are Spaces!

setlocal number

" file encoding
set fileencoding=utf8
set nobomb  " write byte order mark

" highlight repeated words
highlight DoubleWord ctermbg=darkred ctermfg=white guibg=#592929
match DoubleWord /\c\v<(\w+)\s+\1>/

" Formatoptionen setzen:
" a: automatic formatting of paragraphs when insering or deleting (nervt!!!)
" c: automatic formatting for comments
" t: automatic formatting for text
" r: repeat comment chars
" j: remove comment leader when joining lines
" n: numbered lists
" q: reformat comments with 'gq'
" l: Long lines are not broken in insert mode
" o: automatically insert the current comment leader after 'o' or 'O'
" w: trailing white space indicates a paragraph continues in the next line
if v:version >= 703
    setlocal formatoptions=cronqlj
else
    setlocal formatoptions=croql
endif

set wrap
set wrapmargin=0
set textwidth=0
set linebreak
"set nolist
"set virtualedit=
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

" compile async an background
let g:LatexBox_latexmk_async = 1

" add triggers to YCM for LaTeX-Box autocompletion
let g:ycm_semantic_triggers = {
\  'tex'  : ['{'],
\ }

" remove trailing whitespace on writing buffer
autocmd BufWritePre * :%s/\s\+$//e

" match \(chap|eq|fig|page|sec|)ref\(chap|eq|fig|page|sec|){
let g:LatexBox_ref_pattern = '\m\C\\v\?\(chap\|eq\|fig\|page\|sec\|tab\|[cC]\)\?ref\?\(chap\|eq\|fig\|page\|sec\|tab\|[cC]\)\?\*\?\_\s*{'
