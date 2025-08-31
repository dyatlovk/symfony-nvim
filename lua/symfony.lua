local config = require("symfony.config")
local routers = require("symfony.routers")
local containers = require("symfony.containers")
local commands = require("symfony.commands")
local params = require("symfony.params")
local twig = require("symfony.twig")
local icons = require("nvim-web-devicons")
local utils = require("symfony.utils")
local highlights = require("symfony.highlights")
local templates = require("symfony.templates")

local M = {}

M.refresh = function()
  commands.refresh()
  routers.refresh()
  containers.refresh()
  params.refresh()
  twig.refresh()
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

local function command(name, cmd, opts)
  vim.api.nvim_create_user_command(name, cmd, opts or {})
end

local function commands_setup()
  command("SymfonyRefresh", function()
    M.refresh()
  end)
  command("SymfonyParams", function()
    vim.cmd("Telescope symfony params")
  end)
  command("SymfonyRouters", function()
    vim.cmd("Telescope symfony routers")
  end)
  command("SymfonyCommands", function()
    vim.cmd("Telescope symfony commands")
  end)
  command("SymfonyContainers", function()
    vim.cmd("Telescope symfony containers")
  end)
  command("SymfonyVersion", function()
    local v = M.get_version(false)
    utils.notify(v)
  end)
  command("SymfonyTwig", function()
    vim.cmd("Telescope symfony twig")
  end)
end

local function telescope_setup()
  require("telescope").setup({
    extensions = {
      symfony = {
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            mirror = true,
            width = 0.9,
            height = 0.9,
            preview_cutoff = 0,
            preview_height = 0.5,
            prompt_position = "top",
          },
        },
      },
    },
  })
  require("telescope").load_extension("symfony")
end

M.init = function()
  highlights.setup()
  M.refresh()
  M.seticon()
  commands_setup()
  telescope_setup()
  templates.setup()
end

return M
