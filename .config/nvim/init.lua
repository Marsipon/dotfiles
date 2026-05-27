local function bootstrap_config_modules()
	local uv = vim.uv or vim.loop
	local source = debug.getinfo(1, "S").source
	local init_path = source:sub(1, 1) == "@" and source:sub(2) or source
	local init_dir = vim.fn.fnamemodify(init_path, ":p:h")
	local resolved_dir = uv.fs_realpath(init_dir)

	for _, root in ipairs({ resolved_dir, init_dir }) do
		if root and vim.fn.isdirectory(root .. "/lua") == 1 then
			vim.opt.rtp:prepend(root)

			local lua_patterns = {
				root .. "/lua/?.lua",
				root .. "/lua/?/init.lua",
			}

			for i = #lua_patterns, 1, -1 do
				local pattern = lua_patterns[i]
				if not package.path:find(pattern, 1, true) then
					package.path = pattern .. ";" .. package.path
				end
			end

			return
		end
	end
end

bootstrap_config_modules()

if vim.loader and vim.loader.enable then
	vim.loader.enable()
end

require("config.options")
require("config.highlights").setup()
require("config.statusline").setup()
require("config.keymaps")
require("config.autocmds")

require("plugins")
require("plugins.treesitter").setup()
require("plugins.tree").setup()
require("plugins.fzf").setup()
require("plugins.mini").setup()
require("plugins.gitsigns").setup()
require("plugins.mason").setup()
require("plugins.lazydev").setup()
require("plugins.rust").setup()
require("plugins.lsp").setup()
require("plugins.lazygit").setup()
require("plugins.trouble").setup()
require("plugins.dap").setup()
require("plugins.test").setup()
require("plugins.ai").setup()
require("plugins.which-key").setup()

require("config.terminal").setup()
