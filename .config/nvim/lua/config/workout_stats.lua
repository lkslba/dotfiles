-- workout_stats.lua
local M = {}

-- Helper function to parse date from header
local function parse_date(header)
	return header:match("## (%d%d%d%d%-%d%d%-%d%d)")
end

-- Helper function to parse a workout table row
local function parse_exercise_row(line)
	local parts = vim.split(line:gsub("^|", ""):gsub("|$", ""), "|")
	if #parts >= 4 then
		return {
			exercise = vim.trim(parts[1]),
			sets = tonumber(vim.trim(parts[2])) or 0,
			reps = tonumber(vim.trim(parts[3])) or 0,
			weight = tonumber(vim.trim(parts[4])) or 0,
			notes = vim.trim(parts[5] or ""),
		}
	end
	return nil
end

-- Calculate volume for a single exercise entry
local function calculate_volume(exercise)
	return exercise.sets * exercise.reps * exercise.weight
end

-- Function to get all workout data
function M.get_workout_data()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local workouts = {}
	local current_date = nil
	local in_table = false

	for _, line in ipairs(lines) do
		-- Check for date header
		local date = parse_date(line)
		if date then
			current_date = date
			workouts[current_date] = workouts[current_date] or { exercises = {} }
			in_table = false
		-- Check for table header
		elseif line:match("^|%s*Exercise%s*|") then
			in_table = true
		-- Parse exercise rows
		elseif in_table and line:match("^|") and not line:match("^|%-") then
			local exercise = parse_exercise_row(line)
			if exercise and exercise.exercise ~= "" then
				table.insert(workouts[current_date].exercises, exercise)
			end
		-- Parse metadata
		elseif current_date and line:match("^%*%*") then
			local key, value = line:match("^%*%*([^:]+)%*%*:%s*(.+)")
			if key and value then
				workouts[current_date][key:lower()] = value
			end
		end
	end

	return workouts
end

-- Function to find PRs for each exercise
function M.find_prs()
	local workouts = M.get_workout_data()
	local prs = {}

	for date, workout in pairs(workouts) do
		for _, exercise in ipairs(workout.exercises) do
			local name = exercise.exercise
			prs[name] = prs[name] or {}

			-- Check for weight PR
			if not prs[name].weight or exercise.weight > prs[name].weight.value then
				prs[name].weight = {
					value = exercise.weight,
					date = date,
				}
			end

			-- Check for volume PR (weight * sets * reps)
			local volume = calculate_volume(exercise)
			if not prs[name].volume or volume > prs[name].volume.value then
				prs[name].volume = {
					value = volume,
					date = date,
				}
			end

			-- Check for reps PR
			if not prs[name].reps or exercise.reps > prs[name].reps.value then
				prs[name].reps = {
					value = exercise.reps,
					date = date,
				}
			end
		end
	end

	return prs
end

-- Function to generate exercise trends
function M.generate_trends()
	local workouts = M.get_workout_data()
	local trends = {}

	-- Sort dates
	local dates = vim.tbl_keys(workouts)
	table.sort(dates)

	-- Initialize trends for each exercise
	for _, workout in pairs(workouts) do
		for _, exercise in ipairs(workout.exercises) do
			local name = exercise.exercise
			trends[name] = trends[name]
				or {
					dates = {},
					weights = {},
					volumes = {},
					total_sets = 0,
					total_reps = 0,
				}
		end
	end

	-- Collect data points
	for _, date in ipairs(dates) do
		local workout = workouts[date]
		for _, exercise in ipairs(workout.exercises) do
			local name = exercise.exercise
			table.insert(trends[name].dates, date)
			table.insert(trends[name].weights, exercise.weight)
			table.insert(trends[name].volumes, calculate_volume(exercise))
			trends[name].total_sets = trends[name].total_sets + exercise.sets
			trends[name].total_reps = trends[name].total_reps + (exercise.sets * exercise.reps)
		end
	end

	return trends
