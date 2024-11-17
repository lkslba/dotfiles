local M = {}

-- Helper function to create pandoc export commands
local function create_pandoc_command(name, defaults_file)
	local cmd = string.format("command! %s !pandoc '%%' -d %s -o '%%:r.pdf'", name, defaults_file)
	vim.cmd(cmd)
end

-- Setup function for markdown configuration
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

	-- General markdown settings
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			-- Basic settings
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.breakindent = true
			vim.opt_local.conceallevel = 2 -- Hide markup
			vim.opt_local.concealcursor = "nc" -- Show markup when editing line

			-- Spell checking
			vim.opt_local.spell = false
			vim.opt_local.spelllang = "en_us"

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

			-- Task management (using markdown.nvim's native commands)
			-- Changed from ALT+c to leader+x for better compatibility
			--
			vim.keymap.set("n", "<leader>tx", toggle_task_with_timestamp, { buffer = true, desc = "Toggle task" })
			vim.keymap.set(
				"x",
				"<leader>tx",
				toggle_task_with_timestamp,
				{ buffer = true, desc = "Toggle task (visual)" }
			)

			vim.keymap.set("n", "<CR>", function()
				local line = vim.api.nvim_get_current_line()

				-- If it's a task line, toggle it
				if line:match("^%s*[-*+]%s+%[.%]") then
					-- Use your existing toggle function
					toggle_task_with_timestamp()
				else
					-- Normal Enter behavior for non-task lines
					-- Creates a new line below and enters insert mode
					vim.cmd("normal! o")
				end
			end, { buffer = true, desc = "Toggle task or new line" })

			vim.keymap.set("i", "<M-o>", function()
				local line = vim.api.nvim_get_current_line()
				-- If current line is a task
				if line:match("^%s*[-*+]%s+%[.%]") then
					-- Get the current line's indentation
					local indent = line:match("^%s*")
					local pos = vim.api.nvim_win_get_cursor(0)
					local row = pos[1]

					-- Insert new task with same indentation below current line
					vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. "- [ ] **TODO** " })

					-- Move cursor to end of new line
					vim.api.nvim_win_set_cursor(0, { row + 1, 99999 })
				else
					-- If not on a task line, just create a normal new line
					vim.cmd("normal! o")
				end
			end, { buffer = true, desc = "New TODO on Alt+o" })

			-- New task entry (changed from leader+t to leader+n for new task)
			vim.keymap.set("n", "<leader>td", "i- [ ] **TODO** <Esc>A", { buffer = true, desc = "New TODO" })
			vim.keymap.set("n", "<leader>tn", "i- [ ] <Esc>A", { buffer = true, desc = "New Checkbox" })

			vim.keymap.set("n", "<leader>tt", add_or_update_due_date, { buffer = true, desc = "Add/update due date" })

			-- List operations
			vim.keymap.set({ "n", "i" }, "<M-l><M-o>", "<Cmd>MDListItemBelow<CR>", { buffer = true })
			vim.keymap.set({ "n", "i" }, "<M-L><M-O>", "<Cmd>MDListItemAbove<CR>", { buffer = true })

			vim.keymap.set("n", "<leader>ta", archive_done_tasks, { desc = "Archive done tasks" })

			-- Format tables
			vim.keymap.set("n", "<leader>tf", ":TableFormat<CR>", { buffer = true })
		end,
	})

	-- Add auto-organization on save
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*.md",
		callback = function()
			-- Only organize if file contains "# Tasks" or similar header
			local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
			if content:match("^# Tasks") or content:match("\n# Tasks") then
				organize_tasks_by_deadline()
			end
		end,
	})
end

return M
