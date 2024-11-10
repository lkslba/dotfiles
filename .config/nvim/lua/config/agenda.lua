local M = {}

-- Constants and Configuration
local TAG_COLORS = {
	todo = "TodoTag", -- Blue
	toread = "ToreadTag", -- Purple
	tobuy = "TobuyTag", -- Green
	www = "WwwTag", -- Orange
	uni = "UniTag", -- Pink
}

local TASKS_FILE = vim.fn.expand("~/agenda/tasks.md")
local ARCHIVE_FILE = vim.fn.expand("~/agenda/archive.md")

local colors = {
	blue = "#6272A4",
	purple = "#BD93F9",
	green = "#50fa7b",
	orange = "#FFB86C",
	pink = "#FF79C6",
}

-- Utility Functions
local function get_timestamp()
	return os.date("%Y-%m-%d-%H%M")
end

local function extract_tags(line)
	local tags = {}
	for tag in line:gmatch("#(%w+)") do
		tags[tag] = true
	end
	return tags
end

local function extract_due_date(line)
	return line:match("due:(%d%d%d%d%-%d%d%-%d%d)")
end

local function setup_tag_highlights()
	vim.api.nvim_set_hl(0, "TodoTag", { fg = colors.blue, bold = true })
	vim.api.nvim_set_hl(0, "ToreadTag", { fg = colors.purple, bold = true })
	vim.api.nvim_set_hl(0, "TobuyTag", { fg = colors.green, bold = true })
	vim.api.nvim_set_hl(0, "WwwTag", { fg = colors.orange, bold = true })
	vim.api.nvim_set_hl(0, "UniTag", { fg = colors.pink, bold = true })
	vim.api.nvim_set_hl(0, "DefaultTag", { fg = colors.blue, bold = true })
end

-- Task Management Functions
local function sort_tasks_by_due_date()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local due_tasks = {}
	local no_due_tasks = {}

	for _, line in ipairs(lines) do
		if not line:match("^#") then -- Skip headers
			if line:match("^%s*-%s*%[.%]") then
				local due_date = extract_due_date(line)
				if due_date then
					table.insert(due_tasks, { date = due_date, line = line })
				else
					table.insert(no_due_tasks, line)
				end
			end
		end
	end

	table.sort(due_tasks, function(a, b)
		return a.date < b.date
	end)

	local result = { "# Tasks", "" }
	for _, task in ipairs(due_tasks) do
		table.insert(result, task.line)
	end
	if #due_tasks > 0 then
		table.insert(result, "")
	end
	for _, task in ipairs(no_due_tasks) do
		table.insert(result, task)
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
end

local function create_task()
	vim.ui.input({
		prompt = "Task description: ",
	}, function(desc)
		if not desc or desc == "" then
			return
		end

		vim.ui.input({
			prompt = "Tags (space-separated): ",
		}, function(tags)
			local task_line = "- [ ] " .. desc

			if tags and tags ~= "" then
				for tag in tags:gmatch("%S+") do
					task_line = task_line .. " #" .. tag
				end
			end

			vim.ui.input({
				prompt = "Due date (YYYY-MM-DD, optional): ",
			}, function(due)
				if due and due:match("^%d%d%d%d%-%d%d%-%d%d$") then
					task_line = task_line .. " due:" .. due
				end

				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				table.insert(lines, task_line)
				vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
				sort_tasks_by_due_date()
			end)
		end)
	end)
end

local function toggle_task()
	local line = vim.api.nvim_get_current_line()
	if not line:match("^%s*-%s*%[.%]") then
		return
	end

	if line:match("%[x%]") then
		-- Uncomplete task
		line = line:gsub("%[x%]", "[ ]")
		line = line:gsub(" done:%d%d%d%d%-%d%d%-%d%d%-%d%d%d%d", "")
		vim.api.nvim_set_current_line(line)
	else
		-- Complete task
		line = line:gsub("%[ %]", "[x]")
		line = line .. " done:" .. get_timestamp()

		-- Move to archive
		local archive_lines = vim.fn.readfile(ARCHIVE_FILE)
		local month_header = "## " .. os.date("%Y-%m")

		local month_found = false
		for i, archive_line in ipairs(archive_lines) do
			if archive_line == month_header then
				table.insert(archive_lines, i + 1, line)
				month_found = true
				break
			end
		end

		if not month_found then
			table.insert(archive_lines, month_header)
			table.insert(archive_lines, line)
		end

		vim.fn.writefile(archive_lines, ARCHIVE_FILE)

		-- Remove from current file
		local row = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_del_lines(0, row - 1, row, false)
	end
