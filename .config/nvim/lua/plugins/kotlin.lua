local M = {}

local configured = false
local intellij_server = nil -- absolute path, resolved in ensure_setup()

local kotlin_opts = {
	inlay_hints = {
		enabled = true,
		parameters = true,
		types_property = true,
		types_variable = true,
		function_return = true,
		function_parameter = true,
		lambda_return = true,
		lambda_receivers_parameters = true,
	},
}

-- Scan mason/packages/kotlin-lsp/ for a child directory that contains lib/
-- (Mason nests the server under a versioned subdir, e.g. kotlin-server-x.y.z/).
local function find_kotlin_lsp_server_dir()
	local base = vim.fn.stdpath("data") .. "/mason/packages/kotlin-lsp"
	local handle = vim.uv.fs_scandir(base)
	if not handle then
		return nil
	end
	while true do
		local name, ftype = vim.uv.fs_scandir_next(handle)
		if not name then
			break
		end
		if ftype == "directory" then
			local candidate = base .. "/" .. name
			if vim.fn.isdirectory(candidate .. "/lib") == 1 then
				return candidate
			end
		end
	end
	return nil
end

-- Build a workspace/configuration handler so the server receives inlay-hint
-- settings when it requests them (mirrors kotlin.nvim's setup_kotlin_lsp logic).
local function make_config_handler()
	local ih = kotlin_opts.inlay_hints or {}
	return function(err, params, ctx)
		local result = {}
		for _, item in ipairs(params.items or {}) do
			if item.section == "jetbrains.kotlin" then
				table.insert(result, {
					hints = {
						parameters = ih.parameters ~= false,
						["parameters.compiled"] = ih.parameters_compiled ~= false,
						["parameters.excluded"] = ih.parameters_excluded == true,
						settings = {
							types = {
								property = ih.types_property ~= false,
								variable = ih.types_variable ~= false,
							},
							lambda = { ["return"] = ih.lambda_return ~= false },
							value = { ranges = ih.value_ranges ~= false },
						},
						type = {
							["function"] = {
								["return"] = ih.function_return ~= false,
								parameter = ih.function_parameter ~= false,
							},
						},
						lambda = { receivers = { parameters = ih.lambda_receivers_parameters ~= false } },
						value = { kotlin = { time = ih.kotlin_time ~= false } },
					},
				})
			else
				table.insert(result, vim.NIL)
			end
		end
		return result
	end
end

-- Called on every FileType kotlin event. Configures and enables the LSP for
-- the current project, and activates all kotlin.nvim auxiliary modules.
local function setup_kotlin_buffer()
	if not intellij_server then
		return
	end

	-- kotlin.nvim auxiliary features (each module is internally idempotent).
	require("kotlin.autocommands").setup()
	require("kotlin.autocommands").setup_inlay_hints(kotlin_opts)
	require("kotlin.commands").setup()
	require("kotlin.diagnostics").setup()
	require("kotlin.package").setup()

	-- Derive a per-project workspace directory (same convention as kotlin.nvim).
	local workspace_base = require("kotlin").get_workspace_base_dir()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_dir = workspace_base .. "/" .. project_name
	vim.fn.mkdir(workspace_dir, "p")

	-- Configure the native intellij-server binary directly.
	-- kotlin.nvim's setup_kotlin_lsp builds a Java invocation via -cp lib/*,
	-- but this Mason package ships a pre-built native binary instead.
	vim.lsp.config("kotlin_ls", {
		cmd = {
			intellij_server,
			"--stdio",
			"--system-path=" .. workspace_dir,
		},
		filetypes = { "kotlin" },
		root_markers = kotlin_opts.root_markers or {
			"build.gradle",
			"build.gradle.kts",
			"settings.gradle",
			"settings.gradle.kts",
			"pom.xml",
			"mvnw",
		},
		capabilities = {
			textDocument = {
				inlayHint = { dynamicRegistration = true },
			},
		},
		handlers = {
			["workspace/configuration"] = make_config_handler(),
		},
	})
	vim.lsp.enable("kotlin_ls")
end

local function ensure_setup()
	if configured then
		return
	end
	configured = true

	require("plugins").load("kotlin.nvim")

	local server_dir = find_kotlin_lsp_server_dir()
	if not server_dir then
		vim.notify(
			"kotlin.nvim: cannot find Mason kotlin-lsp server directory under "
				.. vim.fn.stdpath("data")
				.. "/mason/packages/kotlin-lsp/",
			vim.log.levels.ERROR
		)
		return
	end

	local binary = server_dir .. "/bin/intellij-server"
	if vim.fn.executable(binary) ~= 1 then
		vim.notify("kotlin.nvim: intellij-server is not executable at: " .. binary, vim.log.levels.ERROR)
		return
	end
	intellij_server = binary

	-- Expose KotlinCleanWorkspace (uses kotlin.nvim's workspace path logic).
	vim.api.nvim_create_user_command("KotlinCleanWorkspace", function()
		require("kotlin").clean_workspace()
	end, { desc = "Clean Kotlin LSP workspace for current project" })

	-- Register the per-buffer LSP + feature setup for all future kotlin buffers.
	local kt_group = vim.api.nvim_create_augroup("kotlin_lsp", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "kotlin",
		group = kt_group,
		callback = setup_kotlin_buffer,
	})
end

function M.setup()
	local group = vim.api.nvim_create_augroup("KotlinPlugin", { clear = true })

	-- Guarantee ensure_setup() runs before the FileType event fires on the
	-- first kotlin buffer (BufReadPre and BufNewFile both precede FileType).
	vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
		group = group,
		pattern = { "*.kt", "*.kts" },
		once = true,
		callback = ensure_setup,
	})

	-- Per-buffer keymaps. Also acts as fallback initialisation if the
	-- BufReadPre/BufNewFile path was skipped (e.g. :set ft=kotlin).
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "kotlin",
		callback = function(args)
			if not configured then
				ensure_setup()
				-- FileType already fired so kotlin_lsp's autocmd won't catch this
				-- buffer; call setup_kotlin_buffer directly as a fallback.
				setup_kotlin_buffer()
			end

			local opts = { buffer = args.buf, silent = true, noremap = true }
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
			end

			map("<leader>ki", function()
				require("kotlin.commands").organize_imports()
			end, "Kotlin: Organize imports")

			map("<leader>kh", function()
				require("kotlin.commands").toggle_inlay_hints()
			end, "Kotlin: Toggle inlay hints")

			map("<leader>kH", function()
				require("kotlin.diagnostics").toggle_hints()
			end, "Kotlin: Toggle hint diagnostics")

			map("<leader>kc", "<cmd>KotlinCleanWorkspace<CR>", "Kotlin: Clean LSP workspace")

			map("<leader>kj", function()
				require("kotlin.commands").export_workspace_to_json()
			end, "Kotlin: Export workspace to JSON")
		end,
	})
end

return M
