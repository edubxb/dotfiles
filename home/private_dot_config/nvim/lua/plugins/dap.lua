return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "nvim-telescope/telescope-dap.nvim",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text"
    },
    config = function()
      local dap_virtual_text = require("nvim-dap-virtual-text")
      local dapui = require("dapui")
      local dap_go = require("dap-go")

      dap_virtual_text.setup{}
      dapui.setup{}
      dap_go.setup{}
    end
  },
}
