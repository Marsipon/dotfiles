local M = {}
local configured = false

local function is_normal_named_buffer(bufnr)
	return vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function setup_diagnostics()
	local diagnostic_signs = {
		Error = " ",
		Warn = " ",
		Hint = "",
		Info = "",
	}

	vim.diagnostic.config({
		virtual_text = { prefix = "●", spacing = 4 },
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
				[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
				[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
				[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
			},
		},
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			source = true,
			header = "",
			prefix = "",
			focusable = false,
			style = "minimal",
		},
	})

	do
		local orig = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded"
			return orig(contents, syntax, opts, ...)
		end
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
	end

	map("<leader>gd", function()
		require("plugins.fzf").load().lsp_definitions()
	end, "Go to definition (FZF)")

	map("<leader>gD", vim.lsp.buf.definition, "Go to definition")

	map("<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, "Go to definition in split")

	map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
	map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")

	map("<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, "Line diagnostics")

	map("<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, "Cursor diagnostics")

	map("<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, "Next diagnostic")

	map("<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, "Previous diagnostic")

	map("K", vim.lsp.buf.hover, "Hover documentation")
	map("gh", vim.lsp.buf.hover, "Hover documentation")

	map("<leader>fd", function()
		require("plugins.fzf").load().lsp_definitions()
	end, "Find definitions")

	map("<leader>fr", function()
		require("plugins.fzf").load().lsp_references()
	end, "Find references")

	map("<leader>ft", function()
		require("plugins.fzf").load().lsp_typedefs()
	end, "Find type definitions")

	map("<leader>fs", function()
		require("plugins.fzf").load().lsp_document_symbols()
	end, "Find document symbols")

	map("<leader>fw", function()
		require("plugins.fzf").load().lsp_workspace_symbols()
	end, "Find workspace symbols")

	map("<leader>fi", function()
		require("plugins.fzf").load().lsp_implementations()
	end, "Find implementations")

	if client:supports_method("textDocument/codeAction", bufnr) then
		map("<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, "Organize imports")
	end
end

local function setup_blink()
	local blink = require("blink.cmp")

	blink.setup({
		keymap = {
			preset = "none",
			["<C-Space>"] = { "show", "hide" },
			["<CR>"] = { "accept", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
		},
		appearance = { nerd_font_variant = "mono" },
		completion = { menu = { auto_show = true } },
		sources = { default = { "lsp", "path", "buffer", "snippets" } },
		snippets = {
			expand = function(snippet)
				require("luasnip").lsp_expand(snippet)
			end,
		},
		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = { download = true },
		},
	})

	vim.lsp.config["*"] = {
		capabilities = blink.get_lsp_capabilities(),
	}
end

local function setup_servers()
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				telemetry = { enable = false },
			},
		},
	})

	vim.lsp.config("pyright", {})
	vim.lsp.config("bashls", {})
	vim.lsp.config("ts_ls", {})
	vim.lsp.config("gopls", {})
	vim.lsp.config("clangd", {})
	vim.lsp.config("kotlin-lsp", {})

	vim.lsp.enable({
		"lua_ls",
		"pyright",
		"bashls",
		"ts_ls",
		"gopls",
		"clangd",
		"kotlin-lsp",
		"buf",
	})
end

local function setup_efm()
	local function configure()
		require("plugins").load("efmls-configs-nvim")

		local luacheck = require("efmls-configs.linters.luacheck")
		local stylua = require("efmls-configs.formatters.stylua")

		local rufflint = require("efmls-configs.linters.ruff")
		local ruffformat = require("efmls-configs.formatters.ruff")

		local prettier_d = require("efmls-configs.formatters.prettier_d")
		local eslint_d = require("efmls-configs.linters.eslint_d")

		local fixjson = require("efmls-configs.formatters.fixjson")

		local shellcheck = require("efmls-configs.linters.shellcheck")
		local shfmt = require("efmls-configs.formatters.shfmt")

		local cpplint = require("efmls-configs.linters.cpplint")
		local clangfmt = require("efmls-configs.formatters.clang_format")

		local go_revive = require("efmls-configs.linters.go_revive")
		local gofumpt = require("efmls-configs.formatters.gofumpt")

		local proto_lint = require("efmls-configs.linters.buf")
		local proto_fmt = require("efmls-configs.formatters.buf")

		vim.lsp.config("efm", {
			filetypes = {
				"c",
				"cpp",
				"css",
				"go",
				"html",
				"javascript",
				"javascriptreact",
				"json",
				"jsonc",
				"lua",
				"markdown",
				"python",
				"sh",
				"typescript",
				"typescriptreact",
				"vue",
				"svelte",
				"buf",
				"kotlin",
			},
			init_options = { documentFormatting = true },
			settings = {
				languages = {
					c = { clangfmt, cpplint },
					go = { gofumpt, go_revive },
					cpp = { clangfmt, cpplint },
					css = { prettier_d },
					html = { prettier_d },
					javascript = { eslint_d, prettier_d },
					javascriptreact = { eslint_d, prettier_d },
					json = { eslint_d, fixjson },
					jsonc = { eslint_d, fixjson },
					lua = { luacheck, stylua },
					markdown = { prettier_d },
					python = { rufflint, ruffformat },
					sh = { shellcheck, shfmt },
					typescript = { eslint_d, prettier_d },
					typescriptreact = { eslint_d, prettier_d },
					vue = { eslint_d, prettier_d },
					svelte = { eslint_d, prettier_d },
					proto = { proto_fmt, proto_lint },
				},
			},
		})
		vim.lsp.enable("efm")
	end

	if vim.v.vim_did_enter == 1 then
		vim.defer_fn(configure, 20)
	else
		local group = vim.api.nvim_create_augroup("DeferredEfmSetup", { clear = true })
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			once = true,
			callback = function()
				vim.defer_fn(configure, 20)
			end,
		})
	end
end

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load_many({
		"nvim-lspconfig",
		"mason.nvim",
		"blink.cmp",
		"LuaSnip",
	})

	require("mason").setup({})
	setup_blink()
	setup_servers()
	setup_efm()

	configured = true
end

function M.setup()
	local group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })
	local lazy_group = vim.api.nvim_create_augroup("LazyLspSetup", { clear = true })

	setup_diagnostics()
	vim.api.nvim_create_autocmd("LspAttach", { group = group, callback = lsp_on_attach })
	vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "BufFilePost" }, {
		group = lazy_group,
		callback = function(args)
			if is_normal_named_buffer(args.buf) then
				ensure_setup()
				vim.api.nvim_del_augroup_by_id(lazy_group)
			end
		end,
	})

	vim.keymap.set("n", "<leader>q", function()
		vim.diagnostic.setloclist({ open = true })
	end, { desc = "Open diagnostic list" })

	vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
end

return M
