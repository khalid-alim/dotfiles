local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.wrap = true
opt.breakindent = true
opt.undofile = true
opt.swapfile = true
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

vim.keymap.set("n", ";", ":", { desc = "Command mode" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result centered" })
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

require("lazy").setup({
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-file-browser.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = { height = 0.85, width = 0.9 },
					path_display = { "smart" },
					mappings = { i = { ["<C-d>"] = require("telescope.actions").delete_buffer } },
				},
				extensions = {
					file_browser = { theme = "dropdown", hijack_netrw = true },
					["ui-select"] = require("telescope.themes").get_dropdown(),
				},
			})
			telescope.load_extension("fzf")
			telescope.load_extension("file_browser")
			telescope.load_extension("ui-select")
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader><leader>", builtin.builtin, { desc = "Telescope" })
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Find Git files" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
			vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search buffer" })
			vim.keymap.set("n", "<leader>?", builtin.live_grep, { desc = "Search project text" })
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
			vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find symbols" })
			vim.keymap.set("n", "<leader>fB", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })
		end,
	},
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.icons").setup()
			require("mini.pairs").setup()
			require("mini.surround").setup()
			require("mini.comment").setup()
			require("mini.diff").setup()
			require("mini.indentscope").setup({ symbol = "│" })
			require("mini.sessions").setup({ directory = vim.fn.expand("~/.local/state/nvim/sessions") })
			local clue = require("mini.clue")
			clue.setup({
				triggers = {
					{ mode = "n", keys = "<Leader>" },
					{ mode = "x", keys = "<Leader>" },
					{ mode = "n", keys = "g" },
					{ mode = "n", keys = "[" },
					{ mode = "n", keys = "]" },
					{ mode = "n", keys = "<C-w>" },
				},
				clues = { clue.gen_clues.g(), clue.gen_clues.windows(), clue.gen_clues.z() },
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			treesitter.setup({})
			local languages = {
				"bash",
				"csv",
				"git_config",
				"git_rebase",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
			}
			treesitter.install(languages)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = languages,
				callback = function()
					pcall(vim.treesitter.start)
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = { preset = "default", ["<CR>"] = { "accept", "fallback" } },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = true, auto_show_delay_ms = 250 } },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
			},
			format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
		},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft =
				{ python = { "ruff" }, sh = { "shellcheck" }, bash = { "shellcheck" }, zsh = { "shellcheck" } }
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
	{ "neovim/nvim-lspconfig" },
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({ contrast = "soft", transparent_mode = true })
			vim.cmd.colorscheme("gruvbox")
		end,
	},
}, {
	change_detection = { notify = false },
	rocks = { enabled = false },
})

local capabilities = require("blink.cmp").get_lsp_capabilities()
local servers = { "pyright", "ruff", "lua_ls", "bashls", "yamlls", "marksman" }
for _, server in ipairs(servers) do
	vim.lsp.config(server, { capabilities = capabilities })
	vim.lsp.enable(server)
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local map = function(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
		end
		map("K", vim.lsp.buf.hover, "Documentation")
		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gi", vim.lsp.buf.implementation, "Go to implementation")
		map("gr", require("telescope.builtin").lsp_references, "Find references")
		map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
	end,
})

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = true },
	virtual_text = { spacing = 2, source = "if_many" },
	underline = true,
})
