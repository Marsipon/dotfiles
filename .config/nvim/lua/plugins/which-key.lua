local M = {}
local configured = false

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load("which-key.nvim")

	local wk = require("which-key")
	wk.setup({})
	wk.add({
		{ "<leader>a", group = "AI" },
		{ "<leader>b", group = "Buffers" },
		{ "<leader>f", group = "Find" },
		{ "<leader>g", group = "Goto / Git" },
		{ "<leader>h", group = "Git hunks" },
		{ "<leader>l", group = "Lists" },
		{ "<leader>o", group = "Organize" },
		{ "<leader>p", group = "Path / previous" },
		{ "<leader>r", group = "Run / Debug / Test" },
		{ "<leader>s", group = "Split" },
		{ "<leader>t", group = "Toggle" },
	})

	configured = true
end

function M.setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = ensure_setup,
	})
end

return M
