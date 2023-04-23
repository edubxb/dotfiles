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
    "krivahtoo/silicon.nvim",
    build = "./install.sh build",
    opts = {
      output = {
        path = vim.fn.expand("~/Pictures/Screenshots/"),
        format = "neovim_[year][month][day]_[hour][minute][second].png",
      },
      font = "JetBrainsMono=11",
      theme = "Nord",
      background = "#FFF0",
      shadow = {
        blur_radius = 10,
        offset_x = 2,
        offset_y = 6,
        color = "#000"
      },
      pad_horiz = 40,
      pad_vert = 40,
      line_number = true,
      round_corner = true,
      window_controls = false,
    }
  }
}
