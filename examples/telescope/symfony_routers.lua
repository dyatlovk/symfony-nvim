local symfony_ok, _ = pcall(require, "symfony")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local telescope = require("telescope")

local get_list = function()
  local list = {}
  local routes = {}
  if symfony_ok then
    local routers = require("symfony.routers")
    routes = routers.get_list()
  end
  for name, route in pairs(routes) do
    local line = string.format(" %-40s | %s", name, route.path)
    table.insert(list, line)
  end
  return list
end

local show_routers = function()
  pickers
    .new({
      prompt_title = "Symfony Routers",
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
          local selected_text = selection[1]
          vim.api.nvim_put({ selected_text }, "", false, true)
        end, { desc = "Insert route" })
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    symfony_routers = show_routers,
  },
})
