local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")
local ns = vim.api.nvim_create_namespace("symfony-hover")
local config = require("symfony.config")

--- Setup color highlights when cursor over the template path
local hoverColors = function()
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      -- dispatch leave event if line is empty
      local line = vim.api.nvim_get_current_line()
      if line:match("^%s*$") then
        vim.api.nvim_exec_autocmds("User", { pattern = "SymfonyTemplatePathLeave", modeline = false })
        return
      end

      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
      local node = ts_utils.get_node_at_cursor()
      if not node then
        return
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
      if lang == nil then
        return
      end
      local parser = vim.treesitter.get_parser(bufnr, lang)
      if parser == nil then
        return
      end
      local tree = parser:parse()[1]
      local root = tree:root()
      local query = vim.treesitter.query.get(lang, "highlights")
      if query == nil then
        return
      end
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      row = row - 1

      for id, n, _ in query:iter_captures(root, bufnr, row, row + 1) do
        local name = query.captures[id]
        if name == "TemplatePath" then
          local srow, scol, erow, ecol = n:range()
          if row >= srow and row <= erow and col >= scol and col <= ecol then
            vim.api.nvim_buf_add_highlight(bufnr, ns, "@TemplatePathHover", srow, scol, ecol)
            local hovered_text = vim.treesitter.get_node_text(n, bufnr)
            -- dispatch hover event if template path found
            vim.api.nvim_exec_autocmds(
              "User",
              { pattern = "SymfonyTemplatePathHover", modeline = false, data = hovered_text }
            )
          end
        end
      end
    end,
  })
end

local function darken(hex, factor)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  r = math.floor(r * factor)
  g = math.floor(g * factor)
  b = math.floor(b * factor)
  return string.format("#%02x%02x%02x", r, g, b)
end

--- Setup color highlights
local colorsGroup = function()
  local hl = vim.api.nvim_get_hl(0, { name = "comment" })
  local fg = hl.fg and string.format("#%06x", hl.fg) or "#ffffff"
  fg = darken(fg, 0.2)
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      vim.api.nvim_set_hl(0, "@Render", { italic = false, underline = false })
      vim.api.nvim_set_hl(0, "@TemplatePath", { italic = true, underline = false })
      vim.api.nvim_set_hl(0, "@TemplatePathHover", { italic = true, underline = true })
      vim.api.nvim_set_hl(0, "SymfonyUnderline", { fg = fg, underline = false })
    end,
  })
end

local function add_virtual_lines()
  local _ns = vim.api.nvim_create_namespace("symfony-virt-method")
  vim.api.nvim_buf_clear_namespace(0, _ns, 0, -1)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local win_width = vim.api.nvim_win_get_width(0)
  local dashes = string.rep("_", win_width)
  for i, line in ipairs(lines) do
    if line:match("^%s*[%w_]*%s*function%s+") then
      local target = i
      -- Move up past all contiguous attributes, comments, and blank lines
      while target > 1 do
        local prev = lines[target - 1]
        if
          prev:match("^%s*#%[")
          or prev:match("^%s*//")
          or prev:match("^%s*/%*")
          or prev:match("^%s*%*")
          or prev:match("^%s*$")
        then
          target = target - 1
        else
          break
        end
      end
      vim.api.nvim_buf_set_extmark(bufnr, _ns, target - 1, 0, {
        virt_lines = { { { dashes, "SymfonyUnderline" } } },
        virt_lines_above = true,
      })
    end
  end
end

M.setup = function()
  colorsGroup()
  hoverColors()
  if config.options().virtual_line then
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      pattern = "*.php",
      callback = add_virtual_lines,
    })
  end
end

return M
