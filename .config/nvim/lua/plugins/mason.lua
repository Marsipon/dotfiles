local M = {}

local configured = false
local install_started = false

local packages = {
	"lua-language-server",
	"pyright",
	"bash-language-server",
	"typescript-language-server",
	"gopls",
	"kotlin-lsp",
	"terraform-ls",
	"tflint",
	"rust-analyzer",
	"buf",
	"stylua",
	"luacheck",
	"ruff",
	"prettierd",
	"eslint_d",
	"shellcheck",
	"shfmt",
	"gofumpt",
	"revive",
	"debugpy",
	"delve",
	"codelldb",
}

local function ensure_installed()
	if install_started then
		return
	end
	install_started = true

	local registry = require("mason-registry")
	local function install_missing()
		for _, name in ipairs(packages) do
			if registry.has_package(name) and not registry.is_installed(name) then
				local pkg = registry.get_package(name)
				if not pkg:is_installing() then
					pkg:install()
				end
			end
		end
	end

	registry.refresh(function()
		vim.schedule(install_missing)
	end)
end

function M.ensure_setup()
	if configured then
		return
	end

	require("plugins").load("mason.nvim")
	require("mason").setup({})
	configured = true
end

function M.setup()
	M.ensure_setup()

	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.schedule(ensure_installed)
		end,
	})
end

return M
