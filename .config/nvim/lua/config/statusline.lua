local M = {}

local uv = vim.uv or vim.loop
local cached_branch = ""
local last_check = 0

function M.git_branch()
	local now = uv.now()
	if now - last_check > 5000 then
		last_check = now
		vim.system({ "git", "branch", "--show-current" }, { text = true }, function(obj)
			cached_branch = (obj.stdout or ""):gsub("%s+$", "")
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end)
	end

	if cached_branch ~= "" then
		return "Git: " .. cached_branch
	end

	return ""
end

function M.file_type()
	local ft = vim.bo.filetype
	local icons = {
		lua = "\u{e620} ",
		python = "\u{e73c} ",
		javascript = "\u{e74e} ",
		typescript = "\u{e628} ",
		javascriptreact = "\u{e7ba} ",
		typescriptreact = "\u{e7ba} ",
		html = "\u{e736} ",
		css = "\u{e749} ",
		scss = "\u{e749} ",
		json = "\u{e60b} ",
		markdown = "\u{e73e} ",
		vim = "\u{e62b} ",
		sh = "\u{f489} ",
		bash = "\u{f489} ",
		zsh = "\u{f489} ",
		rust = "\u{e7a8} ",
		go = "\u{e724} ",
		c = "\u{e61e} ",
		cpp = "\u{e61d} ",
		java = "\u{e738} ",
		php = "\u{e73d} ",
		ruby = "\u{e739} ",
		swift = "\u{e755} ",
		kotlin = "\u{e634} ",
		dart = "\u{e798} ",
		elixir = "\u{e62d} ",
		haskell = "\u{e777} ",
		sql = "\u{e706} ",
		yaml = "\u{f481} ",
		toml = "\u{e615} ",
		xml = "\u{f05c} ",
		dockerfile = "\u{f308} ",
		gitcommit = "\u{f418} ",
		gitconfig = "\u{f1d3} ",
		vue = "\u{fd42} ",
		svelte = "\u{e697} ",
		astro = "\u{e628} ",
	}

	if ft == "" then
		return "Type: text"
	end

	return "Type: " .. ((icons[ft] or "\u{f15b} ") .. ft)
end

function M.file_size()
	local size = vim.fn.getfsize(vim.fn.expand("%"))
	if size < 0 then
		return ""
	end

	local size_str
	if size < 1024 then
		size_str = size .. "B"
	elseif size < 1024 * 1024 then
		size_str = string.format("%.1fK", size / 1024)
	else
		size_str = string.format("%.1fM", size / 1024 / 1024)
	end

	return "Size: " .. size_str
end

function M.lsp_status()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].buftype ~= "" then
		return ""
	end

	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if #clients == 0 then
		return "LSP: off"
	end

	local names = {}
	local seen = {}
	for _, client in ipairs(clients) do
		if not seen[client.name] then
			seen[client.name] = true
			names[#names + 1] = client.name
		end
	end
	table.sort(names)

	local label = table.concat(names, ", ")
	if #names > 2 then
		label = names[1] .. " +" .. (#names - 1)
	end

	local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
	local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })

	if errors > 0 then
		local suffix = errors == 1 and "error" or "errors"
		return "LSP: " .. errors .. " " .. suffix .. " " .. label
	end

	if warnings > 0 then
		local suffix = warnings == 1 and "warning" or "warnings"
		return "LSP: " .. warnings .. " " .. suffix .. " " .. label
	end

	return "LSP: ok " .. label
end

local function join_sections(parts)
	local items = {}
	for _, part in ipairs(parts) do
		if part and part ~= "" then
			items[#items + 1] = part
		end
	end

	return table.concat(items, " \u{e0b1} ")
end

function M.file_size_section()
	local size = M.file_size()
	if size == "" then
		return ""
	end

	return " \u{e0b1} " .. size
end

function M.right_status()
	return join_sections({
		M.git_branch(),
		M.file_type(),
		M.lsp_status(),
	})
end

function M.mode_icon()
	local mode = vim.fn.mode()
	local modes = {
		n = " \u{f121}  NORMAL",
		i = " \u{f11c}  INSERT",
		v = " \u{f0168} VISUAL",
		V = " \u{f0168} V-LINE",
		["\22"] = " \u{f0168} V-BLOCK",
		c = " \u{f120} COMMAND",
		s = " \u{f0c5} SELECT",
		S = " \u{f0c5} S-LINE",
		["\19"] = " \u{f0c5} S-BLOCK",
		R = " \u{f044} REPLACE",
		r = " \u{f044} REPLACE",
		["!"] = " \u{f489} SHELL",
		t = " \u{f120} TERMINAL",
	}

	return modes[mode] or (" \u{f059} " .. mode)
end

local function active_statusline()
	return table.concat({
		"  ",
		"%#StatusLineBold#",
		"%{v:lua.mode_icon()}",
		"%#StatusLine#",
		" \u{e0b1} %f %h%m%r",
		"%{v:lua.file_size_section()}",
		"%=",
		"%{v:lua.right_status()}",
		" \u{e0b1} Ln %l, Col %c",
	})
end

local function inactive_statusline()
	return "  %f %h%m%r%{v:lua.file_size_section()} %= %{v:lua.right_status()} \u{e0b1} Ln %l, Col %c"
end

function M.setup()
	_G.mode_icon = M.mode_icon
	_G.git_branch = M.git_branch
	_G.file_type = M.file_type
	_G.file_size = M.file_size
	_G.file_size_section = M.file_size_section
	_G.lsp_status = M.lsp_status
	_G.right_status = M.right_status

	vim.cmd([[
		highlight StatusLineBold gui=bold cterm=bold
	]])

	local group = vim.api.nvim_create_augroup("UserStatusline", { clear = true })

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		group = group,
		callback = function()
			vim.opt_local.statusline = active_statusline()
		end,
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		group = group,
		callback = function()
			vim.opt_local.statusline = inactive_statusline()
		end,
	})

	vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "DiagnosticChanged" }, {
		group = group,
		callback = function()
			vim.cmd("redrawstatus")
		end,
	})

	vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })
	vim.opt_local.statusline = active_statusline()
end

return M
