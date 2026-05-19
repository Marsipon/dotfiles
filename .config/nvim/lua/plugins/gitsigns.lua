local M = {}
local configured = false

local function is_normal_named_buffer(bufnr)
	return vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function ensure_setup()
	if configured then
		return require("gitsigns")
	end

	require("plugins").load("gitsigns.nvim")

	local gitsigns = require("gitsigns")
	gitsigns.setup({
		signs = {
			add = { text = "\u{2590}" },
			change = { text = "\u{2590}" },
			delete = { text = "\u{2590}" },
			topdelete = { text = "\u{25e6}" },
			changedelete = { text = "\u{25cf}" },
			untracked = { text = "\u{25cb}" },
		},
		signcolumn = true,
		current_line_blame = false,
	})

	configured = true
	return gitsigns
end

function M.setup()
	local group = vim.api.nvim_create_augroup("LazyGitsigns", { clear = true })
	vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "BufFilePost" }, {
		group = group,
		callback = function(args)
			if is_normal_named_buffer(args.buf) then
				ensure_setup()
				vim.api.nvim_del_augroup_by_id(group)
			end
		end,
	})

	vim.keymap.set("n", "]h", function()
		ensure_setup().nav_hunk("next")
	end, { desc = "Next git hunk" })

	vim.keymap.set("n", "[h", function()
		ensure_setup().nav_hunk("prev")
	end, { desc = "Previous git hunk" })

	vim.keymap.set("n", "<leader>hs", function()
		ensure_setup().stage_hunk()
	end, { desc = "Stage hunk" })

	vim.keymap.set("n", "<leader>hr", function()
		ensure_setup().reset_hunk()
	end, { desc = "Reset hunk" })

	vim.keymap.set("n", "<leader>hp", function()
		ensure_setup().preview_hunk()
	end, { desc = "Preview hunk" })

	vim.keymap.set("n", "<leader>hb", function()
		ensure_setup().blame_line({ full = true })
	end, { desc = "Blame line" })

	vim.keymap.set("n", "<leader>hB", function()
		ensure_setup().toggle_current_line_blame()
	end, { desc = "Toggle inline blame" })

	vim.keymap.set("n", "<leader>hd", function()
		ensure_setup().diffthis()
	end, { desc = "Diff this" })
end

return M
