local M = {}

local conflicts = {}
local current_index = 0

local config = {
	keymaps = {
		next_conflict = "]g",
	},
}

local function get_conflicts()
	local conflicts_list = {}
	local files = {}

	-- Try to get Git-tracked files first
	local handle = io.popen("git ls-files 2>nul")
	if handle then
		local output = handle:read("*a")
		handle:close()
		if output ~= "" then
			for file in output:gmatch("[^\r\n]+") do
				table.insert(files, vim.fn.fnamemodify(file, ":p"))
			end
		end
	end

	-- Scan each file for conflict markers
	for _, file in ipairs(files) do
		local ok, lines = pcall(vim.fn.readfile, file)
		if ok then
			for lnum, line in ipairs(lines) do
				if line:match("^%s*<<<<<<< ") then
					table.insert(conflicts_list, {
						file = vim.fn.fnamemodify(file, ":p"),
						lnum = lnum,
					})
				end
			end
		end
	end

	-- Sort conflicts by file and line number
	table.sort(conflicts_list, function(a, b)
		if a.file == b.file then
			return a.lnum < b.lnum
		end
		return a.file < b.file
	end)

	return conflicts_list
end

function M.next_conflict()
	conflicts = get_conflicts()
	current_index = 0

	if #conflicts == 0 then
		print("No conflicts found ✅")
		return
	end

	-- Move to the next conflict (wrap around)
	current_index = current_index + 1
	if current_index > #conflicts then
		current_index = 1
	end

	local conflict = conflicts[current_index]

	-- Open the file and jump to the line
	vim.cmd("edit " .. conflict.file)
	vim.api.nvim_win_set_cursor(0, { conflict.lnum, 0 })
end

function M.setup(user_config)
	-- Merge user config with defaults
	if user_config then
		for k, v in pairs(user_config) do
			config[k] = v
		end
	end

	-- Keymaps
	vim.keymap.set("n", config.keymaps.next_conflict, M.next_conflict, { desc = "Next Git conflict" })

	-- Commands
	vim.api.nvim_create_user_command("HeadhunterNext", M.next_conflict, { desc = "Go to next Git conflict" })
	vim.api.nvim_create_user_command("HeadhunterReload", function()
		package.loaded["headhunter"] = nil
		require("headhunter").setup()
	end, {})
end

return M
