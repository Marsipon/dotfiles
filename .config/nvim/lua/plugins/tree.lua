local M = {}

local loaded = false

function M.toggle()
	if not loaded then
		vim.cmd("packadd nvim-tree.lua")
		require("nvim-tree").setup({
			view = { width = 35 },
			filters = { dotfiles = false },
			renderer = { group_empty = true },
		})
		require("config.highlights").setup_nvim_tree()
		loaded = true
	end

	require("nvim-tree.api").tree.toggle()
end

function M.setup()
	vim.keymap.set("n", "<leader>e", M.toggle, { desc = "Toggle NvimTree" })
end

return M
