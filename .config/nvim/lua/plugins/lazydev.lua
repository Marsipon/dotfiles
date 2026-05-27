local M = {}
local configured = false

function M.ensure_setup()
	if configured then
		return
	end

	require("plugins").load("lazydev.nvim")
	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})

	configured = true
end

function M.setup()
	M.ensure_setup()
end

return M
