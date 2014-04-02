" TABSTOPS
set tabstop=4       " Anzahl der Zeichen, die ein Tab breit dargestellt wird
set shiftwidth=4    " Autoeinrückung: 4 Leerzeichen einrücken zum Zeilenbeginn, sonst tab
set softtabstop=4   " Anzahl der Leerzeichen, die einem Tab entsprechen
set cindent         " Setzt shiftwidth Leerzeichen am Zeilenanfang und tabstop / softtabstop sonst
set expandtab       " Tabs are 4 Spaces and Spaces are Spaces!

setlocal number

" Zeilenlänge auf 80 Zeichen begrenzen und anzeigen:
setlocal textwidth=80
if exists('+colorcolumn')
    setlocal colorcolumn=80
    highlight OverLength ctermbg=red ctermfg=white guibg=#592929
    match OverLength /\%81v.*/
else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

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

" abbreviations for python
iabbrev ipdb import ipdb; ipdb.set_trace()
iabbrev IMNUM import numpy as num
iabbrev IMPLT import matplotlib as plt
iabbrev IMMAT import matplotlib as plt
iabbrev IMPD import pandas as pd
iabbrev FROSCIL from scipy.io import loadmat
iabbrev FROSCIS from scipy.io import savemat
