local M = {}

--- Load a JSON file and decode it
--- @param path string Relative path (with trailing slash) to the file
--- @return any
local load_json = function(path)
  local root = vim.fn.getcwd()
  local f = io.open(root .. path, "r")
  if f == nil then
    return
  end
  local content = f:read("*a")
  io.close(f)
  local decoded = vim.fn.json_decode(content)
  return decoded
end

M.commands = function()
  local path = "/tests/fixtures/commands.json"
  return load_json(path)
end

M.containers = function()
  local path = "/tests/fixtures/containers.json"
  return load_json(path)
end

M.params = function()
  local path = "/tests/fixtures/params.json"
  return load_json(path)
end

M.routers = function()
  local path = "/tests/fixtures/routers.json"
  return load_json(path)
end

M.twig = function()
  local path = "/tests/fixtures/twig.json"
  return load_json(path)
end

return M
