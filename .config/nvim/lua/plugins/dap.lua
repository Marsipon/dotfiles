local M = {}
local configured = false

local function python_command()
	if vim.fn.executable("uv") == 1 then
		return "uv"
	end

	local python = vim.fn.exepath("python3")
	if python ~= "" then
		return python
	end

	python = vim.fn.exepath("python")
	if python ~= "" then
		return python
	end

	return "python3"
end

local function ensure_setup()
	if configured then
		return require("dap"), require("dapui")
	end

	require("plugins").load_many({
		"nvim-dap",
		"nvim-dap-ui",
		"nvim-nio",
		"nvim-dap-virtual-text",
		"nvim-dap-python",
		"nvim-dap-go",
	})

	local dap = require("dap")
	local dapui = require("dapui")

	dapui.setup({})
	require("nvim-dap-virtual-text").setup({})
	require("dap-python").setup(python_command())
	require("dap-python").test_runner = "pytest"
	require("dap-go").setup({})

	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	for _, event in ipairs({ "event_terminated", "event_exited" }) do
		dap.listeners.before[event]["dapui_config"] = function()
			dapui.close()
		end
	end

	configured = true
	return dap, dapui
end

function M.setup()
	vim.keymap.set("n", "<F5>", function()
		ensure_setup()
		require("dap").continue()
	end, { desc = "Debug continue" })

	vim.keymap.set("n", "<F10>", function()
		ensure_setup()
		require("dap").step_over()
	end, { desc = "Debug step over" })

	vim.keymap.set("n", "<F11>", function()
		ensure_setup()
		require("dap").step_into()
	end, { desc = "Debug step into" })

	vim.keymap.set("n", "<F12>", function()
		ensure_setup()
		require("dap").step_out()
	end, { desc = "Debug step out" })

	vim.keymap.set("n", "<leader>rb", function()
		ensure_setup()
		require("dap").toggle_breakpoint()
	end, { desc = "Toggle breakpoint" })

	vim.keymap.set("n", "<leader>rB", function()
		ensure_setup()
		require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, { desc = "Conditional breakpoint" })

	vim.keymap.set("n", "<leader>rc", function()
		ensure_setup()
		require("dap").continue()
	end, { desc = "Continue debug session" })

	vim.keymap.set("n", "<leader>ri", function()
		ensure_setup()
		require("dap").step_into()
	end, { desc = "Step into" })

	vim.keymap.set("n", "<leader>ro", function()
		ensure_setup()
		require("dap").step_over()
	end, { desc = "Step over" })

	vim.keymap.set("n", "<leader>rO", function()
		ensure_setup()
		require("dap").step_out()
	end, { desc = "Step out" })

	vim.keymap.set("n", "<leader>rl", function()
		ensure_setup()
		require("dap").run_last()
	end, { desc = "Run last debug session" })

	vim.keymap.set("n", "<leader>ru", function()
		local _, dapui = ensure_setup()
		dapui.toggle()
	end, { desc = "Toggle debug UI" })

	vim.keymap.set("n", "<leader>rx", function()
		ensure_setup()
		require("dap").terminate()
	end, { desc = "Terminate debug session" })
end

return M
