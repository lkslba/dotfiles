-- General Settings
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if uppercase present
vim.opt.hlsearch = true -- Highlight search results
vim.opt.wrap = false -- Don't wrap lines
vim.opt.breakindent = true -- Preserve indentation in wrapped text
vim.opt.tabstop = 4 -- Tab width
vim.opt.shiftwidth = 4 -- Indent width
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.termguicolors = true -- Enable 24-bit RGB color
vim.opt.showmode = false -- Don't Show mode, since its already in statusline
vim.opt.undofile = true -- save undo history
vim.opt.updatetime = 250 -- decrease update time
vim.opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.timeoutlen = 300 -- Decrease this value (default is 1000)
vim.opt.ttimeoutlen = 10 -- Time in milliseconds to wait for a key code sequence to complete
-- Basic styling settings
vim.opt.termguicolors = true -- Enable 24-bit RGB color
vim.opt.cursorline = true -- Highlight current line
vim.opt.showmatch = true -- Show matching brackets
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.fillchars:append({
	eob = " ", -- Remove ~ from end of buffer
	vert = "│", -- Solid line for vertical splits
})

-- Status line styling
vim.opt.laststatus = 2 -- Always show status line
vim.opt.showcmd = true -- Show command in bottom bar

-- Other visual improvements
vim.opt.list = true -- Show some invisible characters
vim.opt.listchars = {
	tab = "→ ",
	trail = "·",
	extends = "»",
	precedes = "«",
}

-- Line numbers styling
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.numberwidth = 4 -- Width of number column

-- Window styling
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current

-- Search styling
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Show search matches as you type

-- Add filetype detection
vim.filetype.add({
	extension = {
		frag = "glsl",
		vert = "glsl",
		glsl = "glsl",
		comp = "glsl",
	},
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Key Mappings
-- Basic syntax
-- vim.keymap.set({mode}, {lhs}, {rhs}, {opts})

-- Where:
-- {mode} = mode where mapping works ('n','i','v','x','s',etc or combinations)
-- {lhs} = left hand side, the key combination you press
-- {rhs} = right hand side, the command or keys to execute
-- {opts} = optional table of options- Basic syntax

vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = " "

-- Basic mappings
vim.keymap.set("n", "<leader>fs", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>Q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer", silent = true })

-- Close buffer without closing window
vim.keymap.set("n", "<leader>bk", ":bdelete<CR>", { desc = "KILL buffer", silent = true })

-- List all buffers and wait for selection
vim.keymap.set("n", "<leader>bb", ":buffers<CR>:buffer<Space>", { desc = "List buffers and switch" })

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- ZenMode:
vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { silent = true, desc = "Toggle Zen Mode" })

-- Basic autocommands
-- Create an autocommand group
local augroup = vim.api.nvim_create_augroup("custom_settings", { clear = true })

-- The parts:
-- 'custom_settings' : The name of the group (can be any name you choose)
-- { clear = true } : Clears any existing autocommands in this group

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	pattern = "*",
	callback = function()
		if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
			vim.fn.setpos(".", vim.fn.getpos("'\""))
		end
	end,
})

-- Clipboard
if vim.fn.has("clipboard") == 1 then
	-- use system clipboard
	vim.opt.clipboard:append("unnamedplus")
else
	print("No clipboad support available, pls install clipboard provider.")
