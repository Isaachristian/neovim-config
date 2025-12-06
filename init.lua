-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.termguicolors = true
vim.opt.mouse = ''
vim.opt.scrolloff = 999
vim.opt.signcolumn = "yes"

-- Keymaps
vim.keymap.set("n", "<leader>q", ":xa<CR>")
vim.keymap.set("i", "jj", "<Esc>")

-- Plugins
require("lazy").setup({
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
          "postgres_lsp",
          "lua_ls",
        },
      })
  
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
  
      -- Svelte
      vim.lsp.config.svelte = {
				cmd = { "svelteserver", "--stdio" },
				root_markers = { "package.json", ".git" },
				capabilities = capabilities
			}
			vim.lsp.enable('svelte')
  
			-- TypeScript
      vim.lsp.config.ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        root_markers = { "package.json", "tsconfig.json", ".git" },
        capabilities = capabilities,
      }
			vim.lsp.enable('ts_ls')

      -- ESLint
      vim.lsp.config.eslint = {
        cmd = { "vscode-eslint-language-server", "--stdio" },
        root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json" },
        capabilities = capabilities,
      }
			vim.lsp.enable('eslint')

      -- Tailwind
      vim.lsp.config.tailwindcss = {
        cmd = { "tailwindcss-language-server", "--stdio" },
        root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json" },
        capabilities = capabilities,
      }
			vim.lsp.enable('tailwindcss')

      -- Postgres
      vim.lsp.config.postgres_lsp = {
        cmd = { "postgres_lsp" },
        root_markers = { ".git" },
        capabilities = capabilities,
      }
			vim.lsp.enable('postgres_lsp')

			-- Inline diagnostics
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
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
      "hrsh7th/cmp-buffer",
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
          { name = "buffer" },
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
        },
        format_on_save = {
          timeout_ms = 5000,
          lsp_fallback = true,
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
})
