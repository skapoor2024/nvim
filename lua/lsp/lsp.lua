return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "saghen/blink.cmp",
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      "williamboman/mason.nvim",         -- Mason for managing LSP installations
      "williamboman/mason-lspconfig.nvim", -- Bridges mason with nvim-lspconfig
    },
    config = function()
      -- Setup mason and ensure the required LSP servers are installed
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "gopls", "pylsp" },
      })

      local lspconfig = require("lspconfig")
      -- Lua LSP
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      })

      -- Rust LSP (rust-analyzer)
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })

      -- C/C++ LSP (clangd)
      lspconfig.clangd.setup({
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
      })

      -- Go LSP (gopls)
      lspconfig.gopls.setup({
	cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
          },
        },
      })

      -- Python LSP (pylsp)
      lspconfig.pylsp.setup({
	settings = {
          pylsp = {
            plugins = {
              pyflakes = { enabled = true },
              pycodestyle = { enabled = true },
              pylsp_mypy = { enabled = true },
              pylsp_black = { enabled = true },
            },
          },
        },
      })
    end,
  },
}

