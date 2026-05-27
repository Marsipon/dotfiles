local M = {}

vim.pack.add({
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/kdheepak/lazygit.nvim"
})

local loaded = {}

function M.load(name)
	if loaded[name] then
		return true
	end

	local ok = pcall(vim.cmd, "packadd " .. name)
	if ok then
		loaded[name] = true
	end

	return ok
end

function M.load_many(names)
	for _, name in ipairs(names) do
		M.load(name)
	end
end

return M
