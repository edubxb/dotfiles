return {
  {
    "eandrju/cellular-automaton.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    }
  },
  {
    "giusgad/pets.nvim",
    dependencies = {
      "giusgad/hologram.nvim",
      "muniftanjim/nui.nvim",
    },
    config = function ()
      require("pets").setup({
          row = 4,
        })
    end
  },
}
