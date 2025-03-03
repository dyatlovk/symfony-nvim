local utils = require("symfony.utils")
local M = {}

M.defaults = {
  bin = "bin/console",
  mapping = {
    { "/var/www/", vim.fn.getcwd() },
  },
  php = "/usr/bin/php",
  docker_container = nil,
}

M.get_storage = vim.g.symfony_options

--@param boolean
M.is_valid = function()
  if M.get_storage == nil then
    return false
  end
  if M.get_storage.docker_container == nil then
    return false
  end
  return true
end

M.options = function()
  if M.is_valid() then
    local merged = utils.tableMerge(M.defaults, M.get_storage)
    return merged
  end
  return M.get_storage
end

M.setup = function(opt)
  local merged = utils.tableMerge(M.defaults, opt)
  M.get_storage = merged
end

return M
