require("options")

-- for finding luarocks packages --
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
--

projects_path = vim.split(os.getenv("PROJECTS_PATH"), ":")
pkb_home = os.getenv("PKB_HOME")

my_colorscheme = "nightfox"

window_filetypes = {
  "alpha",
  "neo-tree",
  "Outline",
  "Trouble",
  "UltestSummary",
  "dashboard",
  "fidget",
  "fugitive",
  "help",
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

