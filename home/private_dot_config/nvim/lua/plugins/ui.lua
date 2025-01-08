return {
  "folke/twilight.nvim",
  "stevearc/dressing.nvim",
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 100,
    config = function ()
      vim.notify = require("notify")
    end,
  },
 	{
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require "statuscol.builtin"
      require("statuscol").setup {
        -- setopt = true,
        relculright = true,
        clickhandlers = {
          Lnum = builtin.gitsigns_click,
        },
        segments = {
          {
            sign = {
              name = { ".*" },
              namespace = { ".*" },
              maxwidth = 1,
              colwidth = 2,
              auto = false,
              wrap = true,
            },
          },
          {
            text = { builtin.lnumfunc, " " },
            colwidth = 1,
            click = "v:lua.ScLa",
          },
          {
            sign = {
              name = { "GitSigns*" },
              namespace = { "gitsigns" },
              colwidth = 1,
              fillchar = git_sign_icon,
              fillcharhl = "Nrline",
            },
            click = "v:lua.ScSa",
          },
          {
            text = { builtin.foldfunc, " " },
            hl = "FoldColumn",
            wrap = true,
            colwidth = 1,
            click = "v:lua.ScFa",
          },
        },
      }
    end,
  },
  {
    "b0o/incline.nvim",
    opts = {
      hide = {
        cursorline = false,
        focused_win = true,
        only_win = false
      },
      ignore = {
        buftypes = "special",
        filetypes = window_filetypes,
        floating_wins = true,
        unlisted_buffers = true,
        wintypes = "special"
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = true,
          showcmd = true,
        },
      },
    },
  },
  {
    "hiphish/rainbow-delimiters.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = {
      "hiphish/rainbow-delimiters.nvim",
    },
    main = "ibl",
    config = function (_, opts)
      local ibl = require("ibl")
      local hooks = require("ibl.hooks")

      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { link = "TSRainbowRed" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { link = "TSRainbowYellow" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { link = "TSRainbowBlue" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { link = "TSRainbowOrange" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { link = "TSRainbowGreen" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { link = "TSRainbowViolet" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { link = "TSRainbowCyan" })
      end)

      vim.g.rainbow_delimiters = { highlight = highlight }
      ibl.setup({
        exclude = {
          filetypes = window_filetypes,
          buftypes = buffer_types,
        },
        indent = {
          char = "┊",
          tab_char = "┊",
        },
        scope = {
          highlight = highlight,
          show_start = false,
          show_end = false,
        },
      })

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end
  },
  "nvim-tree/nvim-web-devicons",
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        mode = "tabs",
        always_show_bufferline = false,
        separator_style = "slant",
        offsets = {
          {
            filetype = "DiffviewFiles",
            text = "",
            highlight = "",
            padding = 0,
          },
        }
      }
    }
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        component_separators = { left = " ", right = " "},
        section_separators = { left = " ", right = " "},
      },
      sections = {
        lualine_a = {
          {
            "mode",
             fmt = function(str) return str:sub(1,1) end,
          },
        },
        lualine_b = {
          {
            "b:gitsigns_head",
            icon = "",
            color = "lualine_c_normal",
          },
          {
            "diff",
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed
                }
              end
            end,
            color = "lualine_c_normal",
          },
          {
            "diagnostics",
            color = "lualine_c_normal",
          },
        },
        lualine_c = {},
        lualine_x = {
          {
            "filename",
            path = 3,
            color = function()
              local hl = "lualine_c_normal"
              if vim.bo.modified then
                hl = "lualine_x_filename_insert"
              elseif vim.bo.modifiable == false or vim.bo.readonly == true then
                hl = "lualine_x_filename_replace"
              end
              return {
                fg = vim.api.nvim_get_hl_by_name(hl, true).fg
              }
            end
          },
          "filetype",
          "location",
          "progress",
        },
        lualine_y = {
          {
            "encoding",
            color = "lualine_c_normal",
            fmt = string.upper,
          },
          {
            "fileformat",
            color = "lualine_c_normal",
            icons_enabled = false,
            fmt = string.upper,
          },
        },
        lualine_z = {
          {
            function()
            return " "
            end,
            draw_empty = true,
          },
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "muniftanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = nil,
          },
          opts = { skip = true },
        },
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      views = {
        cmdline_popup = {
          border = {
            style = "none",
            padding = { 2, 3 },
          },
          filter_options = {},
          win_options = {
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
          },
        },
      },
    },
    config = function(_, opts)
      local noice = require("noice").setup(opts)

      vim.keymap.set("n", "<c-f>", function()
        if not noice.lsp.scroll(4) then
          return "<c-f>"
        end
      end, { silent = true, expr = true })

    vim.keymap.set("n", "<c-b>", function()
      if not noice.lsp.scroll(-4) then
        return "<c-b>"
      end
    end, { silent = true, expr = true })
end
  },
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      require("alpha.term")

      local function button(sc, txt, keybind)
        local leader = "SPC"
        local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

        local opts = {
          position = "center",
          shortcut = sc,
          cursor = 5,
          width = 50,
          align_shortcut = "right",
          hl_shortcut = "Bold",
        }
        if keybind then
          keybind_opts = { noremap = true, silent = true, nowait = true }
          opts.keymap = { "n", sc_, keybind, keybind_opts }
        end

        local function on_press()
          local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
          vim.api.nvim_feedkeys(key, "t", false)
        end

        return {
          type = "button",
          val = txt,
          on_press = on_press,
          opts = opts,
        }
      end

      dashboard.section.header.val = {
        [[                                                                       ]],
        [[                                                                     ]],
        [[       ████ ██████           █████      ██                     ]],
        [[      ███████████             █████                             ]],
        [[      █████████ ███████████████████ ███   ███████████   ]],
        [[     █████████  ███    █████████████ █████ ██████████████   ]],
        [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
        [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
        [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
        [[                                                                       ]],
      }

      dashboard.section.buttons.val = {
        button("e", "󰃉  · New file" , "<cmd>ene<BAR> startinsert<CR>"),
        { type = "padding", val = 1 },
        button("f", "󰍉  · Find file", "<cmd>Telescope find_files<CR>"),
        button("r", "󰋚  · Recent files", "<cmd>Telescope oldfiles cwd_only=true<CR>"),
        button("p", "󰙴  · Projects", ":lua require('yazi').yazi(nil, projects_root)<CR>"),
        button("s", "󰉓  · Sessions", "<cmd>Telescope persisted<CR>"),
        { type = "padding", val = 1 },
        button("u", "󱑠  · Update plugins", ":Lazy sync<CR>"),
        button("t", "󱁤  · Manage external tools", ":Mason<CR>"),
        { type = "padding", val = 1 },
        button("q", "󰍃  · Quit", ":qa<CR>"),
      }

      local handle = io.popen("/usr/games/fortune bofh-excuses")
      local fortune = handle:read("*a")
      handle:close()
      dashboard.section.footer.val = fortune

      dashboard.section.header.opts.hl = "Character"
      dashboard.section.footer.opts.hl = "Character"

      dashboard.config.layout = {
        { type = "padding", val = 8 },
        dashboard.section.header,
        { type = "padding", val = 3 },
        dashboard.section.buttons,
        { type = "padding", val = 3 },
        dashboard.section.footer,
      }

      alpha.setup(dashboard.config)
    end,
  },
}
