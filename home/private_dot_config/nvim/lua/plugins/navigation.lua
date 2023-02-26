return {
  {
    "olimorris/persisted.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      autoload = true,
      autosave = true,
      allowed_dirs = projects_path,
      use_git_branch = true,
      on_autoload_no_session = function()
        vim.notify("No existing session to load.")
      end
    },
    config = function(_, opts)
      local persisted = require("persisted")
      persisted.setup(opts)
      require("telescope").load_extension("persisted")
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "muniftanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>tt", "<cmd>Neotree float<CR>", desc = "NeoTree", remap = true },
    },
    opts = {
      source_selector = {
        winbar = true,
      }
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "folke/trouble.nvim",
      "mfussenegger/nvim-dap",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      local telescope = require("telescope")
      local telescope_actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")

      telescope.setup {
        defaults = {
          layout_strategy = "flex",
          mappings = {
            i = {
              ["<esc>"] = telescope_actions.close,
              ["<c-t>"] = trouble.open_with_trouble,
            },
            n = {
              ["<c-t>"] = trouble.open_with_trouble
            },
          },
        },
      }

      telescope.load_extension("dap")
      telescope.load_extension("notify")

      vim.api.nvim_set_keymap("n", "<Leader>bb", "<cmd>Telescope buffers<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>ll", "<cmd>Telescope current_buffer_fuzzy_find<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>cc", "<cmd>Telescope commands<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>ff", "<cmd>Telescope find_files<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>gg", "<cmd>Telescope live_grep<CR>", keymap_opts)
    end
  }
}
