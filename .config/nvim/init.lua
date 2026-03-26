-----------------
-- Python host --
-----------------
vim.g.python3_host_prog = vim.fn.expand("~/.local/venv/nvim/bin/python3")

----------
-- lazy --
----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")

-------------
-- Options --
-------------
local o = vim.o

o.encoding      = "utf-8"
o.termguicolors = true
o.background    = "dark"
o.showmode      = true
o.laststatus    = 2
o.number        = true
o.report        = 0
o.mouse         = "a"

-- search
o.ignorecase = true
o.smartcase  = true
o.hlsearch   = true
o.incsearch  = true
o.inccommand = "split"   -- live substitution preview

-- history & undo
o.history  = 1000
o.undofile = true

-- editing
o.hidden     = true
o.autowrite  = true

-- display
o.list      = true
o.listchars = "tab:▸ ,trail:·,precedes:«,extends:»"
o.showbreak = " ↳  "
o.display   = "lastline"
o.matchpairs = "(:),[:],{:},<:>"

-- folds
o.foldmethod = "marker"

-- completion
o.wildmenu = true
o.wildmode = "full"
o.wildignore = table.concat({
    "*.*~,*.acn,*.acr,*.alg,*.aux,*.bbl,*.bcf,*.blg,*.dvi,*.fdb_latexmk,*.fls",
    "*.glg,*.glo,*.gls,*.ist,*.log,*.nav,*.nlo,*.out,*.pdf*",
    "*.run.xml,*.slg,*.snm,*.syg,*.syi,*.synctex.gz,*.toc,*/tmp/*",
}, ",")

-- bells
o.errorbells  = false
o.visualbell  = false

-- keep selection when re-indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- sudo write
vim.cmd("cmap w!! %!sudo tee > /dev/null %")

-- LaTeX: default to latex, not plain-tex
vim.g.tex_flavor = "latex"

------------------
-- Autocommands --
------------------
local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

-- persist folds
ag("Folds", { clear = true })
au("BufWinLeave", { group = "Folds", pattern = "*", command = "silent! mkview" })
au("BufWinEnter", { group = "Folds", pattern = "*", command = "silent! loadview" })

-- python skeleton
au("BufNewFile", { pattern = "*.py", command = "0r ~/.vim/skeleton/skeleton.py | normal | Gdd" })

-- tikz = tex
au({ "BufRead", "BufNewFile" }, { pattern = "*.tikz", command = "set filetype=tex" })

-- root auto-logout
if vim.env.USER == "root" then
    vim.o.timeout = true
    vim.g.netrw_tmout = 300
end
