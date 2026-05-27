local M = {}
local configured = false

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load("which-key.nvim")
	require("which-key").setup({})
	configured = true
end

function M.setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = ensure_setup,
	})
end

return M
