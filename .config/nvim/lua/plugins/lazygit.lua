local M = {}

local configured = false

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load_many({ "plenary.nvim", "lazygit.nvim" })
	configured = true
end

local function send_esc_to_lazygit(buf)
	local job = vim.b[buf].terminal_job_id
	if job then
		vim.api.nvim_chan_send(job, "\27")
	end
end

function M.open(command)
	ensure_setup()
	vim.cmd(command or "LazyGit")
end

function M.setup()
	local group = vim.api.nvim_create_augroup("LazyGitKeys", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "lazygit",
		callback = function(args)
			vim.keymap.set("t", "<Esc>", function()
				send_esc_to_lazygit(args.buf)
			end, { buffer = args.buf, silent = true, desc = "LazyGit cancel" })
		end,
	})

	vim.keymap.set("n", "<leader>gg", function()
		M.open("LazyGit")
	end, { desc = "LazyGit" })
end

return M
