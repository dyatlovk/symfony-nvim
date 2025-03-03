local Job = require("plenary.job")
local config = require("symfony.config")
local utils  = require("symfony.utils")

local M = {}

M.job = function(args, ev)
  if not config.is_valid() then
    return nil
  end
  local opts = config.options()
  if opts == nil then
    return nil
  end
  local j = Job:new({
    command = "docker",
    args = {
      "exec",
      "-i",
      opts.docker_container,
      opts.bin,
    },
    on_exit = ev,
  })
  j.args = vim.list_extend(j.args, args)

  return j
end

return M
