require("options")

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

local rocks_config = {
    rocks_path = vim.fn.stdpath("data") .. "/rocks",
    luarocks_binary = "luarocks",
}
vim.g.rocks_nvim = rocks_config

local luarocks_path = {
    vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
    vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
}
package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

local luarocks_cpath = {
    vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
    vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
}
package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib", "luarocks", "rocks-5.1", "rocks.nvim", "*"))

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

