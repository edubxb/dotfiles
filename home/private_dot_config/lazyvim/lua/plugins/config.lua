return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "carbonfox",
		},
	},
	{
		"mikesmithgh/kitty-scrollback.nvim",
		enabled = true,
		lazy = true,
		cmd = {
			"KittyScrollbackGenerateKittens",
			"KittyScrollbackCheckHealth",
			"KittyScrollbackGenerateCommandLineEditing",
		},
		event = { "User KittyScrollbackLaunch" },
		config = function()
			require("kitty-scrollback").setup()
		end,
	},
	{
		"b0o/incline.nvim",
		main = "incline",
		event = "VeryLazy",
		opts = function()
			Snacks.toggle({
				name = "Incline",
				get = function()
					return not require("incline").is_paused()
				end,
				set = function(enabled)
					local m = require("incline")
					if enabled then
						m.resume()
					else
						m.pause()
					end
				end,
			}):map("<leader>uN")

			local separator = { left = "│", right = "│" } -- vim.g.separators.component
			return {
				---@param props { buf: number, win: number, focused: boolean }
				---@return render_result[]
				render = function(props)
					local theme = require("lualine.themes." .. vim.g.colors_name)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
					local group = props.focused and "Normal" or "Inactive"
					local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf })
					for hl_group, value in pairs({
						InclineBorderNormal = { fg = theme.normal.b.bg, bg = "NONE" },
						InclineBorderInactive = { fg = theme.inactive.b.bg, bg = "NONE" },
						InclineTextNormal = { fg = theme.normal.b.fg, bg = theme.normal.b.bg },
						InclineTextInactive = { bg = theme.inactive.b.bg, fg = theme.normal.b.fg },
					}) do
						vim.api.nvim_set_hl(0, hl_group, value)
					end
					local function get_git_diff()
						local signs, diff = vim.b[props.buf].gitsigns_status_dict or {}, {}
						local icons = {
							added = LazyVim.config.icons.git.added,
							changed = LazyVim.config.icons.git.modified,
							removed = LazyVim.config.icons.git.removed,
						}
						for key, icon in pairs(icons) do
							if signs[key] and signs[key] ~= 0 then
								table.insert(diff, { icon .. signs[key] .. " ", group = "Diff" .. key })
							end
						end
						if #diff > 0 then
							table.insert(diff, 1, " ")
						end
						return diff
					end
					local function expand(render_result)
						local index = 1
						while index < #render_result do
							local value = render_result[index]
							if #value > 0 then
								table.insert(render_result, index + 1, separator.right)
								index = index + 1
							end
							index = index + 1
						end
						return render_result
					end
					return #filename > 0
							and {
								expand({
									get_git_diff(),
									{
										ft_icon and { " ", ft_icon, guifg = ft_color } or "",
										" ",
										{
											filename,
											gui = modified and "bold" or nil,
										},
										" ",
										modified and "● " or "",
									},
									group = "InclineText" .. group,
								}),
							}
						or {}
				end,
				highlight = {
					groups = {
						InclineNormal = { default = false, guifg = "NONE", guibg = "NONE" },
						InclineNormalNC = { default = false, guifg = "NONE", guibg = "NONE" },
					},
				},
				window = {
					padding = 0,
					margin = { vertical = 0, horizontal = 0 },
					placement = { vertical = "top", horizontal = "right" },
				},
			}
		end,
	},
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
				},
			},
		},
	},
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				enabled = false,
			},
			indent = {
				indent = {
					char = "┊",
					only_scope = true,
					only_current = true,
				},
				scope = {
					char = "┊",
					only_current = true,
				},
				chunk = {
					char = "┊",
					only_current = true,
				},
			},
		},
	},
	{
		"folke/noice.nvim",
		opts = {
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
			presets = {
				command_palette = false,
			},
		},
	},
	{ "iamcco/markdown-preview.nvim", enabled = false },
	{
		"selimacerbas/mdkite.nvim",
		version = "^2",
		dependencies = { { "selimacerbas/kitehost.nvim", version = "^2" } },
		cmd = "MdKite",
		keys = {
			{ "<leader>mp", "<cmd>MdKite toggle<cr>", ft = "markdown", desc = "Markdown Preview" },
		},
		opts = function()
			local socket = assert(vim.env.KITTY_LISTEN_ON, "Start Neovim inside Kitty with remote control enabled")
			local window = assert(vim.env.KITTY_WINDOW_ID, "Start Neovim inside Kitty")
			local dock, preview_buf
			local function kitty(args)
				local cmd = { "kitten", "@", "--to", socket }
				return vim.system(vim.list_extend(cmd, args), { text = true }):wait(5000)
			end
			local function close_dock()
				if not dock then
					return true
				end
				local result = kitty({ "close-window", "--match", "id:" .. dock, "--ignore-no-match" })
				if result.code ~= 0 then
					vim.notify("mdkite: could not close Kitty dock: " .. (result.stderr or ""), vim.log.levels.ERROR)
					return false
				end
				dock = nil
				return true
			end
			local group = vim.api.nvim_create_augroup("MdKiteDock", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
				group = group,
				callback = function(event)
					if preview_buf and event.buf ~= preview_buf and vim.bo[event.buf].filetype == "markdown" then
						require("mdkite").start()
					end
				end,
			})
			vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
				group = group,
				callback = function(event)
					if event.buf == preview_buf then
						require("mdkite").stop()
					end
				end,
			})
			vim.api.nvim_create_autocmd("VimLeavePre", {
				group = group,
				callback = function()
					if preview_buf or dock then
						require("mdkite").stop()
					end
				end,
			})
			return {
				-- Each editor owns its server and dock; takeover would share their lifetime.
				instance_mode = "multi",
				open_browser = false,
				default_theme = "light",
				mermaid_renderer = "rust",
				scroll_sync = true,
				hooks = {
					on_start = function(url)
						preview_buf = vim.api.nvim_get_current_buf()
						if dock then
							return
						end
						local result = kitty({
							"launch", "--match", "window_id:" .. window, "--next-to", "id:" .. window,
							"--type", "window-dock", "--dock-edge", "right", "--dock-size", "100",
							"--dock-skip-focus", "--keep-focus", "--title", "mdkite preview",
							"mise", "exec", "--", "blinkterm", "--temp-profile", "--engine", "/usr/bin/chromium",
							"--engine-arg", "--hide-scrollbars", url,
						})
						dock = result.code == 0 and tonumber(result.stdout) or nil
						if not dock then
							vim.notify("mdkite: could not launch Kitty dock: " .. (result.stderr or ""), vim.log.levels.ERROR)
							require("mdkite").stop()
						end
					end,
					on_stop = function()
						preview_buf = nil
						close_dock()
					end,
				},
			}
		end,
	},
	{
		"edeneast/nightfox.nvim",
		opts = {
			options = {
				styles = {
					comments = "italic",
					keywords = "bold",
					functions = "bold",
				},
				transparent = false,
			},
			palettes = {
				carbonfox = {
					sel0 = "#404040",
				},
			},
		},
	},
	{
		"goolord/alpha-nvim",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")
			require("alpha.term")

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
				[[                                                   Powered by LazyVim™ ]],
				[[                                                                       ]],
			}

			dashboard.section.buttons.val = {
				dashboard.button("n", "󰃉  ·" .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
				{ type = "padding", val = 1 },
				dashboard.button("f", "  · " .. "Find file", "<cmd> lua LazyVim.pick()() <cr>"),
				dashboard.button("r", "  · " .. "Recent files", [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
				dashboard.button("g", "  · " .. "Find text", [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),
				dashboard.button("s", "󰉓  · " .. "Sessions", [[<cmd> lua require("persistence").load() <cr>]]),
				{ type = "padding", val = 1 },
				dashboard.button("c", "  · " .. "Config", "<cmd> lua LazyVim.pick.config_files()() <cr>"),
				dashboard.button("l", "󰒲  · " .. "Lazy", "<cmd> Lazy <cr>"),
				dashboard.button("x", "  · " .. "Lazy extras", "<cmd> LazyExtras <cr>"),
				dashboard.button("m", "󱁤  · " .. "Mason (external tools)", "<cmd> Mason <cr>"),
				{ type = "padding", val = 1 },
				dashboard.button("q", "  · " .. "Quit", "<cmd> qa <cr>"),
			}

			local handle = io.popen("/usr/games/fortune bofh-excuses")
			local fortune = handle:read("*a")
			handle:close()
			dashboard.section.footer.val = fortune

			dashboard.section.header.opts.hl = "Character"
			dashboard.section.footer.opts.hl = "Character"

			dashboard.config.layout = {
				{ type = "padding", val = 6 },
				dashboard.section.header,
				{ type = "padding", val = 3 },
				dashboard.section.buttons,
				{ type = "padding", val = 3 },
				dashboard.section.footer,
			}

			alpha.setup(dashboard.config)
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▁" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▁" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
			},
		},
	},
	{
		"mini-vim/mini.diff",
		enabled = false,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
		opts = {
			graph_style = "kitty",
			-- kind = "floating",
			commit_editor = {
				-- kind = "floating",
				-- staged_diff_split_kind = "vsplit",
				show_staged_diff = false,
			},
			commit_select_view = {
				-- kind = "floating",
			},
			commit_view = {
				-- kind = "vsplit",
			},
			log_view = {
				-- kind = "floating",
			},
			rebase_editor = {
				-- kind = "floating",
			},
			reflog_view = {
				-- kind = "floating",
			},
			merge_editor = {
				-- kind = "floating",
			},
			preview_buffer = {
				-- kind = "floating_console",
			},
			popup = {
				-- kind = "floating",
			},
			stash = {
				-- kind = "floating",
			},
			refs_view = {
				-- kind = "floating",
			},
			signs = {
				-- hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},
		},
		keys = {
			{ "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit", remap = true },
		},
	},
	{
		"hotwatermorning/auto-git-diff",
		ft = "gitrebase",
		config = function()
			vim.g.auto_git_diff_show_window_at_right = 1
		end,
	},
	{
		"rhysd/committia.vim",
		ft = "gitcommit",
		config = function()
			vim.g.committia_open_only_vim_starting = 0
		end,
	},
	{
		"sindrets/diffview.nvim",
		dependencies = {
			-- "nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",
		},
		cmd = {
			"DiffviewOpen",
		},
		keys = {
			{ "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "Show current file git history", remap = true },
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
		"folke/sidekick.nvim",
		opts = {
			cli = {
				win = {
					split = {
						width = 100,
					},
				},
			},
		},
	},
	{
		"esmuellert/codediff.nvim",
	},
	{
		"CoreyKaylor/diffbandit.nvim",
		build = function(plugin)
			local bin = vim.fn.expand("~/.local/bin")
			local source = plugin.dir .. "/bin/diffbandit"
			vim.fn.mkdir(bin, "p")

			for _, name in ipairs({ "diffbandit", "git-diffbandit" }) do
				local target = bin .. "/" .. name
				if vim.uv.fs_readlink(target) ~= source then
					assert(vim.uv.fs_symlink(source, target))
				end
			end
		end,
		config = function()
			require("diffbandit").setup()
		end,
	},
  {
    "Owen-Dechow/videre.nvim",
    dependencies = {
      "Owen-Dechow/graph_view_yaml_parser",
      "Owen-Dechow/graph_view_toml_parser",
      "a-usr/xml2lua.nvim",
    },
  },
	{
		"fionn/nvim-hujson",
	}
}
