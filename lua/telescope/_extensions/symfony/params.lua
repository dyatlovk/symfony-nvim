local M = {}

local symfony_ok, _ = pcall(require, "symfony")
if not symfony_ok then
  error("Symfony plugin not loaded")
  return
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local get_list = function()
  local list = {}
  local containers = require("symfony.params")
  local params = containers.get_list()
  for name, param in pairs(params) do
    local line = string.format("%-40s | %s", name, param)
    table.insert(list, line)
  end
  return list
end

M.picker = function()
  pickers
    .new({
      prompt_title = "Symfony Parameters",
      finder = finders.new_table({
        results = get_list(),
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        map("i", "<CR>", function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if not selection then
            return false
          end
          actions.close(prompt_bufnr)
        end, { desc = "Insert param" })
        return true
      end,
    })
    :find()
end

return M
