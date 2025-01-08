return {
  {
    "edeneast/nightfox.nvim",
    lazy = false,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          functions = "bold"
        },
      },
      groups = {
        all = {
          TelescopeBorder = { fg = "bg0", bg = "bg0" },
          TelescopeNormal = { bg = "bg0" },
          TelescopeTitle ={ fg = "bg0", bg = "fg0" },
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd("colorscheme carbonfox")
    end,
  },
}
