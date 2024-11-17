-- markdown.lua
local M = {}

-- Helper function to create pandoc export commands
local function create_pandoc_command(name, defaults_file)
	local cmd = string.format("command! %s !pandoc '%%' -d %s -o '%%:r.pdf'", name, defaults_file)
	vim.cmd(cmd)
end

function M.setup()
	-- Create export commands
	create_pandoc_command("MarkdownExportAcademic", "~/.pandoc/defaults/academic.yaml")
	create_pandoc_command("MarkdownExportDefault", "~/.pandoc/defaults/default.yaml")
	create_pandoc_command("MarkdownExportModern", "~/.pandoc/defaults/modern.yaml")

	-- Create HTML export command
	vim.cmd([[
        command! MarkdownExportHTML !pandoc '%'
            \ --to html5
            \ --standalone
            \ --mathjax
            \ --highlight-style=pygments
            \ --css= markdown.css
            \ --bibliography=bibliography.bib
            \ --csl=chicago-author-date.csl
            \ -o '%:r.html'
    ]])

	-- Basic markdown settings
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.breakindent = true
			vim.opt_local.conceallevel = 2
			vim.opt_local.spell = false
			vim.opt_local.spelllang = "en_us"
			-- Folding settings
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt_local.foldenable = true
			vim.opt_local.foldlevel = 0
			vim.opt_local.foldtext = ""

			-- Keymaps for exports
			local opts = { silent = true, buffer = true }
			vim.keymap.set("n", "<leader>ma", ":MarkdownExportAcademic<CR>", opts)
			vim.keymap.set("n", "<leader>md", ":MarkdownExportDefault<CR>", opts)
			vim.keymap.set("n", "<leader>mm", ":MarkdownExportModern<CR>", opts)
			vim.keymap.set("n", "<leader>mh", ":MarkdownExportHTML<CR>", opts)

			-- Section navigation
			vim.keymap.set("n", "]]", ':lua require("markdown").goto_next_heading()<CR>', { buffer = true })
			vim.keymap.set("n", "[[", ':lua require("markdown").goto_prev_heading()<CR>', { buffer = true })

			-- Preview controls
			vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Start markdown preview" })
			vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { desc = "Stop markdown preview" })

			-- Use Enter to toggle folds in normal mode
			vim.keymap.set("n", "<tab>", "za", { buffer = true, desc = "Toggle fold" })
			-- Level-specific fold commands using space-m (markdown) prefix
			local opts = { buffer = true, silent = true }
			-- Set fold level commands (space-m-number)
			for i = 0, 6 do
				vim.keymap.set("n", string.format("<leader>m%d", i), function()
					vim.opt_local.foldlevel = i - 1
				end, vim.tbl_extend("force", opts, { desc = string.format("Fold to level %d", i) }))
			end

			-- Additional useful fold commands
			vim.keymap.set("n", "<leader>ma", "zR", vim.tbl_extend("force", opts, { desc = "Open all folds" }))
			vim.keymap.set("n", "<leader>mc", "zM", vim.tbl_extend("force", opts, { desc = "Close all folds" }))

			-- Format tables
			vim.keymap.set("n", "<leader>tf", ":TableFormat<CR>", { buffer = true })
		end,
	})
end

return M
