return {
  "tpope/vim-repeat",
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    opts = {
      "*",
      "!alpha",
    },
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    config = function()
      require("rest-nvim").setup()
    end,
  },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          sizing_strategy = "auto",
          download_remote_images = true,
          clear_in_insert_mode = false,
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      kitty_method = "normal",
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    "michaelrommel/nvim-silicon",
    opts = {
      to_clipboard = true,
      font = "JetBrainsMono Nerd Font=15",
      theme = "Nord",
      background = "#FFF0",
      shadow_blur_radius = 10,
      shadow_offset_x = 4,
      shadow_offset_y = 8,
      shadow_color = "#000",
      pad_horiz = 20,
      pad_vert = 20,
      no_line_number = false,
      no_round_corner = false,
      no_window_controls = true,
      gobble = true,
      output = function()
        return vim.fn.expand("~/Pictures/Screenshots/neovim_") .. os.date("!%Y-%m-%dT%H-%M-%S") .. ".png"
      end,
      window_title = nil,
    },
  },
  {
    "mvaldes14/terraform.nvim",
    ft = "terraform",
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
      require("kitty-scrollback").setup()
    end,
  },
}
