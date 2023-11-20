return {
  {
    "lukas-reineke/headlines.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
    opts = {
      markdown = {
        headline_highlights = { "HeadlineReverse" },
        fat_headlines = false,
      },
    },
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
    ft = "markdown",
    opts = {
      auto_load = true,
      theme = "light",
    },
    filetype = {
      "markdown",
    },
    config = function(_, opts)
      require("peek").setup(opts)
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end
  },
}