end

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Theme
		{
			"Mofiqul/dracula.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				vim.cmd([[colorscheme dracula]])
			end,
		},

		-- Status line
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("lualine").setup({
					options = {
						theme = "dracula",
					},
				})
			end,
		},

		-- Git signs in gutter
		{
			"lewis6991/gitsigns.nvim",
			config = function()
				require("gitsigns").setup()
			end,
		},

		-- Indent guides
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			config = function()
				require("ibl").setup()
			end,
		},

		-- Auto pairs
		{
			"windwp/nvim-autopairs",
			config = function()
				require("nvim-autopairs").setup()
			end,
		},

		-- Better comments
		{
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
		},

		-- Which key (shows possible key combinations)
		{
			"folke/which-key.nvim",
			config = function()
				require("which-key").setup()
			end,
		},

		-- Better buffer/tab line
		{
			"akinsho/bufferline.nvim",
			version = "*",
			dependencies = "nvim-tree/nvim-web-devicons",
			config = function()
				require("bufferline").setup()
			end,
		},

		-- File explorer
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"MunifTanjim/nui.nvim",
			},
			config = function()
				require("neo-tree").setup()
			end,
		},

		-- Fuzzy finder
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.5",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
					cond = function()
						return vim.fn.executable("make") == 1
					end,
				},
				{ "nvim-telescope/telescope-ui-select.nvim" },
				{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
			},
			config = function()
				local telescope = require("telescope")

				telescope.setup({
					defaults = {
						path_display = { "truncate" },
						sorting_strategy = "ascending",
						layout_config = {
							horizontal = {
								prompt_position = "top",
							},
						},
					},
				})

				-- Enable telescope fzf native
				telescope.load_extension("fzf")

				-- Files and text search
				vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
				vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
				vim.keymap.set("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "Find word under cursor" })

				-- Buffers, help, commands
				vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
				vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })
				vim.keymap.set("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Find commands" })

				-- Search within config files
				vim.keymap.set("n", "<leader>fn", function()
					require("telescope.builtin").find_files({
						prompt_title = "Config Files",
						cwd = vim.fn.stdpath("config"),
						hidden = true,
					})
				end, { desc = "Find neovim config files" })

				-- Search in home directory
				vim.keymap.set("n", "<leader>fH", function()
					require("telescope.builtin").find_files({
						prompt_title = "Home Files",
						cwd = "~",
						hidden = true,
					})
				end, { desc = "Find files in home dir" })

				-- Recent files
				vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })

				-- Search in current buffer
				vim.keymap.set(
					"n",
					"<leader>/",
					"<cmd>Telescope current_buffer_fuzzy_find<cr>",
					{ desc = "Fuzzy search in current buffer" }
				)

				-- Git operations
				vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Search git commits" })
				vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Search git status" })
			end,
		},
		-- Citation management
		{
			"nvim-telescope/telescope-bibtex.nvim",
			dependencies = { "nvim-telescope/telescope.nvim" },
			config = function()
				require("telescope").load_extension("bibtex")
			end,
		},

		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"markdown",
						"markdown_inline", -- Important for inline elements
						"glsl",
					},
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = { "markdown" },
					},
				})
			end,
		},

		-- glsl support
		{
			"tikhomirov/vim-glsl",
			event = "BufRead",
			ft = { "glsl", "vert", "frag", "geom", "comp" },
		},
		-- LSP and formatting
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"williamboman/mason.nvim",
				"williamboman/mason-lspconfig.nvim",
				"stevearc/conform.nvim", -- Formatter
			},
			config = function()
				-- Mason setup
				require("mason").setup()
				require("mason-lspconfig").setup({
					ensure_installed = {
						"clangd", -- C/C++
						"lua_ls", -- Lua
						"pyright", -- Python
						"bashls", -- Shell scripting
						"html", -- HTML
						"cssls", -- CSS
						"ts_ls", -- JavaScript/TypeScript
					},
				})

				local lspconfig = require("lspconfig")
				local capabilities = require("cmp_nvim_lsp").default_capabilities()

				-- Lua
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
							telemetry = { enable = false },
						},
					},
				})

				-- C/C++
				lspconfig.clangd.setup({
					capabilities = capabilities,

					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
				})

				-- Python
				lspconfig.pyright.setup({
					capabilities = capabilities,
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				})

				-- Shell
				lspconfig.bashls.setup({
					capabilities = capabilities,
					filetypes = { "sh", "bash", "zsh" },
				})

				-- HTML
				lspconfig.html.setup({
					capabilities = capabilities,
					filetypes = { "html", "htmldjango" },
				})

				-- CSS
				lspconfig.cssls.setup({
					capabilities = capabilities,
				})

				-- JavaScript/TypeScript
				lspconfig.ts_ls.setup({
					capabilities = capabilities,
					init_options = {
						preferences = {
							disableSuggestions = false,
						},
					},
				})
				-- Setup formatting
				require("conform").setup({
					formatters_by_ft = {
						c = { "clang-format" },
						cpp = { "clang-format" },
						cuda = { "clang-format" },
						lua = { "stylua" },
						python = { "black" },
						javascript = { "prettier" },
						typescript = { "prettier" },
						json = { "prettier" },
						yaml = { "prettier" },
						html = { "prettier" },
						css = { "prettier" },
						markdown = { "prettier" },
					},
					-- Set up format-on-save
					format_on_save = {
						timeout_ms = 500,
						lsp_fallback = true,
					},
				})

				-- Add format keybinding
				vim.keymap.set("n", "<leader>F", function()
					require("conform").format()
				end, { desc = "Format file" })

				-- Basic LSP keymaps
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
				vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" })

				-- Diagnostic keymaps
				vim.keymap.set(
					"n",
					"<leader>dd",
					vim.diagnostic.open_float,
					{ desc = "Show diagnostic error messages" }
				)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
				vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

				-- Toggle diagnostic display
				vim.keymap.set("n", "<leader>td", function()
					if vim.diagnostic.is_disabled() then
						vim.diagnostic.enable()
						print("Diagnostics enabled")
					else
						vim.diagnostic.disable()
						print("Diagnostics disabled")
					end
				end, { desc = "Toggle diagnostics" })
			end,
		},

		-- completion
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-nvim-lua",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip") -- Add this line to require luasnip properly

				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-Space>"] = cmp.mapping.complete(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
						["<Tab>"] = cmp.mapping.select_next_item(),
						["<S-Tab>"] = cmp.mapping.select_prev_item(),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp", priority = 1000 },
						{ name = "nvim_lua", priority = 750 },
						{ name = "luasnip", priority = 500 },
						{ name = "buffer", priority = 250 },
						{ name = "path", priority = 250 },
					}),
					completion = {
						completeopt = "menu,menuone,noinsert",
					},
				})
			end,
		},

		-- Markdown support
		{
			"tadmccorkle/markdown.nvim",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			ft = "markdown", -- or 'event = "VeryLazy"'
			opts = {
				-- configuration here or empty for defaults
				-- Default settings
				mappings = {
					-- Toggle inline style with gs + key
					inline_surround_toggle = "gs", -- gs + i/b/s/c for italic/bold/strike/code
					inline_surround_toggle_line = "gss", -- same as above but for whole line
					inline_surround_delete = "ds", -- ds + i/b/s/c to remove style
					inline_surround_change = "cs", -- cs + i/b/s/c to change style

					-- Links
					link_add = "gl", -- Add link
					link_follow = "gx", -- Follow link under cursor

					-- Navigation
					go_curr_heading = "]c", -- Go to current heading
					go_parent_heading = "]p", -- Go to parent heading
					go_next_heading = "]]", -- Go to next heading
					go_prev_heading = "[[", -- Go to previous heading
				},

				-- Optional: Add some convenient keymaps
				on_attach = function(bufnr)
					local map = vim.keymap.set
					local opts = { buffer = bufnr }

					-- List operations
					map({ "n", "i" }, "<M-l><M-o>", "<Cmd>MDListItemBelow<CR>", opts)
					map({ "n", "i" }, "<M-L><M-O>", "<Cmd>MDListItemAbove<CR>", opts)

					-- Common formatting shortcuts for visual mode
					local function toggle(key)
						return "<Esc>gv<Cmd>lua require'markdown.inline'"
							.. ".toggle_emphasis_visual'"
							.. key
							.. "'<CR>"
					end
					map("x", "<C-b>", toggle("b"), opts) -- Bold
					map("x", "<C-i>", toggle("i"), opts) -- Italic
				end,
			},
		},

		-- Markdown Preview
		{
			"iamcco/markdown-preview.nvim",
			cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
			build = "cd app && yarn install",
			init = function()
				vim.g.mkdp_filetypes = { "markdown" }

				-- Configure markdown preview
				vim.g.mkdp_auto_close = 0 -- Don't auto-close preview window
				vim.g.mkdp_refresh_slow = 1 -- Refresh on save/leaving insert mode
				vim.g.mkdp_theme = "dark"
				vim.g.mkdp_preview_options = {
					disable_sync_scroll = 0,
					sync_scroll_type = "middle",
				}
			end,
			ft = { "markdown" },
		},

		{
			"folke/zen-mode.nvim",
			config = function()
				require("zen-mode").setup({
					window = {
						backdrop = 1,
						width = 120, -- width for text
						height = 1, -- maximize height
						options = {
							signcolumn = "no", -- disable signcolumn
							number = false, -- disable number column
							relativenumber = false, -- disable relative numbers
							cursorline = true, -- cursorline
							foldcolumn = "0", -- disable fold column
						},
					},
					plugins = {
						options = {
							enabled = true,
							ruler = false, -- disable ruler
							showcmd = false, -- disable showcmd
							laststatus = 0, -- disable status line
						},
						twilight = { enabled = false }, -- dimming other parts of the text

						kitty = {
							enabled = true,
							font = "+4", -- font size increment
						},
					},
				})
			end,
		},

		{
			-- For enhanced editing experience
			"MeanderingProgrammer/render-markdown.nvim",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-web-devicons", -- for code block icons
			},
			config = function()
				-- First define the highlight groups
				local colors = {
					cyan = "#8be9fd",
					green = "#50fa7b",
					orange = "#ffb86c",
					pink = "#ff79c6",
					purple = "#bd93f9",
					red = "#ff5555",
					yellow = "#f1fa8c",
					white = "#f8f8f2",
				}

				-- Set up heading foreground highlights (for icons and text)
				-- Heading colors (when not hovered over), extends through the entire line
				vim.cmd(string.format([[highlight Headline1Bg cterm=bold gui=bold guifg=%s guibg=NONE]], colors.pink))
				vim.cmd(string.format([[highlight Headline2Bg cterm=bold gui=bold guifg=%s guibg=NONE]], colors.purple))
				vim.cmd(string.format([[highlight Headline3Bg guifg=%s guibg=NONE]], colors.cyan))
				vim.cmd(string.format([[highlight Headline4Bg guifg=%s guibg=NONE]], colors.green))
				vim.cmd(string.format([[highlight Headline5Bg guifg=%s guibg=NONE]], colors.yellow))
				vim.cmd(string.format([[highlight Headline6Bg guifg=%s guibg=NONE]], colors.red))
				-- Highlight for the heading and sign icons (symbol on the left)
				-- I have the sign disabled for now, so this makes no effect
				vim.cmd(string.format([[highlight Headline1Fg cterm=bold gui=bold guifg=%s]], colors.pink))
				vim.cmd(string.format([[highlight Headline2Fg cterm=bold gui=bold guifg=%s]], colors.purple))
				vim.cmd(string.format([[highlight Headline3Fg cterm=bold gui=bold guifg=%s]], colors.cyan))
				vim.cmd(string.format([[highlight Headline4Fg cterm=bold gui=bold guifg=%s]], colors.green))
				vim.cmd(string.format([[highlight Headline5Fg cterm=bold gui=bold guifg=%s]], colors.yellow))
				vim.cmd(string.format([[highlight Headline6Fg cterm=bold gui=bold guifg=%s]], colors.red))
				require("render-markdown").setup({
					-- Customize based on preference
					heading = {
						enabled = true,
						-- Use iconic headings
						icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },

						backgrounds = {
							"Headline1Bg",
							"Headline2Bg",
							"Headline3Bg",
							"Headline4Bg",
							"Headline5Bg",
							"Headline6Bg",
						},
						foregrounds = {
							"Headline1Fg",
							"Headline2Fg",
							"Headline3Fg",
							"Headline4Fg",
							"Headline5Fg",
							"Headline6Fg",
						},
					},
					-- Enable code block styling
					code = {
						style = "full",
						-- Add icons for languages
						language_name = true,
					},
					-- Nice checkbox icons
					checkbox = {
						enabled = true,
						unchecked = {
							icon = "󰄱 ",
						},
						checked = {
							icon = "󰄲 ",
						},
					},
				})
			end,
		},
	},
	-- Install Settings:
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "dracula" } },
	-- Update Settings:
	-- automatically check for plugin updates
	checker = { enabled = true },
})

require("config.markdown").setup()
