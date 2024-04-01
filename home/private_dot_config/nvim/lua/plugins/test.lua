return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local neotest = require("neotest").setup({})

      -- neotest.setup({
      --   adapters = {
      --     require("neotest-go"),
      --     require("neotest-python"),
      --   },
      -- })

      -- local test_ag = vim.api.nvim_create_augroup("test", {})
      -- vim.api.nvim_create_autocmd(
      --   "BufWritePost",
      --   {
      --     command = function() require("neotest").run.run() end,
      --     group = test_ag
      --   }
      -- )
    end,
  }
}
