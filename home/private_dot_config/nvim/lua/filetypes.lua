local filetypes_ag = vim.api.nvim_create_augroup("filetypes", {})
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = {
      "ansible",
      "bash",
      "css",
      "less",
      "lua",
      "scss",
      "sh",
      "terraform",
      "yaml",
    },
    command = "setlocal ts=2 sts=2 sw=2",
    group = filetypes_ag
  }
)
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "go",
    command = "setlocal ts=4 sts=4 sw=4 noexpandtab",
    group = filetypes_ag
  }
)
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "python",
    command = "setlocal ts=4 sts=4 sw=4 tw=88",
    group = filetypes_ag
  }
)
vim.api.nvim_create_autocmd(
  {
    "BufFilePre",
    "BufNewFile",
    "BufRead"
  },
  {
    pattern = "*.md",
    command = "setlocal ft=markdown.pandoc textwidth=100",
    group = filetypes_ag
  }
)

local git_ag = vim.api.nvim_create_augroup("git", {})
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = {
      "gitcommit",
      "gitrebase",
    },
    command = "set nonumber noswapfile",
    group = git_ag
  }
)

local shell_ag = vim.api.nvim_create_augroup("shell", {})
vim.api.nvim_create_autocmd(
  {
    "BufFilePre",
    "BufNewFile",
    "BufRead",
  },
  {
    pattern = vim.fn.getenv("HOME") .. "/.config/shell/*.sh",
    command = "set filetype=sh",
    group = shell_ag
  }
)
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "bash",
    command = "let $SHELLCHECK_OPTS='--shell=bash'",
    group = shell_ag
  }
)
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "zsh",
    command = "let $SHELLCHECK_OPTS='--shell=zsh'",
    group = shell_ag
  }
)

local git_config_ag = vim.api.nvim_create_augroup("git_config", {})
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "gitconfig",
    command = "setlocal ts=4 sts=4 sw=4 noexpandtab",
    group = filetypes_ag
  }
)

local ssh_ag = vim.api.nvim_create_augroup("ssh", {})
vim.api.nvim_create_autocmd(
  {
    "BufFilePre",
    "BufNewFile",
    "BufRead",
  },
  {
    pattern = vim.fn.getenv("HOME") .. "/.ssh/config.d/*",
    command = "set filetype=sshconfig",
    group = ssh_ag
  }
)

local diff_ag = vim.api.nvim_create_augroup("diff", {})
vim.api.nvim_create_autocmd(
  "BufWritePost",
  {
    command = "if &diff | diffupdate | endif",
    group = diff_ag
  }
)
vim.api.nvim_create_autocmd(
  "FilterWritePre",
  {
    command = "if &diff | set noswapfile nolist colorcolumn=0 | endif",
    group = diff_ag
  }
)

local windows_ag = vim.api.nvim_create_augroup("windows", {})
vim.api.nvim_create_autocmd(
  "WinEnter",
  {
    command = "if &previewwindow | setlocal colorcolumn=0 nolist nonumber signcolumn=no | endif",
    group = windows_ag
  }
)
vim.api.nvim_create_autocmd(
  "FileType",
  {
    pattern = "qf",
    command = "setlocal colorcolumn=0 nolist nonumber signcolumn=no",
    group = windows_ag
  }
)
vim.api.nvim_create_autocmd(
  "TermOpen",
  {
    command = "setlocal colorcolumn=0 nolist nonumber signcolumn=no | let g:terminal_scrollback_buffer_size=100000",
    group = windows_ag
  }
)
