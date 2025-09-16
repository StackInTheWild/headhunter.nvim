local M = {}

local conflicts = {}
local current_index = 0

local config = {
    keymaps = {
        next_conflict = "]g",
    },
} -- Parses git grep output (testable, can be called by tests)
function M._parse_conflicts(output)
    local conflicts = {}
    for line in output:gmatch("[^\r\n]+") do
        local file, lnum = line:match("^(.-):(%d+):<<<<<<< HEAD")
        if file and lnum then
            table.insert(conflicts, { file = file, lnum = tonumber(lnum) })
        end
    end
    return conflicts
end

-- Get all Git conflicts across tracked files
local function get_conflicts()
    local conflicts_list = {}
    local files = {}

    -- Get Git-tracked files (cross-platform)
    local handle = io.popen("git ls-files 2>nul") -- Windows-friendly
    if handle then
        local output = handle:read("*a")
        handle:close()
        for file in output:gmatch("[^\r\n]+") do
            table.insert(files, vim.fn.fnamemodify(file, ":p"))
        end
    end

    -- Scan each file for conflict markers
    for _, file in ipairs(files) do
        local ok, lines = pcall(vim.fn.readfile, file)
        if ok then
            local file_conflicts = M.parse_conflicts(file, lines)
            vim.list_extend(conflicts_list, file_conflicts)
        end
    end

    -- Sort by file and line number
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
    vim.keymap.set(
        "n",
        config.keymaps.next_conflict,
        M.next_conflict,
        { desc = "Next Git conflict" }
    )

    -- Commands
    vim.api.nvim_create_user_command(
        "HeadhunterNext",
        M.next_conflict,
        { desc = "Go to next Git conflict" }
    )
    vim.api.nvim_create_user_command("HeadhunterReload", function()
        package.loaded["headhunter"] = nil
        require("headhunter").setup()
    end, {})
end

-- Optional helper for tests
M._get_conflicts_mock = M._parse_conflicts

return M
