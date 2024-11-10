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

	-- TODO:
	-- Simplified todo states
	local todo_states = {
		"**TODO**", -- Not started
		"**IN PROGRESS**", -- Currently working on
		"**DONE**", -- Completed
	}
	local function toggle_task_with_timestamp()
		local line = vim.api.nvim_get_current_line()

		-- Check if it's a task line
		if not line:match("^%s*[-*+]%s+%[.%]") then
			return
		end

		if line:match("%[x%]") then
			-- If task is completed, uncomplete it
			line = line:gsub("%[x%]", "[ ]")
			-- Remove timestamp and DONE state if they exist
			line = line:gsub("%s*%(%d%d%d%d%-%d%d%-%d%d%)", "")
			line = line:gsub("%s*%*%*DONE%*%*", "")

			-- Restore TODO state if no other state exists
			if not line:match("%*%*[%u%s]+%*%*") then
				line = line:gsub("%[ %]", "[ ] **TODO** ")
			end
		else
			-- Complete the task
			line = line:gsub("%[ %]", "[x]")
			-- Add timestamp
			local timestamp = os.date("(%Y-%m-%d)")
			-- Replace any existing state with DONE
			if line:match("%*%*[%u%s]+%*%*") then
				line = line:gsub("%*%*[%u%s]+%*%*", "**DONE** " .. timestamp)
			else
				line = line:gsub("%[x%]", "[x] **DONE** " .. timestamp)
			end
		end

		vim.api.nvim_set_current_line(line)
	end
	-- Archive done tasks
	local function archive_done_tasks()
		-- Get all lines
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local done_tasks = {}
		local keep_lines = {}

		-- Separate done tasks and other lines
		for _, line in ipairs(lines) do
			if line:match("^%s*[-*+]%s+%[x%]") then
				table.insert(done_tasks, line)
			else
				table.insert(keep_lines, line)
			end
		end

		if #done_tasks == 0 then
			print("No completed tasks to archive")
			return
		end

		-- Find or create archive section
		local archive_found = false
		for i, line in ipairs(keep_lines) do
			if line:match("^# Archive") then
				archive_found = true
				-- Add done tasks after archive header
				for j, task in ipairs(done_tasks) do
					table.insert(keep_lines, i + j, task)
				end
				break
			end
		end

		-- If no archive section exists, create one
		if not archive_found then
			table.insert(keep_lines, "")
			table.insert(keep_lines, "# Archive")
			for _, task in ipairs(done_tasks) do
				table.insert(keep_lines, task)
			end
		end

		-- Update buffer
		vim.api.nvim_buf_set_lines(0, 0, -1, false, keep_lines)
	end

	local function organize_tasks_by_deadline()
		-- Get all lines
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

		-- Categories for tasks
		local overdue = {}
		local due_today = {}
		local due_next_7 = {}
		local no_date = {}
		local archived = {}
		local other_sections = {}
		local in_archive = false
		local current_section = other_sections

		-- Get today's date as string for comparison
		local today_str = os.date("%Y-%m-%d")
		local today_time = os.time()
		local end_of_week = today_time + (7 * 24 * 60 * 60)
		local in_other = false

		for _, line in ipairs(lines) do
			-- Check for Other section
			if line:match("^# Other") then
				in_other = true
				current_section = other_sections
			end

			-- Only process tasks if we're not in Other section or Archive
			if not in_other and not in_archive then
				if line:match("^#") then
					if line:match("^# Archive") then
						in_archive = true
						current_section = archived
					elseif
						not line:match("^# Tasks")
						and not line:match("^## Overdue")
						and not line:match("^## Due Today")
						and not line:match("^## Due Next 7")
						and not line:match("^## No Due Date")
					then
						current_section = other_sections
					end
					-- Skip the line if it's one of our deadline headers
					if
						not line:match("^# Tasks")
						and not line:match("^## Overdue")
						and not line:match("^## Due Today")
						and not line:match("^## Due Next 7")
						and not line:match("^## No Due Date")
					then
						table.insert(current_section, line)
					end
				-- Process tasks only if not in Other section
				elseif line:match("^%s*[-*+]%s+%[.%]") and not line:match("%[x%]") then
					-- Extract due date if it exists
					local due_date = line:match("DUE:%s+(%d%d%d%d%-%d%d%-%d%d)")

					if due_date then
						-- Convert date string to time
						local year, month, day = due_date:match("(%d%d%d%d)-(%d%d)-(%d%d)")
						local due_time = os.time({ year = year, month = month, day = day })

						if due_date < today_str then
							table.insert(overdue, line)
						elseif due_date == today_str then
							table.insert(due_today, line)
						elseif due_time <= end_of_week then
							table.insert(due_next_7, line)
						else
							table.insert(no_date, line)
						end
					else
						table.insert(no_date, line)
					end
				else
					table.insert(current_section, line)
				end
			else
				-- We're in Other or Archive section, just collect lines
				table.insert(current_section, line)
			end
		end

		-- Organize output
		local organized = {
			"# Tasks",
			"",
			"## Overdue",
		}

		-- Only add tasks if they exist
		if #overdue > 0 then
			for _, task in ipairs(overdue) do
				table.insert(organized, task)
			end
		end

		table.insert(organized, "")
		table.insert(organized, "## Due Today")

		if #due_today > 0 then
			for _, task in ipairs(due_today) do
				table.insert(organized, task)
			end
		end

		table.insert(organized, "")
		table.insert(organized, "## Due Next 7")

		if #due_next_7 > 0 then
			for _, task in ipairs(due_next_7) do
				table.insert(organized, task)
			end
		end

		table.insert(organized, "")
		table.insert(organized, "## No Due Date")

		if #no_date > 0 then
			for _, task in ipairs(no_date) do
				table.insert(organized, task)
			end
		end

		-- Add other sections
		if #other_sections > 0 then
			table.insert(organized, "")
			for _, line in ipairs(other_sections) do
				table.insert(organized, line)
			end
		end

		-- Add archive section if it exists
		if #archived > 0 then
			if archived[1] ~= "# Archive" then
				table.insert(organized, "")
				table.insert(organized, "# Archive")
			end
			for _, line in ipairs(archived) do
				table.insert(organized, line)
			end
		end

		-- Update buffer
		vim.api.nvim_buf_set_lines(0, 0, -1, false, organized)
	end
	local function add_or_update_due_date()
		local line = vim.api.nvim_get_current_line()
		if not line:match("^%s*[-*+]%s+%[.%]") then
			return
		end

		-- Get current timestamp for default value
		local default_date = os.date("%Y-%m-%d")

		-- If there's an existing due date, use it as default
		local current_date = line:match("DUE:%s+(%d%d%d%d%-%d%d%-%d%d)")

		-- Prompt for date with current/default date pre-filled
		vim.ui.input({
			prompt = "Due date (YYYY-MM-DD): ",
			default = current_date or default_date,
		}, function(input)
			if input then
				-- Validate date format
				if input:match("^%d%d%d%d%-%d%d%-%d%d$") then
					if current_date then
						-- Update existing due date
						line = line:gsub("DUE:%s+%d%d%d%d%-%d%d%-%d%d", "DUE: " .. input)
					else
						-- Add new due date
						line = line .. " DUE: " .. input
					end
					vim.api.nvim_set_current_line(line)
				else
					vim.notify("Invalid date format. Please use YYYY-MM-DD", vim.log.levels.ERROR)
				end
			end
		end)
	end

	-- Keymaps for exports
	local opts = { silent = true, buffer = true }
	vim.keymap.set("n", "<leader>ma", ":MarkdownExportAcademic<CR>", opts)
	vim.keymap.set("n", "<leader>md", ":MarkdownExportDefault<CR>", opts)
	vim.keymap.set("n", "<leader>mm", ":MarkdownExportModern<CR>", opts)
	vim.keymap.set("n", "<leader>mh", ":MarkdownExportHTML<CR>", opts)

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
