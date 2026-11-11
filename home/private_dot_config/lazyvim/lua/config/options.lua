local opt = vim.opt

vim.g.copilot_nes = false
vim.g.autoformat = false

-- Visual Stuff
-- opt.cmdheight = 0
-- opt.concealcursor = ""
-- opt.conceallevel = 2
-- opt.termguicolors = true
-- vim.wo.colorcolumn = "+1"
-- opt.cursorline = true
opt.fillchars = {
  diff = " ",
  eob = " ",
  fold = " ",
  foldclose = "",
  foldopen = "",
  foldsep = " ",
  horiz = "━",
  horizdown = "┳",
  horizup = "┻",
  msgsep = " ",
  stl = " ",
  stlnc = " ",
  vert = "┃",
  verthoriz = "╋",
  vertleft = "┫",
  vertright = "┣",
}
-- opt.inccommand = "split"
-- opt.laststatus = 3
opt.list = true
opt.listchars = {
  tab = "┈┈",
  trail = "·",
  extends = "→",
  precedes = "←",
  nbsp = "•",
  eol = "↵",
}
-- opt.showmode = false
-- opt.ruler = false
-- opt.number = true
-- opt.numberwidth = 5
opt.relativenumber = false
-- opt.pumblend = 15
-- opt.pumheight = 25
-- opt.scrolljump = 5
-- opt.scrolloff = 5
-- opt.shortmess = "IFWs"
-- opt.showfulltag = true
-- opt.showmatch = true
-- opt.showtabline = 2
-- opt.signcolumn = "yes"
-- opt.statuscolumn = "%=%l %s%C"
-- opt.splitbelow = true
-- opt.splitkeep = "screen"
-- opt.splitright = true
-- opt.title = true
opt.wrap = true
-- opt.winblend = 15
-- opt.cpoptions = "aABceFsn_"
-- opt.diffopt="internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"
--
-- -- Search Stuff
-- opt.ignorecase = true
-- opt.magic = true
-- opt.smartcase = true
--
-- -- Insert mode completion
-- opt.completeopt = "fuzzy,menu,menuone,noselect"
--
-- -- Commandline completion
-- opt.wildcharm = vim.api.nvim_eval([[char2nr("\<C-z>")]])
-- opt.wildmenu = true
-- opt.wildmode = "longest:full,full"
-- opt.wildoptions = "pum"
--
-- -- Indentation
-- opt.autoindent = true
-- opt.breakindent = true
-- -- opt.breakindentopt = ""
-- -- opt.copyindent = true
-- opt.expandtab = true
-- opt.preserveindent = true
-- -- opt.linebreak = true
-- opt.shiftround = true
-- opt.shiftwidth = 4
-- -- opt.showbreak = "↪"
-- -- opt.showbreak = ""
-- opt.smartindent = true
-- opt.smarttab = true
-- opt.softtabstop = 4
-- opt.tabstop = 4
-- opt.textwidth = 0
--
-- -- Folding
-- opt.foldcolumn = "1"
-- opt.foldenable = true
-- -- opt.foldlevel = 99
-- opt.foldlevelstart = 99
-- opt.foldnestmax = 1
-- opt.foldmethod="expr"
-- opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- opt.foldtext = ""
--
-- -- Other Settings
-- vim.g.localmapleader = " "
-- vim.g.mapleader = " "
-- opt.autochdir = false
-- opt.backup = false
-- opt.hidden = true
-- opt.mouse = "a"
-- vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
-- vim.cmd("aunmenu PopUp.-1-")
-- opt.swapfile = true
-- opt.virtualedit = "onemore"
-- opt.wildignore = "*.swp,.*bak,.*pyc,*.class,.*jar,*.o"
--
-- opt.background = "dark"
