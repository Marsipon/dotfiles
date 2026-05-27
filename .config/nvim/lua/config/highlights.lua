local M = {}

local themes = {
	dark = "gruvbox",
	light = "gruvbox",
}

local gruvbox_configured = false

local function ensure_theme(theme)
	if theme ~= "gruvbox" then
		return
	end

	require("plugins").load("gruvbox.nvim")
	if gruvbox_configured then
		return
	end

	require("gruvbox").setup({
		terminal_colors = true,
		transparent_mode = false,
		italic = {
			strings = false,
			emphasis = false,
			comments = false,
			operators = false,
			folds = false,
		},
		overrides = {
			Comment = { italic = false },
			String = { italic = false },
			Operator = { italic = false },
			Folded = { italic = false },
			Todo = { italic = false },
			Done = { italic = false },
			["@text.emphasis"] = { italic = false },
			["@markup.italic"] = { italic = false },
			markdownItalic = { italic = false },
			markdownBoldItalic = { italic = false },
			htmlItalic = { italic = false },
			htmlBoldItalic = { italic = false },
		},
	})
	gruvbox_configured = true
end

local function tweak_highlights()
	local transparent_groups = {
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

	for _, group in ipairs(transparent_groups) do
		vim.api.nvim_set_hl(0, group, { bg = "none" })
	end

	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
end

local function apply_colors()
	local theme = themes[vim.o.background] or themes.dark
	ensure_theme(theme)
	vim.cmd.colorscheme(theme)
	tweak_highlights()
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

	if package.loaded["nvim-tree.api"] then
		M.setup_nvim_tree()
	end
end

function M.setup()
	vim.opt.termguicolors = true
	apply_colors()
end

function M.toggle_background()
	vim.o.background = vim.o.background == "dark" and "light" or "dark"
	apply_colors()
	print("background:", vim.o.background)
end

function M.setup_nvim_tree()
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { link = "NormalNC" })
	vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { link = "SignColumn" })
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { link = "Normal" })
	vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { link = "EndOfBuffer" })
end

return M
