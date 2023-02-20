return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "joosepalviste/nvim-ts-context-commentstring",
      "mrjones2014/nvim-ts-rainbow",
    },
    opts = {
      context_commentstring = {
        enable = true
      },
      rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
  }
}
