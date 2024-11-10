-- agenda.lua
local M = {}

-- Helper function to ensure agenda directory exists
local function ensure_agenda_dir()
	local home = os.getenv("HOME")
	local agenda_dir = home .. "/agenda"
	local handle = io.popen("mkdir -p " .. agenda_dir)
	if handle then
		handle:close()
	end
	return agenda_dir
end

-- Create or open agenda files
function M.open_todo()
	local agenda_dir = ensure_agenda_dir()
	vim.cmd("edit " .. agenda_dir .. "/todo.md")
end

function M.open_workout()
	local agenda_dir = ensure_agenda_dir()
	vim.cmd("edit " .. agenda_dir .. "/wout.md")
end

function M.open_journal()
	local agenda_dir = ensure_agenda_dir()
	local year = os.date("%Y")
	vim.cmd("edit " .. agenda_dir .. "/" .. year .. ".md")
end

-- Create a new workout entry
function M.new_workout_entry()
	local current_date = os.date("%Y-%m-%d")
	local template = {
		"## " .. current_date,
		"",
		"| Exercise | Sets | Reps | Weight | Notes |",
		"|----------|-------|------|---------|-------|",
		"| | | | | |",
		"",
		"**Duration**: ",
		"**Type**: ",
		"**Energy Level**: /5",
		"**Notes**: ",
		"",
		"---",
		"",
	}

	-- Insert at cursor position
	local line = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, line, line, false, template)
end

-- Create a new journal entry
function M.new_journal_entry()
	local current_date = os.date("%Y-%m-%d")
	local current_time = os.date("%H:%M")
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

	-- Search backwards from cursor for the most recent date header
	local date_line = nil
	for i = cursor_line, 0, -1 do
		if lines[i] and lines[i]:match("^## " .. current_date) then
			date_line = i
			break
		end
	end

	-- If we found current date header, search forward from it for a time header
	local time_exists = false
	if date_line then
		for i = date_line + 1, #lines do
			-- Stop searching if we hit another date header or the end
			if lines[i]:match("^## ") then
				break
			end
			-- Check for time header
			if lines[i]:match("^### " .. current_time) then
				time_exists = true
				break
			end
		end

		-- If current date exists but no matching time header, just add time and content
		if not time_exists then
			local template = {
				"### " .. current_time,
				"",
				"### Morning",
				"- Mood: ",
				"- Sleep Quality: /5",
				"- Dreams: ",
				"",
				"### Goals for Today",
				"- [ ] ",
				"",
				"### Notes",
				"",
				"### Evening Reflection",
				"- Accomplishments:",
				"- Challenges:",
				"- Grateful for:",
				"",
				"---",
				"",
			}
			vim.api.nvim_buf_set_lines(0, cursor_line, cursor_line, false, template)
		end
	else
		-- No current date header found, add everything
		local template = {
			"## " .. current_date,
			"",
			"### " .. current_time,
			"",
			"### Morning",
			"- Mood: ",
			"- Sleep Quality: /5",
			"- Dreams: ",
			"",
			"### Goals for Today",
			"- [ ] ",
			"",
			"### Notes",
			"",
			"### Evening Reflection",
			"- Accomplishments:",
			"- Challenges:",
			"- Grateful for:",
			"",
			"---",
			"",
		}
		vim.api.nvim_buf_set_lines(0, cursor_line, cursor_line, false, template)
	end
end
-- Setup function to initialize keymaps and commands
function M.setup()
	-- Create user commands
	vim.api.nvim_create_user_command("AgendaTodo", M.open_todo, {})
	vim.api.nvim_create_user_command("AgendaWorkout", M.open_workout, {})
	vim.api.nvim_create_user_command("AgendaJournal", M.open_journal, {})

	-- File-specific settings
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*/agenda/*.md",
		callback = function()
			local filename = vim.fn.expand("%:t")

			-- Common settings for all agenda files
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.breakindent = true
			vim.opt_local.conceallevel = 2

			-- File-specific settings
			if filename == "wout.md" then
				-- Workout file keymaps
				vim.keymap.set("n", "<leader>wn", M.new_workout_entry, { buffer = true, desc = "New workout entry" })

				-- Auto-format tables on save
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = 0,
					callback = function()
						vim.cmd("TableFormat")
					end,
				})
			elseif filename:match("^%d%d%d%d%.md$") then
				-- Journal file keymaps
				vim.keymap.set("n", "<leader>jn", M.new_journal_entry, { buffer = true, desc = "New journal entry" })
			end
		end,
	})

	-- Global keymaps for quick access
	vim.keymap.set("n", "<leader>at", M.open_todo, { desc = "Open agenda todo" })
	vim.keymap.set("n", "<leader>aw", M.open_workout, { desc = "Open agenda workout" })
	vim.keymap.set("n", "<leader>aj", M.open_journal, { desc = "Open agenda journal" })

	 -- Safely require workout_stats
         local ok, workout_stats = pcall(require, 'config.workout_stats')
         if ok then
         workout_stats.setup()
    end
end

return M
