return {
  "direnv/direnv.vim",
  "editorconfig/editorconfig-vim",
  "tpope/vim-repeat",
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    opts = {
      "*",
      "!alpha",
    },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  },
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    }
  },
  {
    "rest-nvim/rest.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "narutoxy/silicon.lua",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    cond = function() return vim.fn.executable("silicon") == 1 end,
    opts = {
      theme = "auto",
      output = vim.fn.expand("~/Pictures/Screenshots/neovim_${year}${month}${date}_${time}.png"),
      bgColor = "#FFF0",
      windowControls = false,
      font = "JetBrains Mono Medium",
      lineOffset = 1,
      linePad = 2,
      padHoriz = 40,
      padVert = 40,
      shadowBlurRadius = 10,
      shadowColor = "#000000",
      shadowOffsetX = 2,
      shadowOffsetY = 6,
    },
    config = function(_, opts)
      silicon = require("silicon")
      silicon.setup(opts)

      vim.keymap.set("v", "<Leader>ss", function() silicon.visualise_api({to_clip = true}) end)
      vim.keymap.set("v", '<Leader>sb', function() silicon.visualise_api({to_clip = true, show_buf = true}) end)
    end
  }
}
