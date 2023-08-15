-- Visual Stuff
vim.o.cmdheight = 0
vim.o.concealcursor = ""
vim.o.conceallevel = 2
vim.o.termguicolors = true
vim.wo.colorcolumn = "+1"
vim.o.cursorline = true
vim.opt.fillchars = {
  stl = " ",
  stlnc = " ",
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
  fold = "─",
  eob = " ",
  diff = " ",
  msgsep = " ",
  foldopen = "▾",
  foldsep = "│",
  foldclose = "▸",
}
vim.o.inccommand = "split"
vim.o.laststatus = 3
vim.o.list = true
vim.opt.listchars = {
  tab = "╴╴",
  trail = "·",
  extends = "→",
  precedes = "←",
  nbsp = "•",
  eol = "↵",
}
vim.o.showmode = false
vim.o.ruler = false
vim.o.number = true
vim.o.numberwidth = 5
vim.o.pumblend = 15
vim.o.pumheight = 25
vim.o.scrolljump = 5
vim.o.scrolloff = 5
vim.o.shortmess = "atIW"
vim.o.showfulltag = true
vim.o.showmatch = true
vim.o.showtabline = 2
vim.o.signcolumn = "yes"
-- vim.o.statuscolumn = "%=%l %s%C"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.title = true
vim.o.wrap = true
vim.o.winblend = 15
vim.o.cpoptions = "aABceFsn_"

-- Search Stuff
vim.o.ignorecase = true
vim.o.magic = true
vim.o.smartcase = true
vim.o.cscopetag = true

-- Insert mode completion
vim.o.completeopt = "menu,menuone,noselect"

-- Commandline completion
vim.o.wildcharm = vim.api.nvim_eval([[char2nr("\<C-z>")]])
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "pum"

-- Indentation
vim.o.autoindent = true
vim.o.breakindent = true
-- vim.o.breakindentopt = ""
-- vim.o.copyindent = true
vim.o.expandtab = true
vim.o.preserveindent = true
-- vim.o.linebreak = true
vim.o.shiftround = true
vim.o.shiftwidth = 4
-- vim.o.showbreak = "↪"
-- vim.o.showbreak = ""
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.tabstop = 4
vim.o.textwidth = 0

-- Folding
vim.o.foldlevel = 20
vim.o.foldlevelstart = 20
vim.o.foldnestmax = 2
-- vim.o.foldmethod = "indent"
-- vim.o.foldenable = false

-- Other Settings
vim.g.localmapleader = " "
vim.g.mapleader = " "
vim.o.pastetoggle = "F2"
vim.o.autochdir = false
vim.o.backup = false
vim.o.hidden = true
vim.o.mouse = "a"
vim.o.swapfile = true
vim.o.virtualedit = "onemore"
vim.o.wildignore = "*.swp,.*bak,.*pyc,*.class,.*jar,*.o"

vim.o.background = "dark"
vim.api.nvim_command("syntax enable")
