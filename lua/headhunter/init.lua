local M = {}

local conflicts = {}
local current_index = 0

local defaultConfig = {
  register_keymaps = true,
  keymaps = {
    prev_conflict = "[g",
    next_conflict = "]g",
    take_head = "<leader>gh",
    take_origin = "<leader>go",
    take_both = "<leader>gb",
    populate_quickfix = "<leader>gq",
  },
}

-- Parses git grep output (testable, can be called by tests)
function M._parse_conflicts(output)
  local local_conflicts = {}
  for line in output:gmatch("[^\r\n]+") do
    local file, lnum = line:match("^(.-):(%d+):<<<<<<<")
    if file and lnum then
      table.insert(local_conflicts, { file = file, lnum = tonumber(lnum) })
    end
  end
  return local_conflicts
end

-- Parse lines in a file for conflicts (helper for get_conflicts)
function M.parse_conflicts(file, lines)
  local res = {}
  for i, line in ipairs(lines) do
    if line:match("^<<<<<<<") then
      table.insert(res, { file = file, lnum = i })
    end
  end
  return res
end

-- Get all Git conflicts across tracked files
function M._get_conflicts()
  local conflicts_list = {}
  local files = {}
  local seen_files = {}

  local handle = io.popen("git ls-files 2>nul")
  if handle then
    local output = handle:read("*a")
    handle:close()
    for file in output:gmatch("[^\r\n]+") do
      -- `git ls-files` shows one entry per index stage
      -- merges/stash conflicts only get scanned once here.
      if not seen_files[file] then
        seen_files[file] = true
        table.insert(files, vim.fn.fnamemodify(file, ":p"))
      end
    end
  end

  for _, file in ipairs(files) do
    local ok, lines = pcall(vim.fn.readfile, file)
    if ok then
      local file_conflicts = M.parse_conflicts(file, lines)
      vim.list_extend(conflicts_list, file_conflicts)
    end
  end

  table.sort(conflicts_list, function(a, b)
    if a.file == b.file then
      return a.lnum < b.lnum
    end
    return a.file < b.file
  end)

  return conflicts_list
end

local function build_quickfix_entries(conflicts_list)
  local entries = {}
  for _, conflict in ipairs(conflicts_list) do
    local bufnr = vim.fn.bufadd(conflict.file)
    table.insert(entries, {
      bufnr = bufnr,
      filename = vim.fn.fnamemodify(conflict.file, ":."),
      lnum = conflict.lnum,
      col = 1,
      text = "Merge conflict marker",
    })
  end
  return entries
end

-- Jump to next conflict
local function navigate_conflict(direction)
  conflicts = M._get_conflicts()

  if #conflicts == 0 then
    print("No conflicts found ✅")
    return
  end

  current_index = current_index + direction * 1
  if current_index > #conflicts then
    current_index = 1
  elseif current_index < 1 then
    current_index = #conflicts
  end

  local conflict = conflicts[current_index]
  vim.cmd("edit " .. conflict.file)
  vim.api.nvim_win_set_cursor(0, { conflict.lnum, 0 })
end

function M.populate_quickfix()
  local conflicts_list = M._get_conflicts()
  if #conflicts_list == 0 then
    vim.fn.setqflist({}, "r")
    print("No conflicts found ✅")
    return
  end

  local entries = build_quickfix_entries(conflicts_list)
  vim.fn.setqflist(entries, "r")
  vim.cmd("copen")
end

-- Jump to next conflict
function M.prev_conflict()
  navigate_conflict(-1)
end

-- Jump to next conflict
function M.next_conflict()
  navigate_conflict(1)
end

-- Extract conflict block (HEAD, ORIGIN)
local function get_conflict_block(bufnr, start_line)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, -1, false)
  local head_lines, origin_lines = {}, {}
  local mode = "head"

  local consumed = 0
  for _, line in ipairs(lines) do
    consumed = consumed + 1
    if line:match("^<<<<<<<") then
      mode = "head"
    elseif line:match("^=======") then
      mode = "origin"
    elseif line:match("^>>>>>>>") then
      break
    else
      if mode == "head" then
        table.insert(head_lines, line)
      else
        table.insert(origin_lines, line)
      end
    end
  end

  return head_lines, origin_lines, consumed
end

-- Replace conflict with resolution
local function apply_resolution(mode)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor[1]

  local head_lines, origin_lines, consumed =
      get_conflict_block(bufnr, start_line)

  local replacement = {}
  if mode == "head" then
    replacement = head_lines
  elseif mode == "origin" then
    replacement = origin_lines
  elseif mode == "both" then
    vim.list_extend(replacement, head_lines)
    vim.list_extend(replacement, origin_lines)
  end

  vim.api.nvim_buf_set_lines(
    bufnr,
    start_line - 1,
    start_line - 1 + consumed,
    false,
    replacement
  )
end

function M.take_head()
  apply_resolution("head")
end

function M.take_origin()
  apply_resolution("origin")
end

function M.take_both()
  apply_resolution("both")
end

function M._register_keymaps(config)
  vim.keymap.set(
    "n",
    config.keymaps.prev_conflict,
    M.prev_conflict,
    { desc = "Previous Git conflict" }
  )
  vim.keymap.set(
    "n",
    config.keymaps.next_conflict,
    M.next_conflict,
    { desc = "Next Git conflict" }
  )
  vim.keymap.set(
    "n",
    config.keymaps.take_head,
    M.take_head,
    { desc = "Take HEAD in conflict" }
  )
  vim.keymap.set(
    "n",
    config.keymaps.take_origin,
    M.take_origin,
    { desc = "Take ORIGIN in conflict" }
  )
  vim.keymap.set(
    "n",
    config.keymaps.take_both,
    M.take_both,
    { desc = "Take BOTH in conflict" }
  )
end

local config = vim.deepcopy(defaultConfig)

function M.setup(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end

  if config.register_keymaps then
    M._register_keymaps(config)
  end

  vim.api.nvim_create_user_command(
    "HeadhunterPrevious",
    M.prev_conflict,
    { desc = "Go to previous Git conflict" }
  )
  vim.api.nvim_create_user_command(
    "HeadhunterNext",
    M.next_conflict,
    { desc = "Go to next Git conflict" }
  )

  vim.api.nvim_create_user_command(
    "HeadhunterTakeHead",
    M.take_head,
    { desc = "Take changes from HEAD" }
  )
  vim.api.nvim_create_user_command(
    "HeadhunterTakeOrigin",
    M.take_origin,
    { desc = "Take changes from origin" }
  )
  vim.api.nvim_create_user_command(
    "HeadhunterTakeBoth",
    M.take_both,
    { desc = "Take both changes" }
  )

  vim.api.nvim_create_user_command(
    "HeadhunterQuickfix",
    M.populate_quickfix,
    { desc = "List Git conflicts in quickfix" }
  )

  vim.api.nvim_create_user_command("HeadhunterReload", function()
    package.loaded["headhunter"] = nil
    require("headhunter").setup()
  end, {})
end

M._get_conflicts_mock = M._parse_conflicts

return M
