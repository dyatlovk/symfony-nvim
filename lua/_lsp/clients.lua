local utils = require("symfony.utils")
local M = {}

--- @param name string
--- @return vim.lsp.Client|nil
M.get_client_by_name = function(name)
  local client = vim.lsp.get_client_by_id(0)
  for _, c in ipairs(vim.lsp.get_clients()) do
    if c.name == name then
      client = c
      break
    end
  end
  return client
end

--- Find one symbol by name
--- @param name string
--- @return table
M.filter_symbol_name = function(lsp_result, name)
  local found = {}
  for _, k in pairs(lsp_result) do
    local child = k["children"]
    for id, item in pairs(child) do
      if item["name"] == name then
        found = child[id]
      end
    end
  end
  return found
end

--- Find all symbols in current buffer
--- @param client_name string
--- @param q string
--- @return table
M.request_symbols = function(client_name)
  local client = M.get_client_by_name(client_name)
  if client == nil then
    return {}
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(0) }
  local result = client:request_sync("textDocument/documentSymbol", params, 1000, 0)

  if result.err ~= nil then
    return {}
  end

  if result.result == nil then
    return {}
  end

  -- Serialize result
  -- local lines = {}
  -- for line in vim.inspect(result.result):gmatch("[^\r\n]+") do
  --   table.insert(lines, line)
  -- end
  -- -- Create new buffer and window
  -- vim.cmd("vnew")
  -- local buf = vim.api.nvim_get_current_buf()
  -- -- Set lines in buffer
  -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  return result.result
end

return M
