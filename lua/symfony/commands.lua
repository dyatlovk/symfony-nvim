local utils = require("symfony.utils")
local docker = require("symfony.docker")
local config = require("symfony.config")

local M = {}

local _update_storage = function(val)
  vim.g.symfony_commands = val
end

M.get_list = function()
  return vim.g.symfony_commands
end

M.parse = function()
  utils.clear_cmdline()
  if not config.is_valid() then
    return vim.g.symfony_commands
  end
  if vim.g.symfony_commands ~= nil then
    return vim.g.symfony_commands
  end
  utils.notify("Commands dump starting...")
  local job = docker.job({ "list", "--format=json" }, function(j, code, signal)
    if code ~= 0 then
      _update_storage("")
      return vim.g.symfony_commands
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
      _update_storage(decoded)
      utils.notify("Commands dumped")
    end, 0)
  end)
  if job == nil then
    _update_storage("")
    return vim.g.symfony_commands
  end
  job:start()
end

M.refresh = function()
  _update_storage(nil)
  M.parse()
end

return M
