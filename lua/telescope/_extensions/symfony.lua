local telescope = require("telescope")
local containers = require("telescope._extensions.symfony.containers")
local routers = require("telescope._extensions.symfony.routers")
local commands = require("telescope._extensions.symfony.commands")
local params = require("telescope._extensions.symfony.params")
local twig = require("telescope._extensions.symfony.twig")

local _options = {}

return telescope.register_extension({
  setup = function(ext, opt)
    _options = ext
  end,
  exports = {
    containers = function()
      containers.picker(_options)
    end,
    routers = function()
      routers.picker(_options)
    end,
    commands = function()
      commands.picker(_options)
    end,
    params = function()
      params.picker()
    end,
    twig = function()
      twig.picker(_options)
    end,
  },
})
