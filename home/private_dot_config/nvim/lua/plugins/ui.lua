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
    "hoob3rt/lualine.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      local colors = {
        bg      = "#131A24",
        fg      = "#cdcecf",
        blue    = "#719cd6",
        cyan    = "#63cdcf",
        green   = "#81b29a",
        magenta = "#9d79d6",
        orange  = "#f4a261",
        pink    = "#d67ad2",
        red     = "#c94f6d",
        yellow  = "#dbc074",
      }

      local mode_color = {
        n = colors.fg,
        i = colors.green,
        v = colors.blue,
        [''] = colors.blue,
        V = colors.blue,
        c = colors.fg,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        [''] = colors.orange,
        ic = colors.yellow,
        R = colors.magenta,
        Rv = colors.magenta,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ['r?'] = colors.cyan,
        ['!'] = colors.red,
        t = colors.red,
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
      }

      local function diff_source()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed
          }
        end
      end

      local config = {
        extensions = {
          "neo-tree",
          "nvim-dap-ui",
          "quickfix",
        },
        options = {
          component_separators = " ",
          section_separators = " ",
          disabled_filetypes = window_filetypes,
          theme = {
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      ins_left {
        function ()
          local mode_map = {
            ["n"]     = "N",
            ["no"]    = "OP",
            ["nov"]   = "OP",
            ["noV"]   = "OP",
            ["no\22"] = "OP",
            ["niI"]   = "N",
            ["niR"]   = "N",
            ["niV"]   = "N",
            ["nt"]    = "N",
            ["v"]     = "V",
            ["vs"]    = "V",
            ["V"]     = "VL",
            ["Vs"]    = "VL",
            ["\22"]   = "VB",
            ["\22s"]  = "VB",
            ["s"]     = "S",
            ["S"]     = "SL",
            ["\19"]   = "SB",
            ["i"]     = "I",
            ["ic"]    = "I",
            ["ix"]    = "I",
            ["R"]     = "R",
            ["Rc"]    = "R",
            ["Rx"]    = "R",
            ["Rv"]    = "VR",
            ["Rvc"]   = "VR",
            ["Rvx"]   = "VR",
            ["c"]     = "CMD",
            ["cv"]    = "EX",
            ["ce"]    = "EX",
            ["r"]     = "R",
            ["rm"]    = "M",
            ["r?"]    = "",
            ["!"]     = "SH",
            ["t"]     = "T",
          }
          return mode_map[vim.api.nvim_get_mode().mode] or "__"
        end,
        color = function()
          return {
            fg = colors.bg,
            bg = mode_color[vim.fn.mode()],
            gui = "bold"
          }
        end,
      }

      ins_left {
        function ()
          return vim.b.gitsigns_head
        --   local tag = vim.api.nvim_cmd("Git describe --tags --exact-match", true)
        --   if vim.v.shell_error then
        --     return " " .. vim.b.gitsigns_head
        --   else
        --     return " " .. tag
        --   end
        end,
        icon = "",
        cond = function ()
          return vim.b.gitsigns_head ~= nil
        end,
        color = {
          fg = colors.fg,
        },
        padding = {
          left = 2
        },
      }

      ins_left {
        "diff",
        symbols = {added = "+", modified = "~", removed = "-"},
        diff_color = {
          added = { fg = colors.green, },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        source = diff_source,
        cond = conditions.hide_in_width,
        padding = {
          right = 0
        },
      }

      ins_left {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", hint = "󰌵 ", info = " " },
        diagnostics_color = {
          color_error = { fg = colors.red },
          color_warn = { fg = colors.yellow },
          color_info = { fg = colors.cyan },
        },
        padding = {
          left = 2
        },
      }

      ins_left {
        "searchcount",
        icon = "󰍉",
        padding = {
          left = 2
        }
      }

      ins_left {
        function()
          return "%="
        end
      }

      ins_right {
        "filename",
        cond = conditions.buffer_not_empty,
        path = 1,
        symbols = {
          modified = "",
          readonly = "",
          unnamed = "[No Name]",
        },
        padding = {
          left = 2,
          right = 2
        },
        color = function()
          local mode_fg = colors.fg
          if vim.bo.modified then
            mode_fg = colors.red
          elseif vim.bo.modifiable == false or vim.bo.readonly == true then
            mode_fg = colors.magenta
          end
          return {
            fg = mode_fg,
          }
        end,
      }

      ins_right {
        "filetype",
        icons_enabled = true,
        padding = {
          left = 0,
          right = 1
        },
        color = {
          fg = colors.fg,
          bg = colors.bg,
        }
      }

      ins_right {
        "location"
      }

      ins_right {
        "progress"
      }

      ins_right {
        "filesize",
        cond = conditions.buffer_not_empty,
      }

      ins_right {
        "o:encoding",
        fmt = string.upper,
        cond = conditions.hide_in_width,
        color = { fg = colors.fg },
      }

      ins_right {
        "fileformat",
        fmt = string.upper,
        icons_enabled = false,
        padding = {
          left = 0,
          right = 3
        },
        color = { fg = colors.fg },
      }

      ins_right {
        function()
          return "   "
        end,
        color = function()
          return {
            bg = mode_color[vim.fn.mode()],
          }
        end,
        padding = { left = 0 },
      }

      require("lualine").setup(config)
    end
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
