local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

M.update_storage = function(val)
  vim.g.symfony_commands = val
end

M.clear_storage = function()
  vim.g.symfony_commands = nil
end

M.get_list = function()
  return vim.g.symfony_commands
end

M.find_by_name = function(name)
  local commands = vim.g.symfony_commands
  if type(commands) ~= "table" then
    return nil
  end
  for _, command in pairs(commands.commands) do
    if command.name == name then
      return command
    end
  end
  return nil
end

--- @param q string
--- @return table<string, any>
M.search = function(q)
  local results = {}
  local storage = M.get_list()
  for _, param in pairs(storage.commands) do
    local line = param.name:find(q)
    if line then
      table.insert(results, { param.name, param })
    end
  end
  return results
end

--- @param name string
--- @return table<string, any>
M.filter_by_name = function(name)
  local result = {}
  local params = M.get_list()
  if type(params) ~= "table" then
    return result
  end

  result = M.search(name)

  return result
end

M.parse = function()
  utils.clear_cmdline()
  if not config.is_valid() then
    return
  end
  if vim.g.symfony_commands ~= nil then
    return
  end
  utils.notify("Commands dump starting...")
  local job = docker.job({ "list", "--format=json" }, function(j, code, signal)
    if code ~= 0 then
      M.update_storage("")
      return
    end
    local data = j:result()
    local item = {}
    for _, v in pairs(data) do
      if v ~= "" then
        table.insert(item, v)
      end
    end
    if utils.tableIsEmpty(item) then
      return
    end
    local s = table.concat(item, "")
    vim.defer_fn(function()
      local decoded = vim.fn.json_decode(s)
      M.update_storage(decoded)
      utils.notify("Commands dumped")
    end, 0)
  end)
  if job == nil then
    M.update_storage("")
    return
  end
  job:start()
end

M.refresh = function()
  M.update_storage(nil)
  M.parse()
end

return M
