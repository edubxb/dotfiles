return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "hiphish/nvim-ts-rainbow2",
    },
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    opts = {
      highlight = {
        enable = true
      },
      rainbow = {
        enable = true,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  }
}
