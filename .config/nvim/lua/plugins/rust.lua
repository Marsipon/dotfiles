local M = {}

local crates_configured = false

local function ensure_crates()
	if crates_configured then
		return
	end

	require("plugins").load("crates.nvim")
	require("crates").setup({})
	crates_configured = true
end

function M.setup()
	vim.g.rustaceanvim = {
		server = {
			default_settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
					checkOnSave = true,
					check = {
						command = "clippy",
					},
					procMacro = {
						enable = true,
					},
				},
			},
		},
		dap = {
			autoload_configurations = true,
		},
	}

	local group = vim.api.nvim_create_augroup("RustExtras", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "rust",
		callback = function(args)
			require("plugins").load("rustaceanvim")

			local opts = { buffer = args.buf, silent = true }
			vim.keymap.set("n", "<leader>rh", function()
				vim.cmd.RustLsp({ "hover", "actions" })
			end, vim.tbl_extend("force", opts, { desc = "Rust hover actions" }))

			vim.keymap.set("n", "<leader>re", function()
				vim.cmd.RustLsp("explainError")
			end, vim.tbl_extend("force", opts, { desc = "Explain Rust error" }))

			vim.keymap.set("n", "<leader>rR", function()
				vim.cmd.RustLsp({ "runnables" })
			end, vim.tbl_extend("force", opts, { desc = "Rust runnables" }))

			vim.keymap.set("n", "<leader>rD", function()
				vim.cmd.RustLsp({ "debuggables" })
			end, vim.tbl_extend("force", opts, { desc = "Rust debuggables" }))
		end,
	})

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = group,
		pattern = "Cargo.toml",
		callback = ensure_crates,
	})
end

return M
