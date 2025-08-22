local symfony_ok, _ = pcall(require, "symfony")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local telescope = require("telescope")

local get_list = function()
  local list = {}
  local cmds = {}
  if symfony_ok then
    local commands = require("symfony.commands")
    cmds = commands.get_list()
  end
  for _, cmd in pairs(cmds.namespaces) do
    local ns_cmds = cmd.commands
    for _, c in pairs(ns_cmds) do
      local line = string.format("%s", c)
      table.insert(list, line)
    end
  end
  return list
end

local show = function()
  pickers
    .new({
      prompt_title = "Symfony Commands",
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
        end, { desc = "Insert command" })
        return true
      end,
    })
    :find()
end

-- Register as a Telescope extension
return telescope.register_extension({
  exports = {
    symfony_commands = show,
  },
})
