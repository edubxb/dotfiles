-- copy & paste
vim.api.nvim_set_keymap("v", "<C-Ins>", "\"+yi", keymap_opts)
vim.api.nvim_set_keymap("v", "<S-Del>", "\"+c", keymap_opts)
vim.api.nvim_set_keymap("v", "<S-Ins>", "c<ESC>\"+gp", keymap_opts)
vim.api.nvim_set_keymap("i", "<S-Ins>", "<ESC>\"+gp", keymap_opts)

-- easy movement on wrapped lines
vim.api.nvim_set_keymap("n", "j", "gj", keymap_opts)
vim.api.nvim_set_keymap("n", "k", "gk", keymap_opts)

-- disable some annoying defaults
vim.api.nvim_set_keymap("", "Q", "<nop>", keymap_opts)
vim.api.nvim_set_keymap("", "ZZ", "<nop>", keymap_opts)

-- terminal buffer
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", keymap_opts)

-- bye
vim.api.nvim_set_keymap("", "<C-S-q>", ":qa!", keymap_opts)
