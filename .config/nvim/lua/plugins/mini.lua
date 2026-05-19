local M = {}
local configured = false

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load("mini.nvim")

	require("mini.ai").setup({})
	require("mini.comment").setup({})
	require("mini.move").setup({})
	require("mini.surround").setup({})
	require("mini.cursorword").setup({})
	require("mini.indentscope").setup({})
	require("mini.pairs").setup({})
	require("mini.trailspace").setup({})
	require("mini.bufremove").setup({})
	require("mini.notify").setup({})
	require("mini.icons").setup({})

	configured = true
end

function M.setup()
	local group = vim.api.nvim_create_augroup("LazyMini", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		once = true,
		callback = function()
			vim.schedule(ensure_setup)
		end,
	})
end

return M
