return {
  {
    "MeanderingProgrammer/markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
    ft = { 
      "markdown",
      "telekasten",
     },
    opts = {
      file_types = { 
        "markdown",
        "telekasten",
      },
      headings = { "Ⅰ. ", "Ⅱ. ", "Ⅲ. ", "Ⅳ. ", "Ⅴ. ", "Ⅵ. " },
      bullets = { "•", "◦", "▪", "▫" },
      highlights = {
        heading = {
          backgrounds = { 
            "DiffChange",
          },
          foregrounds = {
            "DiffChange",
          },
        },
        table = {
          head = "Normal",
        },
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
    end,
  },
  {
    "mzlogin/vim-markdown-toc",
    ft = "markdown",
  },
  {
    "plasticboy/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_follow_anchor = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_new_list_item_indent = 2
      vim.g.vim_markdown_strikethrough = 1
    end,
  },
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    event = { "VeryLazy" },
    ft = {
      "markdown",
      "telekasten",
    },
    opts = {
      auto_load = true,
      theme = "light",
    },
    config = function(_, opts)
      require("peek").setup(opts)
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
  {
    "renerocksai/telekasten.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      home = pkb_home,
      auto_set_filetype = true,
      close_after_yanking = false,
      command_palette_theme = "dropdown",
      insert_after_inserting = true,
      new_note_location = "smart",
      show_tags_theme = "dropdown",
      subdirs_in_links = true,
      tag_notation = "#tag",
      take_over_my_home = true,
    },
    keys = {
      { "<leader>z",  "<cmd>Telekasten panel<CR>" },
      { "<leader>zb", "<cmd>Telekasten show_backlinks<CR>" },
      { "<leader>zc", "<cmd>Telekasten show_calendar<CR>" },
      { "<leader>zd", "<cmd>Telekasten goto_today<CR>" },
      { "<leader>zf", "<cmd>Telekasten find_notes<CR>" },
      { "<leader>zg", "<cmd>Telekasten search_notes<CR>" },
      { "<leader>zi", "<cmd>Telekasten insert_img_link<CR>" },
      { "<leader>zn", "<cmd>Telekasten new_note<CR>" },
      { "<leader>zz", "<cmd>Telekasten follow_link<CR>" },
    },
  },
}
