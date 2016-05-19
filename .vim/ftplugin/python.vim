" TABSTOPS
set tabstop=4       " Anzahl der Zeichen, die ein Tab breit dargestellt wird
set shiftwidth=4    " Autoeinrückung: 4 Leerzeichen einrücken zum Zeilenbeginn, sonst tab
set softtabstop=4   " Anzahl der Leerzeichen, die einem Tab entsprechen
set cindent         " Setzt shiftwidth Leerzeichen am Zeilenanfang und tabstop / softtabstop sonst
set expandtab       " Tabs are 4 Spaces and Spaces are Spaces!
set smarttab

setlocal number

" Zeilenlänge auf 80 Zeichen begrenzen und anzeigen:
setlocal textwidth=80
setlocal colorcolumn=80

" highlight chars > 105 characters (PEP8)
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%106v.*/

" file encoding
set fileencoding=utf8
set nobomb  " don't write byte order mark

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
setlocal formatoptions=cronqlj

" abbreviations for python
iabbrev ipdb import ipdb; ipdb.set_trace()
iabbrev IMNUM import numpy as num
iabbrev IMPLT import matplotlib as plt
iabbrev IMMAT import matplotlib as plt
iabbrev IMPD import pandas as pd
iabbrev FROSCIL from scipy.io import loadmat
iabbrev FROSCIS from scipy.io import savemat

" remove trailing whitespace on writing buffer
autocmd BufWritePre * :%s/\s\+$//e

if executable('flake8')
	let g:syntastic_python_checkers=['flake8']
endif
let g:syntastic_python_flake8_args='--ignore=E501'
let g:syntastic_check_on_open = 1
let g:syntastic_auto_loc_list=1
let g:syntastic_loc_list_height=5
let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'

" jedi-vim {
let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
let g:jedi#completions_enabled = 1
let g:jedi#smart_auto_mappings = 0
let g:jedi#completions_command = ""
let g:jedi#show_call_signatures = "1"

let g:jedi#goto_assignments_command = "<leader>pa"
let g:jedi#goto_definitions_command = "<leader>pd"
let g:jedi#documentation_command = "<leader>pd"
let g:jedi#usages_command = "<leader>pu"
let g:jedi#rename_command = "<leader>pr"
" }
"
if executable('flake8')
	let g:neomake_python_enabled_makers = ['flake8', 'pep8']
else
	let g:neomake_python_enabled_makers = ['pep8']
endif
" E501 is line length of 80 characters, I don't want to see all those errors
let g:neomake_python_flake8_maker = { 'args': ['--ignore=E501'], }
let g:neomake_python_pep8_maker = { 'args': ['--max-line-length=105'], }

" to make jedi etc. work properly in virtual environments
py << EOF
import os.path
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, project_base_dir)
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF
