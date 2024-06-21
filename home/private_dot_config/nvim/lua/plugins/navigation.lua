return {
  {
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>-",
        function()
          require("yazi").yazi()
        end,
        desc = "Open the file manager",
      },
      {
        "<leader>cw",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Open the file manager in nvim's working directory",
      },
    },
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.85,
      yazi_floating_window_winblend = 15,
    },
    config = function(_, opts)
      require("yazi").setup(opts)
      vim.api.nvim_create_autocmd(
        "Filetype",
        {
          pattern = "yazi",
          command = "tunmap <Esc>",
        }
      )
    end
  },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup()
    end
  },
  {
    "olimorris/persisted.nvim",
    opts = {
      autoload = true,
      autosave = true,
      allowed_dirs = { projects_root },
      use_git_branch = true,
      on_autoload_no_session = function()
        vim.notify("No existing session to load.")
      end
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    keys = {
      {
        "<leader>d",
        "<cmd>Trouble diagnostics toggle<CR>"
      },
    }
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
      "nvim-telescope/telescope-github.nvim",
      "nvim-telescope/telescope-media-files.nvim",
      "olimorris/persisted.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      local telescope = require("telescope")
      local telescope_actions = require("telescope.actions")
      local trouble = require("trouble.sources.telescope")

      telescope.load_extension("dap")
      telescope.load_extension("fzf")
      telescope.load_extension("media_files")
      telescope.load_extension("notify")
      telescope.load_extension("persisted")

      telescope.setup {
        defaults = {
          borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
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

      vim.api.nvim_set_keymap("n", "<Leader>bb", "<cmd>Telescope buffers<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>cc", "<cmd>Telescope commands<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>ff", "<cmd>Telescope find_files<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>gg", "<cmd>Telescope live_grep<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>ll", "<cmd>Telescope current_buffer_fuzzy_find<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>mm", "<cmd>Telescope mefia_files<CR>", keymap_opts)
    end
  }
}
