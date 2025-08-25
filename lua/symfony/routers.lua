local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

--- Return cached routers
--- @return table<string, any>
M.get_list = function()
  return vim.g.symfony_routers
end

M.update_storage = function(val)
  vim.g.symfony_routers = val
end

M.clear_storage = function()
  M.update_storage({})
end

--- @param name string
--- @return table|nil
M.find_one_by_name = function(name)
  local collection = M.get_list()
  if type(collection) ~= "table" then
    return nil
  end

  for _name, router in pairs(collection) do
    if _name == name then
      router["name"] = _name
      return router
    end
  end
  return nil
end

--- Search by router name
--- @param q string
--- @return table<string, any>
M.search = function(q)
  local results = {}
  local storage = M.get_list()
  for name, router in pairs(storage) do
    local line = name:find(q)
    if line then
      table.insert(results, { name, router })
    end
  end
  return results
end

--- Filter by router name
--- @param name string
--- @return table<string, any>
M.filter_by_name = function(name)
  local result = {}
  local collection = M.get_list()
  if type(collection) ~= "table" then
    return result
  end
  result = M.search(name)
  return result
end

--- @private
local onEvent = function(j, code, signal)
  if code ~= 0 then
    M.clear_storage()
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
    M.clear_storage()
    return
  end
  local s = table.concat(item, "")
  vim.defer_fn(function()
    local decoded = vim.fn.json_decode(s)
    M.update_storage(decoded)
    utils.notify("Routers dumped")
  end, 0)
end

--- @private
local parseCollection = function()
  utils.clear_cmdline()
  if not config.is_valid() then
    M.clear_storage()
    return
  end
  utils.notify("Routers dump starting...")
  local job = docker.job({ "debug:router", "--show-controllers", "--format=json" }, onEvent)
  if job == nil then
    M.clear_storage()
    return
  end
  job:start()
end

M.refresh = function()
  M.clear_storage()
  parseCollection()
end

return M
