return {
  {
    "dinhhuy258/git.nvim",
    config = function()
      require("git").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      _threaded_diff = true,
      trouble = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, {expr=true})

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, {expr=true})

        map({"n", "v"}, "<leader>hs", ":Gitsigns stage_hunk<CR>")
        map({"n", "v"}, "<leader>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function() gs.blame_line{full = true, ignore_whitespace = true} end)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function() gs.diffthis("~") end)
        map("n", "<leader>td", gs.toggle_deleted)

        map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end
    },
  },
  {
    "hotwatermorning/auto-git-diff",
    ft = "gitrebase",
    config = function()
      vim.g.auto_git_diff_show_window_at_right = 1
    end
  },
  {
    "rhysd/committia.vim",
    ft = "gitcommit",
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
    cmd = {
      "DiffviewOpen"
    },
    keys = {
      { "<leader>fh", "<cmd>DiffviewFileHistory %<CR>", desc = "Show current file git history", remap = true },
    },
    opts = {
      diff_binaries = true,
      show_help_hints = false,
      file_panel = {
        win_config = {
          position = "right",
        },
      },
    },
  },
  {
    "FabijanZulj/blame.nvim",
    opts = {
      date_format = "%Y-%m-%d",
      views = {
        default = virtual_view,
      },
    }
  }
}
