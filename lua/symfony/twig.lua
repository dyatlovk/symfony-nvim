local M = {}

local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local CACHE_VAR = vim.g.symfony_twig

M.cache_update = function(val)
  vim.g.symfony_twig = val
end

M.cache_clear = function()
  M.cache_update(nil)
end

M.get_list = function()
  return vim.g.symfony_twig
end

--- @param name string|nil
--- @return table<string, any>
M.filter_functions = function(name)
  local collection = M.get_list()
  if name == nil then
    return collection["functions"]
  end

  if type(collection) ~= "table" then
    return {}
  end

  local result = {}
  for _name, value in pairs(collection["functions"]) do
    local line = _name:find(name)
    if line then
      table.insert(result, { name = _name, data = value })
    end
  end

  return result
end

--- @param name string
--- @return table<string, table<string, any>>|nil
M.find_one_function = function(name)
  local found = M.filter_functions(name)
  if vim.tbl_count(found) == 0 then
    return nil
  end

  return found[1]
end

--- @param name string|nil
--- @return table<string, any>
M.filter_filters = function(name)
  local collection = M.get_list()
  if name == nil then
    return collection["filters"]
  end
  if type(collection) ~= "table" then
    return {}
  end

  local result = {}
  for _name, value in pairs(collection["filters"]) do
    local line = _name:find(name)
    if line then
      result[_name] = value
    end
  end
  return result
end

M.find_one_filter = function(name)
  local found = M.filter_filters(name)
  if vim.tbl_count(found) == 0 then
    return nil
  end

  for _name, value in pairs(found) do
    return { name = _name, data = value }
  end
end

--- @param name string|nil
--- @return table<string, any>
M.filter_globals = function(name)
  local collection = M.get_list()
  if name == nil then
    return collection["globals"]
  end
  if type(collection) ~= "table" then
    return {}
  end

  local result = {}
  for _name, value in pairs(collection["globals"]) do
    local line = _name:find(name)
    if line then
      result[_name] = value
    end
  end
  return result
end

M.find_one_global = function(name)
  local found = M.filter_globals(name)
  if vim.tbl_count(found) == 0 then
    return nil
  end

  for _name, value in pairs(found) do
    return { name = _name, data = value }
  end
end

--- @param name string|nil
--- @return table<string, table<string>>
M.filter_loader_paths = function(name)
  local collection = M.get_list()
  if name == nil then
    return collection["loader_paths"]
  end
  if type(collection) ~= "table" then
    return {}
  end
  local result = {}
  for _name, value in pairs(collection["loader_paths"]) do
    local line = _name:find(name)
    if line then
      result[_name] = value
    end
  end
  return result
end

M.find_one_loader_path = function(name)
  local found = M.filter_loader_paths(name)
  if vim.tbl_count(found) == 0 then
    return nil
  end

  for _name, value in pairs(found) do
    return { name = _name, data = value }
  end
end

--- Resolve the full path of a template by searching through loader paths.
--- @param name string
--- @return nil|string
M.resolve_tpl_path = function(name)
  local loader_paths = M.get_list()["loader_paths"]
  if loader_paths == nil then
    return nil
  end
  if utils.tableIsEmpty(loader_paths) then
    return nil
  end
  local root = vim.fn.getcwd() .. "/"
  for _, paths in pairs(loader_paths) do
    for _, p in pairs(paths) do
      local full_path = root .. p .. "/" .. name
      if utils.isFileExists(full_path) then
        return full_path
      end
    end
  end
  return nil
end

local async_job = function(j, code, signal)
  if code ~= 0 then
    M.cache_clear()
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
    M.cache_update(decoded)
    utils.notify("Twig dumped")
  end, 0)
end

M.parse = function()
  if not config.is_valid() then
    return
  end
  if CACHE_VAR ~= nil then
    return
  end
  utils.notify("Twig dump starting...")
  local job = docker.job({ "debug:twig", "--format=json" }, async_job)
  if job == nil then
    M.cache_clear()
    return
  end
  job:start()
end

M.refresh = function()
  M.cache_clear()
  M.parse()
end

return M
