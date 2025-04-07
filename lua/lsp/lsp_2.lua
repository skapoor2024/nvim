return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Ensure Mason and Mason-LSPConfig are loaded first to manage servers
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- Completion Engine and Sources (DEPENDENCIES FOR LSP AND COMPLETION)
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp", -- Source for LSP completions
          "hrsh7th/cmp-buffer",   -- Source for buffer words
          "hrsh7th/cmp-path",     -- Source for file paths
          "hrsh7th/cmp-cmdline",  -- Source for command line
          "L3MON4D3/LuaSnip",     -- Snippet Engine (Recommended)
          "saadparwaiz1/cmp_luasnip", -- Snippet Source for nvim-cmp
          { -- <<<<<<< BLINK.CMP MOVED HERE AS A DEPENDENCY OF NVIM-CMP >>>>>>>
            "saghen/blink.cmp",
             -- lazydev is primarily for Lua development helpers, often used with lua_ls
             -- It's okay here, but could also be a top-level plugin if used elsewhere.
            dependencies = {
               {
                  "folke/lazydev.nvim",
                  ft = "lua", -- only load on lua files
                  opts = {
                    library = {
                      -- Load luvit types when the `vim.uv` word is found
                      { path = "luvit-meta/library", words = { "vim%.uv" } },
                    },
                  },
                },
            },
             -- Keep your blink.cmp options if needed, otherwise remove opts = {}
            opts = {}, -- Add any specific blink.cmp options here if you have them
                      -- The original config didn't have specific blink opts, only lazydev opts.
                      -- If the lazydev setup above is meant *only* for blink, keep it nested.
                      -- If lazydev is generally useful for your Lua setup, consider making it a top-level plugin.
          },
        },
      },
    },
    config = function()
      local cmp = require("cmp")
      local cmp_lsp = require("cmp_nvim_lsp")
      local lspconfig = require("lspconfig")
      local capabilities = cmp_lsp.default_capabilities() -- Get capabilities from nvim-cmp

      -- Setup mason and ensure the required LSP servers are installed
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "gopls", "pylsp" },
      })

      -- Define a generic on_attach function for LSP servers
      -- This is where you can set keymaps specific to LSP features
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc') -- Not needed with nvim-cmp usually

        -- Mappings (Example mappings, customize as needed)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      end

      -- Configure nvim-cmp
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(), -- Trigger completion
          ['<C-e>'] = cmp.mapping.abort(),       -- Close completion
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept selected suggestion. 'select = true' means pressing enter confirms even if you haven't explicitly selected with up/down.
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require('luasnip').expand_or_jumpable() then
               require('luasnip').expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }), -- i for insert mode, s for select mode (visual)
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require('luasnip').jumpable(-1) then
              require('luasnip').jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- Order of sources matters. This order prioritizes LSP, then snippets, then blink, then buffer words, then paths.
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' }, -- Snippet source
          { name = 'blink' },   -- <<<<<<< BLINK.CMP ADDED AS A SOURCE >>>>>>>
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- Set configuration for specific completion sources.
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      -- Configure LSP Servers - Pass capabilities and on_attach to each server setup

      -- Lua LSP
      lspconfig.lua_ls.setup({
        capabilities = capabilities, -- Pass capabilities
        on_attach = on_attach,       -- Pass on_attach function
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false, -- Make sure lazydev provides types if needed
            },
            completion = {
               callSnippet = "Replace" -- Important for snippet integration with LuaLS
            }
          },
        },
      })

      -- Rust LSP (rust-analyzer)
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities, -- Pass capabilities
        on_attach = on_attach,       -- Pass on_attach function
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })

      -- C/C++ LSP (clangd)
      lspconfig.clangd.setup({
        capabilities = capabilities, -- Pass capabilities
        on_attach = on_attach,       -- Pass on_attach function
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
      })

      -- Go LSP (gopls)
      lspconfig.gopls.setup({
        capabilities = capabilities, -- Pass capabilities
        on_attach = on_attach,       -- Pass on_attach function
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            usePlaceholders = true, -- Required for snippet support with gopls
          },
        },
      })

      -- Python LSP (pylsp)
      lspconfig.pylsp.setup({
        capabilities = capabilities, -- Pass capabilities
        on_attach = on_attach,       -- Pass on_attach function
        settings = {
          pylsp = {
            plugins = {
              pyflakes = { enabled = true },
              pycodestyle = { enabled = true },
              pylsp_mypy = { enabled = true },
              pylsp_black = { enabled = true },
              -- Example: Adding Jedi completer if needed (ensure pylsp[jedi] is installed)
              -- jedi_completion = { enabled = true },
              -- pylsp_ruff = { enabled = true } -- Consider using ruff instead of pyflakes/pycodestyle
            },
          },
        },
      })

    end,
  },

  -- You might want LuaSnip configuration here as well, or rely on defaults
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest major version, or use "*", or nil
    -- install jsregexp (optional!:).
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" }, -- Optional: Common snippets collection
    config = function()
        -- Basic configuration, you might want more from LuaSnip docs
        require("luasnip.loaders.from_vscode").lazy_load()
    end
  },

   -- You had lazydev.nvim as a dependency of blink.cmp before.
   -- If it's generally useful for Lua development (like providing types for lua_ls),
   -- it might be better as a top-level plugin spec like this:
   {
     "folke/lazydev.nvim",
     ft = "lua", -- only load on lua files
     opts = {
       library = {
         -- Load luvit types when the `vim.uv` word is found
         { path = "luvit-meta/library", words = { "vim%.uv" } },
         -- You might want Neovim runtime types too
         vim.api.nvim_get_runtime_file("", true),
       },
     },
   },
}
