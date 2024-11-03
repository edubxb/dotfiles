require("options")

pkb_home = os.getenv("PKB_HOME")
projects_root = os.getenv("PROJECTS_ROOT")

my_colorscheme = "nightfox"

buffer_types = {
  "nofile",
  "prompt",
  "quickfix",
  "terminal",
}

window_filetypes = {
  "",
  "TelescopePrompt",
  "TelescopeResults",
  "Trouble",
  "UltestSummary",
  "alpha",
  "checkhealth",
  "dashboard",
  "fidget",
  "fugitive",
  "gitcommit",
  "help",
  "lspinfo",
  "man",
  "mason",
  "notify",
  "octo",
  "packer",
}

window_filenames = {
  "__committia_diff__",
  "__committia_status__",
}

keymap_opts = {
  noremap = true,
  silent = false,
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = {
    lazy = false,
    -- version = "*"
  },
  install = {
    colorscheme = {
      my_colorscheme,
    },
  },
})

require("filetypes")
require("keymaps")
require("gui")
