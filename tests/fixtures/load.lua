local M = {}

M.commands = function()
  local root = vim.fn.getcwd()
  local f = io.open(root .. "/tests/fixtures/commands.json", "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

M.command = function()
  local root = vim.fn.getcwd()
  local f = io.open(root .. "/tests/fixtures/command.json", "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

M.containers = function()
  local root = vim.fn.getcwd()
  local f = io.open(root .. "/tests/fixtures/containers.json", "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

M.params = function()
  local root = vim.fn.getcwd()
  local f = io.open(root .. "/tests/fixtures/params.json", "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

M.routers = function()
  local root = vim.fn.getcwd()
  local f = io.open(root .. "/tests/fixtures/routers.json", "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

M.twig = function()
  local root = vim.fn.getcwd()
  local f = io.open(root .. "/tests/fixtures/twig.json", "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

return M
