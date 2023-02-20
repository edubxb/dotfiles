return {
  "rhysd/committia.vim",
  "tpope/vim-fugitive",
  "tpope/vim-git",
  {
    "rhysd/git-messenger.vim",
    config = function()
      vim.g.git_messenger_extra_blame_args = "-w -M"
      vim.g.git_messenger_floating_win_opts = {
        border = "single"
      }
      vim.g.git_messenger_popup_content_margins = false
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("gitsigns").setup()

      vim.api.nvim_set_keymap("n", "<Leader>ga", "<cmd>Gitsigns get_actions<CR>", keymap_opts)
    end,
  },
  {
    "hotwatermorning/auto-git-diff",
    ft = "gitrebase",
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end,
  },
}
