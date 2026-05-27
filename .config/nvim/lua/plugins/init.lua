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
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/mrcjkb/rustaceanvim",
	"https://github.com/Saecki/crates.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/antoinemadec/FixCursorHold.nvim",
	"https://github.com/nvim-neotest/neotest",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/nvim-neotest/neotest-python",
	"https://github.com/nvim-neotest/neotest-go",
	"https://github.com/marilari88/neotest-vitest",
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
	"https://github.com/mfussenegger/nvim-dap-python",
	"https://github.com/leoluz/nvim-dap-go",
	"https://github.com/zbirenbaum/copilot.lua",
	"https://github.com/CopilotC-Nvim/CopilotChat.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/ellisonleao/gruvbox.nvim",
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