end

-- Function to create a workout summary
function M.create_summary()
	local prs = M.find_prs()
	local trends = M.generate_trends()

	-- Generate summary markdown
	local summary = { "# Workout Statistics Summary", "", "## Personal Records", "" }

	for exercise, records in pairs(prs) do
		table.insert(summary, "### " .. exercise)
		if records.weight then
			table.insert(summary, string.format("- Weight PR: %.1f (%s)", records.weight.value, records.weight.date))
		end
		if records.volume then
			table.insert(summary, string.format("- Volume PR: %.1f (%s)", records.volume.value, records.volume.date))
		end
		if records.reps then
			table.insert(summary, string.format("- Reps PR: %d (%s)", records.reps.value, records.reps.date))
		end
		table.insert(summary, "")
	end

	table.insert(summary, "## Exercise Trends")
	table.insert(summary, "")

	for exercise, data in pairs(trends) do
		table.insert(summary, "### " .. exercise)
		table.insert(summary, string.format("- Total Sets: %d", data.total_sets))
		table.insert(summary, string.format("- Total Reps: %d", data.total_reps))

		-- Calculate average weight
		local sum = 0
		for _, weight in ipairs(data.weights) do
			sum = sum + weight
		end
		local avg = sum / #data.weights

		table.insert(summary, string.format("- Average Weight: %.1f", avg))
		table.insert(summary, "")
	end

	-- Create new buffer with summary
	vim.cmd("new")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, summary)
	vim.bo.modifiable = false
	vim.bo.buftype = "nofile"
	vim.bo.filetype = "markdown"
end

-- Add visualization of trends using a simple ASCII chart
function M.visualize_exercise(exercise_name)
	local trends = M.generate_trends()
	local data = trends[exercise_name]

	if not data then
		print("No data found for exercise: " .. exercise_name)
		return
	end

	-- Create ASCII chart of weight progression
	local chart = { "# Weight Progression for " .. exercise_name, "" }

	-- Find min and max for scaling
	local min_weight = math.huge
	local max_weight = 0
	for _, weight in ipairs(data.weights) do
		min_weight = math.min(min_weight, weight)
		max_weight = math.max(max_weight, weight)
	end

	-- Create chart
	local height = 10
	local width = math.min(#data.weights, 30)
	local scale = height / (max_weight - min_weight)

	for i = height, 1, -1 do
		local row = string.format("%3d |", min_weight + (i / scale))
		for j = 1, width do
			local weight = data.weights[j]
			local val = (weight - min_weight) * scale
			if val >= i then
				row = row .. "*"
			else
				row = row .. " "
			end
		end
		table.insert(chart, row)
	end

	-- Add x-axis
	local x_axis = "    +" .. string.rep("-", width)
	table.insert(chart, x_axis)

	-- Create new buffer with chart
	vim.cmd("new")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, chart)
	vim.bo.modifiable = false
	vim.bo.buftype = "nofile"
end

-- Add commands to the agenda module
function M.setup()
	-- Commands
	vim.api.nvim_create_user_command("WorkoutStats", M.create_summary, {})
	vim.api.nvim_create_user_command("WorkoutPRs", function()
		local prs = M.find_prs()
		-- Pretty print PRs
		print(vim.inspect(prs))
	end, {})
	vim.api.nvim_create_user_command("WorkoutVisualize", function(opts)
		M.visualize_exercise(opts.args)
	end, {
		nargs = 1,
		complete = function()
			local trends = M.generate_trends()
			return vim.tbl_keys(trends)
		end,
	})

	-- Add keymaps when in workout file
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*/agenda/wout.md",
		callback = function()
			vim.keymap.set("n", "<leader>ws", M.create_summary, { buffer = true, desc = "Show workout statistics" })
			vim.keymap.set("n", "<leader>wp", function()
				vim.cmd("WorkoutPRs")
			end, { buffer = true, desc = "Show PRs" })
		end,
	})
end

return M

