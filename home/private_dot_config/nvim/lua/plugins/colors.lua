return {
  {
    "edeneast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          functions = "bold"
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd([[colorscheme nightfox]])
    end,
  },
}
