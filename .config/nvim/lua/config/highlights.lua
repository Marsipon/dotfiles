local M = {}

local function set_transparent()
	local groups = {
		"Normal",
		"NormalNC",
		"EndOfBuffer",
		"NormalFloat",
		"FloatBorder",
		"SignColumn",
		"StatusLine",
		"StatusLineNC",
		"TabLine",
		"TabLineFill",
		"TabLineSel",
		"ColorColumn",
	}

	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { bg = "none" })
	end

	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
end

function M.setup()
	vim.opt.termguicolors = true
	vim.cmd.colorscheme("habamax")
	set_transparent()
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
end

function M.setup_nvim_tree()
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
end

return M
