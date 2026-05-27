local M = {}
local configured = false

local function ensure_setup()
	if configured then
		return require("neotest")
	end

	require("plugins").load_many({
		"FixCursorHold.nvim",
		"neotest",
		"neotest-python",
		"neotest-go",
		"neotest-vitest",
		"rustaceanvim",
	})

	local adapters = {}

	local ok_python, neotest_python = pcall(require, "neotest-python")
	if ok_python then
		adapters[#adapters + 1] = neotest_python({
			dap = { justMyCode = false },
			pytest_discover_instances = true,
		})
	end

	local ok_go, neotest_go = pcall(require, "neotest-go")
	if ok_go then
		adapters[#adapters + 1] = neotest_go({})
	end

	local ok_rust, rustacean_neotest = pcall(require, "rustaceanvim.neotest")
	if ok_rust then
		adapters[#adapters + 1] = rustacean_neotest
	end

	local ok_vitest, neotest_vitest = pcall(require, "neotest-vitest")
	if ok_vitest then
		adapters[#adapters + 1] = neotest_vitest({})
	end

	require("neotest").setup({ adapters = adapters })
	configured = true
	return require("neotest")
end

function M.setup()
	vim.keymap.set("n", "<leader>rr", function()
		ensure_setup().run.run()
	end, { desc = "Run nearest test" })

	vim.keymap.set("n", "<leader>rf", function()
		ensure_setup().run.run(vim.fn.expand("%"))
	end, { desc = "Run file tests" })

	vim.keymap.set("n", "<leader>ra", function()
		ensure_setup().run.run(vim.uv.cwd())
	end, { desc = "Run all tests" })

	vim.keymap.set("n", "<leader>rd", function()
		ensure_setup().run.run({ strategy = "dap" })
	end, { desc = "Debug nearest test" })

	vim.keymap.set("n", "<leader>rt", function()
		ensure_setup().run.run_last()
	end, { desc = "Run last test" })

	vim.keymap.set("n", "<leader>rs", function()
		ensure_setup().summary.toggle()
	end, { desc = "Toggle test summary" })

	vim.keymap.set("n", "<leader>rp", function()
		ensure_setup().output.open({ enter = true, auto_close = true })
	end, { desc = "Open test output" })

	vim.keymap.set("n", "<leader>rP", function()
		ensure_setup().output_panel.toggle()
	end, { desc = "Toggle test output panel" })
end

return M
