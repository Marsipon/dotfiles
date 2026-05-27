local M = {}
local configured = false

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load("trouble.nvim")
	require("trouble").setup({})
	configured = true
end

local function open(args)
	ensure_setup()
	vim.cmd("Trouble " .. args)
end

function M.setup()
	vim.keymap.set("n", "<leader>ld", function()
		open("diagnostics toggle filter.buf=0")
	end, { desc = "Buffer diagnostics list" })

	vim.keymap.set("n", "<leader>lD", function()
		open("diagnostics toggle")
	end, { desc = "Workspace diagnostics list" })

	vim.keymap.set("n", "<leader>ll", function()
		open("loclist toggle")
	end, { desc = "Location list" })

	vim.keymap.set("n", "<leader>lq", function()
		open("qflist toggle")
	end, { desc = "Quickfix list" })

	vim.keymap.set("n", "<leader>ls", function()
		open("symbols toggle focus=false")
	end, { desc = "Document symbols list" })

	vim.keymap.set("n", "<leader>lr", function()
		open("lsp toggle focus=false win.position=right")
	end, { desc = "LSP definitions / references list" })
end

return M