end

local function filter_by_tag()
	vim.ui.input({
		prompt = "Filter by tag: ",
	}, function(tag)
		if not tag or tag == "" then
			return
		end

		-- Create new split
		vim.cmd("vsplit")
		local buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_win_set_buf(0, buf)

		-- Read tasks file
		local lines = vim.fn.readfile(TASKS_FILE)
		local filtered = {
			"# Filtered Tasks - #" .. tag,
			"",
		}

		for _, line in ipairs(lines) do
			if line:match("#" .. tag) then
				table.insert(filtered, line)
			end
		end

		-- Set buffer content and options
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered)
		vim.bo[buf].modifiable = false
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].filetype = "markdown"

		-- Add keybinding to close the filter buffer
		vim.keymap.set("n", "q", ":q<CR>", { buffer = buf, silent = true })
	end)
end

local function list_tags()
	local lines = vim.fn.readfile(TASKS_FILE)
	local tags = {}

	for _, line in ipairs(lines) do
		for tag in line:gmatch("#(%w+)") do
			tags[tag] = true
		end
	end

	local tag_list = {}
	for tag in pairs(tags) do
		table.insert(tag_list, tag)
	end
	table.sort(tag_list)

	print("Available tags: " .. table.concat(tag_list, ", "))
end

-- Setup Function
function M.setup()
	-- Create files if they don't exist
	if vim.fn.filereadable(TASKS_FILE) == 0 then
		vim.fn.writefile({ "# Tasks", "" }, TASKS_FILE)
	end

	if vim.fn.filereadable(ARCHIVE_FILE) == 0 then
		vim.fn.writefile({ "# Archive", "", "## " .. os.date("%Y-%m"), "" }, ARCHIVE_FILE)
	end

	-- Setup highlights
	setup_tag_highlights()

	-- Key mappings
	vim.keymap.set("n", "<leader>ta", function()
		vim.cmd("edit " .. TASKS_FILE)
	end, { desc = "Open tasks" })
	vim.keymap.set("n", "<leader>tA", function()
		vim.cmd("edit " .. ARCHIVE_FILE)
	end, { desc = "Open archive" })
	vim.keymap.set("n", "<leader>tn", create_task, { desc = "New task" })
	vim.keymap.set("n", "<leader>tx", toggle_task, { desc = "Toggle task" })
	vim.keymap.set("n", "<leader>ts", sort_tasks_by_due_date, { desc = "Sort by due date" })
	vim.keymap.set("n", "<leader>tf", filter_by_tag, { desc = "Filter tasks by tag" })

	-- Commands
	vim.api.nvim_create_user_command("TaskTags", list_tags, {})

	-- Create autocommands
	local group = vim.api.nvim_create_augroup("TaskManagement", { clear = true })

	-- Sort on save
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = TASKS_FILE,
		group = group,
		callback = sort_tasks_by_due_date,
	})

	-- Set filetype and syntax
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = { TASKS_FILE, ARCHIVE_FILE },
		group = group,
		callback = function()
			vim.bo.filetype = "markdown"

			-- Custom syntax for tags
			for tag, hl_group in pairs(TAG_COLORS) do
				vim.cmd(string.format([[syntax match %s /#%s\>/]], hl_group, tag))
			end

			-- Match any other tag with default color
			vim.cmd([[syntax match DefaultTag /#\w\+/]])
			vim.cmd([[syntax sync fromstart]])
		end,
	})
end

return M
