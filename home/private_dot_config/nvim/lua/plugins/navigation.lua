return {
  {
    "olimorris/persisted.nvim",
    opts = {
      autoload = true,
      autosave = true,
      allowed_dirs = projects_path,
      use_git_branch = true,
      on_autoload_no_session = function()
        vim.notify("No existing session to load.")
      end
    },
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
      window = {
        position = "right",
      },
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
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "folke/trouble.nvim",
      "mfussenegger/nvim-dap",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "olimorris/persisted.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      local telescope = require("telescope")
      local telescope_actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")

      telescope.load_extension("dap")
      telescope.load_extension("fzf")
      telescope.load_extension("notify")
      telescope.load_extension("persisted")

      telescope.setup {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          layout_strategy = "flex",
          extensions = {
            fzf = {
              case_mode = "smart_case",
              fuzzy = true,
              override_file_sorter = true,
              override_generic_sorter = true,
            }
          },
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

      local colors = {
        black  = "#131A24",
        gray   = "#d6d6d7",
      }

      local TelescopePrompt = {
        TelescopeBorder = {
          fg = colors.black,
          bg = colors.black,
        },
        TelescopePromptBorder = {
          fg = colors.black,
          bg = colors.black,
        },
        TelescopePromptNormal = {
          bg = colors.black,
        },
        TelescopePromptTitle = {
          fg = colors.black,
          bg = colors.gray,
        },
        TelescopeNormal = {
          bg = colors.black
        },
        TelescopePreviewTitle = {
          fg = colors.black,
          bg = colors.gray,
        },
        TelescopeResultsTitle = {
          fg = colors.black,
          bg = colors.gray,
        },
      }
      for hl, col in pairs(TelescopePrompt) do
        vim.api.nvim_set_hl(0, hl, col)
      end

      vim.api.nvim_set_keymap("n", "<Leader>bb", "<cmd>Telescope buffers<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>ll", "<cmd>Telescope current_buffer_fuzzy_find<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>cc", "<cmd>Telescope commands<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>ff", "<cmd>Telescope find_files<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>gg", "<cmd>Telescope live_grep<CR>", keymap_opts)
    end
  }
}
