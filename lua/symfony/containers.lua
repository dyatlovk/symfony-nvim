local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

M.get_params = function()
  return vim.g.symfony_params
end

M.get_containers = function()
  return vim.g.symfony_containers
end

local _update_storage = function(val)
  vim.g.symfony_params = val
end

M.parse_containers = function()
  utils.clear_cmdline()
  if not config.is_valid() then
    return vim.g.symfony_containers
  end
  if vim.g.symfony_containers ~= nil then
    return vim.g.symfony_containers
  end
  utils.notify("Containers dump starting...")
  local job = docker.job({ "debug:container", "--format=json" }, function(j, code, signal)
    if code ~= 0 then
      _update_storage("")
      return vim.g.symfony_containers
    end
    local data = j:result()
    local item = {}
    for _, v in pairs(data) do
      if v ~= "" then
        table.insert(item, v)
      end
    end
    if utils.tableIsEmpty(item) then
      vim.g.symfony_containers = ""
      return vim.g.symfony_containers
    end
    local s = table.concat(item, "")
    vim.defer_fn(function()
      local decoded = vim.fn.json_decode(s)
      vim.g.symfony_containers = decoded
      utils.notify("Container dumped")
    end, 0)
  end)
  if job == nil then
    vim.g.symfony_containers = ""
    return vim.g.symfony_containers
  end
  job:start()
end

M.parse_params = function()
  utils.clear_cmdline()
  if not config.is_valid() then
    return vim.g.symfony_params
  end
  if vim.g.symfony_params ~= nil then
    return vim.g.symfony_params
  end
  utils.notify("Parameters dump starting...")
  local job = docker.job({ "debug:container", "--parameters", "--format=json" }, function(j, code, signal)
    if code ~= 0 then
      _update_storage("")
      return vim.g.symfony_params
    end
    local data = j:result()
    local item = {}
    for _, v in pairs(data) do
      if v ~= "" then
        table.insert(item, v)
      end
    end
    if utils.tableIsEmpty(item) then
      _update_storage("")
      return vim.g.symfony_params
    end
    local s = table.concat(item, "")
    vim.defer_fn(function()
      local decoded = vim.fn.json_decode(s)
      _update_storage(decoded)
      utils.notify("Parameters dumped")
    end, 0)
  end)
  if job == nil then
    _update_storage("")
    return vim.g.symfony_params
  end
  job:start()
end

M.refresh = function()
  vim.g.symfony_params = nil
  vim.g.symfony_containers = nil
  M.parse_params()
  M.parse_containers()
end

return M
