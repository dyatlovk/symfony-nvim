local config = require("symfony.config")
local routers = require("symfony.routers")
local containers = require("symfony.containers")
local commands = require("symfony.commands")
local params = require("symfony.params")
local icons = require("nvim-web-devicons")

local M = {}

M.init = function()
  M.refresh()
  M.seticon()
end

M.refresh = function()
  commands.refresh()
  routers.refresh()
  containers.refresh()
  params.refresh()
end

-- @param with_icon boolean
M.get_version = function(with_icon)
  local v = commands.get_list()
  if v == nil then
    return ""
  end

  local version = v.application.version
  if with_icon == true then
    local icon, _ = icons.get_icon("symfony")
    version = icon .. " " .. version
  end

  return version
end

M.seticon = function()
  icons.set_icon({
    symfony = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "symfony",
    },
  })
end

M.setup = function(opt)
  config.setup(opt)
end

return M
