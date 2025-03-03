local docker = require("symfony.docker")
local utils = require("symfony.utils")
local icons = require("nvim-web-devicons")

local M = {}

-- @return string
M.get_version = function()
  -- utils.notify("Retrieving version...")
  if vim.g.symfony_ver then
    return vim.g.symfony_ver
  end
  local version = ""
  local job = docker.job({ "--version" }, function(j, code, signal)
    local output = table.concat(j:result(), "")
    version = string.match(output, "[0-9].+[0-9]") -- Extract the version
    vim.g.symfony_ver = version
  end)

  -- Start the job
  job:start()

  return version
end

M.get_version_icon = function()
  local numbers = M.get_version()
  local icon, _ = icons.get_icon("symfony")
  return icon .. " " .. numbers
end

return M
