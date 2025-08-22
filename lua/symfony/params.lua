local utils = require("symfony.utils")
local config = require("symfony.config")
local docker = require("symfony.docker")

--- @class SymfonyParamTable: table<string, table|string>

local M = {}

--- @return SymfonyParamTable
M.get_list = function()
  return vim.g.symfony_params
end

--- @param val table|nil
M.update_storage = function(val)
  vim.g.symfony_params = val
end

M.clear_storage = function()
  M.update_storage(nil)
end

--- @param q string
--- @return table<string, any>
M.search = function(q)
  local results = {}
  local storage = M.get_list()
  for name, param in pairs(storage) do
    local line = name:find(q)
    if line then
      table.insert(results, { name, param })
    end
  end
  return results
end

--- @param q string
--- @return table|nil
M.find_one_by_name = function(name)
  local params = vim.g.symfony_params
  if type(params) ~= "table" then
    return nil
  end
  local result = {}
  for _name, param in pairs(params) do
    if _name == name then
      table.insert(result, { _name, param })
      return result
    end
  end
  return nil
end

--- @param name string
--- @return SymfonyParamTable
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
    M.clear_params_storage()
    return
  end
  if vim.g.symfony_params ~= nil then
    M.clear_params_storage()
    return
  end
  utils.notify("Parameters dump starting...")
  local job = docker.job({ "debug:container", "--parameters", "--format=json" }, function(j, code, signal)
    if code ~= 0 then
      M.clear_params_storage()
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
      M.clear_params_storage()
      return
    end
    local s = table.concat(item, "")
    vim.defer_fn(function()
      local decoded = vim.fn.json_decode(s)
      M.update_storage(decoded)
      utils.notify("Parameters dumped")
    end, 0)
  end)
  if job == nil then
    M.clear_params_storage()
    return
  end
  job:start()
end

M.refresh = function()
  M.clear_storage()
  M.parse()
end

return M
