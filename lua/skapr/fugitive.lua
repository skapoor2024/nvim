
return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "Gmove", "Gdelete", "GBrowse" },
  keys = {
    { "<leader>gs", ":Git<CR>", desc = "Open Git status" },
    { "<leader>gc", ":Git commit<CR>", desc = "Git commit" },
    { "<leader>gp", ":Git push<CR>", desc = "Git push" },
    { "<leader>gl", ":Git pull<CR>", desc = "Git pull" },
    { "<leader>gb", ":Git blame<CR>", desc = "Git blame" },
    { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git diff split" },
  },
  config = function()
    vim.g.fugitive_no_maps = 1 -- Disable default Fugitive mappings if needed
  end,
}
