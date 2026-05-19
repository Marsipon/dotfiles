local M = {}
local configured = false

local function attach(bufnr, filetype)
	local treesitter = require("nvim-treesitter")
	local ok_lang, language = pcall(vim.treesitter.language.get_lang, filetype)

	if ok_lang and language and vim.tbl_contains(treesitter.get_installed(), language) then
		local ok = pcall(vim.treesitter.start, bufnr)
		if ok then
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end
	end
end

local function ensure_setup()
	if configured then
		return
	end

	require("plugins").load("nvim-treesitter")

	local treesitter = require("nvim-treesitter")
	treesitter.setup({})

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			attach(args.buf, args.match)
		end,
	})

	configured = true
end

function M.setup()
	local group = vim.api.nvim_create_augroup("LazyTreeSitter", { clear = true })
	vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "BufFilePost", "FileType" }, {
		group = group,
		callback = function(args)
			ensure_setup()

			if args.event == "FileType" then
				attach(args.buf, args.match)
			else
				local filetype = vim.bo[args.buf].filetype
				if filetype ~= "" then
					attach(args.buf, filetype)
				end
			end

			vim.api.nvim_del_augroup_by_id(group)
		end,
	})
end

return M
