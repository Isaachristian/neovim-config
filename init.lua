----------------------------------------------------------------------------------------------------
-- Basic Setup
----------------------------------------------------------------------------------------------------

-- Basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.showmode = false
vim.o.undofile = true
vim.o.list = true
vim.o.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.termguicolors = true
vim.opt.mouse = ""
vim.opt.scrolloff = 999
vim.opt.signcolumn = "yes"
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.colorcolumn = "101"

-- Keymaps
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<leader>q", ":xa<CR>")
vim.keymap.set("n", "<leader>w", ":wa<CR>")
vim.keymap.set("n", "<leader>n", ":set relativenumber!<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Customizations
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

----------------------------------------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------------------------------------

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
	-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
	-- used for completion, annotations and signatures of Neovim apis
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"svelte",
					"ts_ls",
					"eslint",
					"tailwindcss",
					-- "postgres_lsp",
					-- "lua_ls",
					"stylua",
				},
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Svelte
			vim.lsp.config.svelte = {
				cmd = { "svelteserver", "--stdio" },
				root_markers = { "package.json", ".git" },
				capabilities = capabilities,
			}
			vim.lsp.enable("svelte")

			-- TypeScript
			vim.lsp.config.ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				root_markers = { "package.json", "tsconfig.json", ".git" },
				capabilities = capabilities,
			}
			vim.lsp.enable("ts_ls")

			-- ESLint
			vim.lsp.config.eslint = {
				cmd = { "vscode-eslint-language-server", "--stdio" },
				root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json" },
				capabilities = capabilities,
			}
			vim.lsp.enable("eslint")

			-- Tailwind
			vim.lsp.config.tailwindcss = {
				cmd = { "tailwindcss-language-server", "--stdio" },
				root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json" },
				capabilities = capabilities,
			}
			vim.lsp.enable("tailwindcss")

			-- Postgres
			vim.lsp.config.postgres_lsp = {
				cmd = { "postgres-language-server", "lsp-proxy" },
				filetypes = { "sql" },
				root_markers = { "postgres-language-server.jsonc" },
				workspace_required = true,
				capabilities = capabilities,
			}
			vim.lsp.enable("postgres_lsp")

			-- Lua
			vim.lsp.config.lua_ls = {
				cmd = { "lua-language-server" },
				root_markers = { ".git" },
				capabilities = capabilities,
			}
			vim.lsp.enable("lua_ls")

			-- Inline diagnostics
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			-- Keymaps
			vim.keymap.set("n", "grd", vim.lsp.buf.definition)
			vim.keymap.set("n", "K", vim.lsp.buf.hover)
			vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
			vim.keymap.set("n", "grn", vim.lsp.buf.rename)
			vim.keymap.set("n", "grr", vim.lsp.buf.references)

			-- Close quickfix after selecting item
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "qf",
				callback = function()
					vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true })
				end,
			})
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			--"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					-- { name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					sql = { "pg_format" },
					-- sql = { "prettier" },
					lua = { "stylua" },
				},
				format_on_save = {
					timeout_ms = 5000,
					lsp_fallback = true,
				},
				formatters = {
					pg_format = {
						prepend_args = {
							"--spaces",
							"2", -- or 4
							"--function-case",
							"1", -- 0=unchanged, 1=lowercase, 2=uppercase, 3=capitalize
							"--keyword-case",
							"1", -- same options as function-case
							-- "--comma-break", -- break after commas in SELECT
							"--no-extra-line", -- remove extra blank lines
						},
					},
				},
			})
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				modules = {},
				sync_install = false,
				auto_install = true,
				ignore_install = {},
				ensure_installed = {
					"svelte",
					"typescript",
					"javascript",
					"html",
					"css",
					"sql",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						"seed.sql",
					},
				},
			})

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sf", builtin.find_files)
			vim.keymap.set("n", "<leader>sg", builtin.live_grep)
			vim.keymap.set("n", "<leader>sb", builtin.buffers)
			vim.keymap.set("n", "<leader>sh", builtin.help_tags)
		end,
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup()
			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
			vim.keymap.set("n", "<leader>ff", ":NvimTreeFindFile<CR>")
		end,
	},

	-- Color scheme
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	-- {
	-- 	"Mofiqul/dracula.nvim",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd.colorscheme("dracula")
	-- 	end,
	-- },

	-- Adds git related signs to the gutter, as well as utilities for managing changes
	{

		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- status bar
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
		},
	},
})
