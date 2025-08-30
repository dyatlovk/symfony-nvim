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
  return load_json("/tests/fixtures/commands.json")
end

M.containers = function()
  return load_json("/tests/fixtures/containers.json")
end

M.params = function()
  return load_json("/tests/fixtures/params.json")
end

M.routers = function()
  return load_json("/tests/fixtures/routers.json")
end

M.twig = function()
  return load_json("/tests/fixtures/twig.json")
end

return M
