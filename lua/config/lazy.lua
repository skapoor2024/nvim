-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
-- Adding some shortcuts here. Other places it gets difficult to load these keys unitl you save it as config function
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.softtabstop = 4 -- Number of spaces for a Tab key press (useful for visual consistency)

-- TO save the tree in undo dir for treesitter
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- For search related
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.colorcolumn = "80"

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set the line number
vim.keymap.set('n', '<leader>n', ":set number!<CR>",{ noremap = true, silent = true, desc = "set line number"})
vim.keymap.set('n', '<leader>rn', ":set relativenumber!<CR>",{  noremap = true, silent = true, desc = "set relative line number"})

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import ="skapr" },
    { import ="lsp"},
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  --install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
-- Set tokyonight as the active colorscheme
vim.cmd.colorscheme("tokyonight-night")



-- Set some keybinds for vim
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { noremap = true, silent = true, desc = "Open netrw" })

-- Set some keybindings for lsp
