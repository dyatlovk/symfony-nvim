local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

M.get_list = function()
  return vim.g.symfony_containers
end

M.update_storage = function(val)
  vim.g.symfony_containers = val
end

M.clear_storage = function()
  M.update_storage(nil)
end

--- @param q string
--- @return table<string, any>
M.search = function(q)
  local results = {}
  local storage = M.get_list()
  for name, param in pairs(storage.definitions) do
    local line = name:find(q)
    if line then
      table.insert(results, { name, param })
    end
  end
  return results
end

M.find_one_by_name = function(name)
  local containers = vim.g.symfony_containers
  if type(containers) ~= "table" then
    return nil
  end
  for _name, container in pairs(containers.definitions) do
    if _name == name then
      container["name"] = _name
      return container
    end
  end
  return nil
end

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
    M.update_storage("")
    return
  end
  if vim.g.symfony_containers ~= nil then
    M.update_storage("")
    return
  end
  utils.notify("Containers dump starting...")
  local job = docker.job({ "debug:container", "--format=json" }, function(j, code, signal)
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
      M.update_storage("")
      return
    end
    local s = table.concat(item, "")
    vim.defer_fn(function()
      local decoded = vim.fn.json_decode(s)
      M.update_storage(decoded)
      utils.notify("Container dumped")
    end, 0)
  end)
  if job == nil then
    M.update_storage("")
    return
  end
  job:start()
end

M.refresh = function()
  M.clear_storage()
  M.parse()
end

return M
