local M = {}
local configured = false

local function ensure_setup()
	if configured then
		return require("flash")
	end

	require("plugins").load("flash.nvim")

	local flash = require("flash")
	flash.setup({
		modes = {
			search = { enabled = false },
			char = { enabled = false },
		},
	})
	configured = true
	return flash
end

function M.setup()
	vim.keymap.set({ "n", "x", "o" }, "f", function()
		ensure_setup().jump({
			search = {
				max_length = 2,
			},
		})
	end, { desc = "Flash jump" })
end

return M
