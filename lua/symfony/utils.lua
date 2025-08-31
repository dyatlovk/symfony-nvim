local M = {}

M.dumpTable = function(t, indent)
  if not indent then
    indent = 0
  end -- Set default indentation level to 0
  local tableType = type(t)
  if tableType == "table" then
    for key, value in pairs(t) do
      local keyType = type(key)
      local valueType = type(value)

      -- Print key
      if keyType == "table" then
        print(string.rep(" ", indent) .. "[table]")
      elseif keyType == "string" then
        print(string.rep(" ", indent) .. '["' .. key .. '"] = ')
      else
        print(string.rep(" ", indent) .. "[" .. key .. "] = ")
      end

      -- Print value
      if valueType == "table" then
        print(string.rep(" ", indent + 2) .. "{")
        M.dumpTable(value, indent + 4)
        print(string.rep(" ", indent + 2) .. "}")
      elseif valueType == "string" then
        print(string.rep(" ", indent + 2) .. '"' .. value .. '"')
      else
        print(string.rep(" ", indent + 2) .. tostring(value))
      end
    end
  else
    print("Error: The provided argument is not a table!")
  end
end

M.tableMerge = function(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        M.tableMerge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

M.clear_cmdline = function()
  vim.defer_fn(function()
    vim.cmd("redraw!")
    vim.cmd("clear")
  end, 0)
end

M.notify = function(msg)
  M.clear_cmdline()
  -- vim.api.nvim_out_write("[Symfony] " .. msg .. "\n")
  -- vim.notify("[Symfony] " .. msg, vim.log.levels.INFO)
  -- vim.api.nvim_echo("[Symfony] " .. msg, true, {})
  vim.defer_fn(function()
    vim.api.nvim_echo({ { "[Symfony] " .. msg, "Comment" } }, true, {})
  end, 0)
end

M.echo = function(opts)
  if opts == nil or type(opts) ~= "table" then
    return
  end
  vim.api.nvim_echo(opts, false, {})
end

M.tableIsEmpty = function(t)
  return next(t) == nil
end

--- Check if a file exist
--- @param file string
--- @return boolean
M.isFileExists = function(file)
  local f = io.open(file, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

return M
