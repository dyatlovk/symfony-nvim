local symfony = require("symfony")
local uv = vim.loop
local timeout_ms = 1000 -- Set timeout in milliseconds
local timers = {}

local ignore_patterns = {
  "%.swp$", -- Vim swap files
  "%.tmp$", -- Temporary files
  "%~$", -- Backup files ending with '~'
  "%.bak$", -- Backup files
  "^%d+$",
}

local watchers = {}

local M = {}

-- Function to apply timeout per file
local function on_file_change(filename)
  if timers[filename] then
    timers[filename]:stop()
  end -- Stop any existing timer

  timers[filename] = uv.new_timer()
  timers[filename]:start(
    timeout_ms,
    0,
    vim.schedule_wrap(function()
      symfony.refresh()
    end)
  )
end

-- Function to check if a file should be ignored
local function should_ignore(filename)
  for _, pattern in ipairs(ignore_patterns) do
    if filename:match(pattern) then
      return true
    end
  end
  return false
end

-- Recursively scan directories and watch them
local function watch_directory(dir)
  local handle = uv.new_fs_event()
  if not handle then
    print("❌ Failed to create handle for:", dir)
    return
  end

  local success, err = uv.fs_event_start(handle, dir, { recursive = true }, function(err, filename, _)
    if err then
      print("❌ Error watching", dir, ":", err)
      return
    end
    if filename and not should_ignore(filename) then
      on_file_change(filename)
    end
  end)

  if success then
    table.insert(watchers, handle)
  else
    print("⚠️ Failed to start watching:", dir, err)
  end
end

-- Helper function to scan all subdirectories recursively
local function scan_and_watch(root)
  local function scan(dir)
    local dir_handle = uv.fs_scandir(dir)
    if not dir_handle then
      return
    end -- Skip if directory can't be opened

    watch_directory(dir) -- Watch the current directory

    while true do
      local name, type = uv.fs_scandir_next(dir_handle)
      if not name then
        break
      end -- No more files

      local full_path = dir .. "/" .. name
      if type == "directory" then
        scan(full_path) -- Recursively scan subdirectories
      end
    end
  end

  scan(root)
end

M.watch = function(dirs)
  for _, dir in ipairs(dirs) do
    scan_and_watch(dir)
  end
end

return M
