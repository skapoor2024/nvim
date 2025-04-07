return{
	{	"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate", -- This will run the initial parser installation
		config = function()
			require("nvim-treesitter.configs").setup({
				-- Add languages you want to enable here
				ensure_installed = {  "c", "cpp", "rust", "python", "go", "javascript", "typescript", "tsx", "lua" }, -- Example: Add common ML languages like JavaScript
				sync_install = false,
				-- Automatically install missing parsers when opening a file
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				additional_vim_regex_highlight = false,
			})
		end,
	},
	{
		"nvim-treesitter/playground",
	},
}
