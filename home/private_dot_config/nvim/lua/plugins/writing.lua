return {
 {
    "vim-pandoc/vim-pandoc-syntax",
    ft = "markdown",
    config = function()
      vim.g["pandoc#syntax#conceal#urls"] = 1
    end
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
    end
  },
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    ft = "markdown",
    opts = {
      auto_load = false,
      theme = "light",
    },
    filetype = {
      "markdown",
      "markdown.pandoc",
    },
    config = function(_, opts)
      require("peek").setup(opts)
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end
  },
}
