local M = {}

M.open = function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "single",
  }
  vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_keymap(buf, "t", "q", "<C-\\><C-n>:close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-n>:close<CR>", { noremap = true, silent = true })
end

return M
