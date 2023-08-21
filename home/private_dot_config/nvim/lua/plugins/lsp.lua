return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "b0o/schemastore.nvim",
      "folke/trouble.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "jay-babu/mason-null-ls.nvim",
      "jose-elias-alvarez/null-ls.nvim",
      "kosayoda/nvim-lightbulb",
      "lvimuser/lsp-inlayhints.nvim",
      "rrethy/vim-illuminate",
      "weilbith/nvim-code-action-menu",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      local cmp_lsp = require("cmp_nvim_lsp")
      local illuminate = require("illuminate")
      local inlayhints = require("lsp-inlayhints")
      local lightbulb = require("nvim-lightbulb")
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local mason_null_ls = require("mason-null-ls")
      local lspconfig = require("lspconfig")
      local null_ls = require("null-ls")
      local schemastore = require("schemastore")
      local trouble = require("trouble")

      illuminate.configure({
        filetypes_denylist = window_filetypes,
        min_count_to_highlight = 2,
      })

      local illuminate_visual_ag = vim.api.nvim_create_augroup("illuminate_visual", {})
      vim.api.nvim_create_autocmd(
        "ModeChanged",
        {
          pattern = "*:[vV\x16]*",
          command = "IlluminatePauseBuf",
          group = illuminate_visual_ag,
        }
      )
      vim.api.nvim_create_autocmd(
        "ModeChanged",
        {
          pattern = "[vV\x16]*:*",
          command = "IlluminateResumeBuf",
          group = illuminate_visual_ag,
        }
      )

      inlayhints.setup()
      trouble.setup()

      lightbulb.setup({
        sign = {
          enabled = true,
          priority = 10,
        },
        autocmd = {
          enabled = true,
        }
      })
      vim.fn.sign_define("LightBulbSign", { text = "襁", texthl = "", linehl = "", numhl = "" })

      vim.g.symbols_outline = {
        highlight_hovered_item = false,
        relative_width = false,
        width = 50,
        auto_preview = false,
      }

      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      -- local signs = {Error = "", Warn = "", Hint = "", Info = ""}
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.diagnostic.config({
        virtual_text = {
          source = "always",
        },
        float = {
          source = "always",
        },
        signs = true,
        underline = false,
        update_in_insert = true,
        severity_sort = false,
      })

      vim.api.nvim_set_keymap("n", "<Leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>et", "<cmd>TroubleToggle<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", keymap_opts)
      vim.api.nvim_set_keymap("n", "<Leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", keymap_opts)

      local on_attach = function(client, bufnr)
        illuminate.on_attach(client, bufnr)
        inlayhints.on_attach(client, bufnr)

        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>ca", "<cmd>CodeActionMenu<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>f", "<cmd>lua vim.lsp.buf.format{ async = true }<CR>",
          keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
          keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>wl",
          "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", keymap_opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
          keymap_opts)
      end

      local capabilities = cmp_lsp.default_capabilities()

      local servers = {
        ansiblels = {},
        bashls = {
          filetypes = {
            "bash",
            "sh",
          },
        },
        dockerls = {},
        docker_compose_language_service = {},
        groovyls = {
          filetypes = {
            "groovy",
            "Jenkinsfile",
          },
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              experimentalPostfixCompletions = true,
              staticcheck = true,
              usePlaceholders = true,
            },
          },
        },
        grammarly = {},
        jsonls = {},
        marksman = {},
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                pylint = {
                  enabled = true,
                  executable = "pylint",
                  args = {
                    "--output-format=text",
                    -- "--init-hook='import pylint_venv; pylint_venv.inithook(force_venv_activation=True)'",
                    "--load-plugins=pylint.extensions.mccabe",
                    "--disable=missing-docstring,empty-docstring,line-too-long",
                  },
                },
                jedi_completion = {
                  fuzzy = true,
                },
                flake8 = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                autopep8 = {
                  enabled = false,
                },
                yapf = {
                  enabled = false,
                },
                pycodestyle = {
                  enabled = true,
                },
              },
            },
          },
        },
        rust_analyzer = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" }
              }
            }
          }
        },
        terraformls = {
          settings = {
            ["terraform-ls"] = {
              experimentalFeatures = {
                prefillRequiredFields = true,
              },
            },
          },
        },
        tflint = {},
        yamlls = {
          settings = {
            yaml = {
              hover = true,
              completion = true,
              validate = true,
              schemas = schemastore.json.schemas(),
            },
          },
          filetypes = {
            "yaml.ansible",
            "yaml",
          },
        }
      }

      local servers_ensure_installed = {}
      for key, _ in pairs(servers) do
        table.insert(servers_ensure_installed, key)
      end

      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = servers_ensure_installed
      })

      mason_lspconfig.setup_handlers {
        function(server_name)
          if servers[server_name] == nil then
            vim.notify("LSP server \"" .. server_name .. "\" installed but no config defined")
          else
            local config = vim.tbl_deep_extend("force", {
              on_attach = on_attach,
              capabilities = capabilities,
              flags = {
                -- debounce_text_changes = 150,
                debounce_text_changes = nil,
                allow_incremental_sync = true
              },
            }, servers[server_name])

            lspconfig[server_name].setup(config)
          end
        end,
      }

      mason_null_ls.setup({
        automatic_setup = true,
        ensure_installed = {
          -- formatters
          "prettier",
          "shfmt",
          "stylua",
          -- linters
          "actionlint",
          "ansible-lint",
          "commitlint",
          "editorconfig-checker",
          "gitlint",
          "jsonlint",
          "luacheck",
          "shellcheck",
          "shellharden",
          "tflint",
          "yamllint",
        },
        handlers = {
          function(source_name, methods)
            require("mason-null-ls.automatic_setup")(source_name, methods)
          end,
          stylua = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.stylua)
          end,
          shellcheck = function(source_name, methods)
            null_ls.register(null_ls.builtins.diagnostics.shellcheck.with({
               filetypes = { "bash", "zsh", "sh" },
            }))
          end,
        },
      })

      null_ls.setup({
        sources = {
          null_ls.builtins.diagnostics.trail_space,
        },
        should_attach = function(bufnr)
          for _, filetype in pairs(window_filetypes) do
            if vim.api.nvim_buf_get_option(bufnr, "filetype"):match("^" .. filetype) then
              return false
            end
          end
          for _, filename in pairs(window_filenames) do
            if vim.api.nvim_buf_get_name(bufnr):match(".*" .. filename .. ".*") then
              return false
            end
          end
          return true
        end,
      })

    end,
  }
}
