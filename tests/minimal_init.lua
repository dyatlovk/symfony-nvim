vim.o.swapfile = false
vim.bo.swapfile = false

local root = vim.fn.getcwd()
local package_root = root .. "/.tests/site/pack/deps/start/"

--- @param name string
local test_path = function(name)
  return root .. name
end

---@param plugin string
local load = function(plugin)
  local name = plugin:match(".*/(.*)")
  if not vim.loop.fs_stat(package_root .. name) then
    print("Installing " .. plugin)
    vim.fn.mkdir(package_root, "p")
    vim.fn.system({
      "git",
      "clone",
      "--depth=1",
      "https://github.com/" .. plugin .. ".git",
      package_root .. "/" .. name,
    })
  end
end

local setup = function()
  print("Setup runtime...")
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.opt.runtimepath:append(root)
  vim.opt.packpath = { test_path(".tests/site") }
  load("nvim-lua/plenary.nvim")
  load("nvim-tree/nvim-web-devicons")
  print("Setup ok")
end

setup()

local symfony = require("symfony")
symfony.setup({
  docker_container = "fake_container_name",
  mapping = {
    { "/var/www/", root },
  },
  php = "/usr/bin/php",
  bin = "bin/console",
})
