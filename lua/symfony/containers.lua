local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

M.get_params = function()
  return vim.g.symfony_params
end

local _update_storage = function(val)
  vim.g.symfony_params = val
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
  _update_storage(nil)
  M.parse_params()
end

return M
