local M = {}
local configured = false

function M.load()
	require("plugins").load("fzf-lua")

	local fzf = require("fzf-lua")
	if not configured then
		fzf.setup({})
		configured = true
	end

	return fzf
end

function M.setup()
	vim.keymap.set("n", "<leader>ff", function()
		M.load().files()
	end, { desc = "FZF Files" })

	vim.keymap.set("n", "<leader>fg", function()
		M.load().live_grep()
	end, { desc = "FZF Live Grep" })

	vim.keymap.set("n", "<leader>fb", function()
		M.load().buffers()
	end, { desc = "FZF Buffers" })

	vim.keymap.set("n", "<leader>fh", function()
		M.load().help_tags()
	end, { desc = "FZF Help Tags" })

	vim.keymap.set("n", "<leader>fx", function()
		M.load().diagnostics_document()
	end, { desc = "FZF Diagnostics Document" })

	vim.keymap.set("n", "<leader>fX", function()
		M.load().diagnostics_workspace()
	end, { desc = "FZF Diagnostics Workspace" })
end

return M
