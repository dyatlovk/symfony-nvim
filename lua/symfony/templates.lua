local M = {}

local tw = require("symfony.twig")
local config = require("symfony.config")

local last_hovered_path = nil

M.goTo = function(path)
  local absPath = tw.resolve_tpl_path(path)
  if absPath == nil then
    return
  end
  vim.cmd("edit " .. absPath)
end

M.setup = function()
  vim.api.nvim_create_autocmd("User", {
    pattern = "SymfonyTemplatePathHover",
    callback = function(path)
      local cleaned = path["data"]:gsub("'", "")
      last_hovered_path = cleaned
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "SymfonyTemplatePathLeave",
    callback = function()
      last_hovered_path = nil
    end,
  })
  local opts = config.options()
  vim.keymap.set("n", opts.mappings.twig.goTo, function()
    if last_hovered_path then
      M.goTo(last_hovered_path)
      last_hovered_path = nil
    end
  end, { desc = "Symfony goto template" })
end

return M
