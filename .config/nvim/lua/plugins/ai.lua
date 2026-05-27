local M = {}

local copilot_configured = false
local chat_configured = false

local function ensure_copilot()
	if copilot_configured then
		return
	end

	require("plugins").load("copilot.lua")
	require("copilot").setup({
		panel = {
			enabled = true,
			auto_refresh = true,
			keymap = {
				jump_prev = "[[",
				jump_next = "]]",
				accept = "<CR>",
				refresh = "gr",
				open = "<M-CR>",
			},
		},
		suggestion = {
			enabled = true,
			auto_trigger = true,
			debounce = 75,
			keymap = {
				accept = "<M-l>",
				accept_word = "<M-w>",
				accept_line = false,
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<M-\\>",
				toggle_auto_trigger = false,
			},
		},
		filetypes = {
			help = false,
			gitcommit = true,
			gitrebase = false,
			markdown = true,
			["."] = true,
		},
		server_opts_overrides = {
			settings = {
				telemetry = {
					telemetryLevel = "off",
				},
			},
		},
	})

	copilot_configured = true
end

local function ensure_chat()
	if chat_configured then
		return require("CopilotChat")
	end

	ensure_copilot()
	require("plugins.fzf").load()
	require("plugins").load("CopilotChat.nvim")

	local chat = require("CopilotChat")
	chat.setup({})
	chat_configured = true
	return chat
end

local function current_selection()
	local select = require("CopilotChat.select")
	local mode = vim.fn.mode()
	if mode:find("^[vV\22]") then
		return select.visual
	end
	return select.buffer
end

local function ask(prompt)
	ensure_chat().ask(prompt, { selection = current_selection() })
end

function M.setup()
	vim.schedule(ensure_copilot)

	vim.keymap.set("n", "<leader>aa", function()
		ensure_copilot()
		require("copilot.suggestion").toggle_auto_trigger()
	end, { desc = "Toggle Copilot suggestions" })

	vim.keymap.set("n", "<leader>ap", function()
		ensure_copilot()
		require("copilot.panel").open()
	end, { desc = "Open Copilot panel" })

	vim.keymap.set("n", "<leader>ac", function()
		ensure_chat().toggle()
	end, { desc = "Toggle Copilot Chat" })

	vim.keymap.set("n", "<leader>ax", function()
		ensure_chat().reset()
	end, { desc = "Reset Copilot Chat" })

	vim.keymap.set("n", "<leader>am", function()
		ensure_chat()
		vim.cmd("CopilotChatModels")
	end, { desc = "Select Copilot model" })

	vim.keymap.set("n", "<leader>aP", function()
		ensure_chat()
		vim.cmd("CopilotChatPrompts")
	end, { desc = "Copilot prompt library" })

	for _, mode in ipairs({ "n", "x" }) do
		vim.keymap.set(mode, "<leader>ae", function()
			ask("/Explain")
		end, { desc = "Explain code with Copilot" })

		vim.keymap.set(mode, "<leader>ar", function()
			ask("/Review")
		end, { desc = "Review code with Copilot" })

		vim.keymap.set(mode, "<leader>af", function()
			ask("/Fix")
		end, { desc = "Fix code with Copilot" })

		vim.keymap.set(mode, "<leader>at", function()
			ask("/Tests")
		end, { desc = "Generate tests with Copilot" })
	end
end

return M
