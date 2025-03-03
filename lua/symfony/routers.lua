local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

M.get_list = function()
  return vim.g.symfony_routers
end

local onEvent = function(j, code, signal)
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
    vim.g.symfony_routers = decoded
    utils.notify("Routers dumped")
  end, 0)
end

M.parseCollection = function()
  utils.clear_cmdline()
  if not config.is_valid() then
    return ""
  end
  -- check cache
  if vim.g.symfony_routers ~= nil then
    return ""
  end
  utils.notify("Routers dump starting...")
  local job = docker.job({ "debug:router", "--show-controllers", "--format=json" }, onEvent)
  if job == nil then
    vim.g.symfony_routers = ""
    return vim.g.symfony_routers
  end
  job:start()
end

M.refresh = function()
  vim.g.symfony_routers = nil
  M.parseCollection()
end

return M
