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
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

local get_list = function()
  local list = {}
  local commands = require("symfony.commands")
  local cmds = commands.get_list()
  for _, cmd in pairs(cmds.namespaces) do
    local ns_cmds = cmd.commands
    for _, c in pairs(ns_cmds) do
      local line = string.format("%s", c)
      table.insert(list, line)
    end
  end
  return list
end

local previewer_cmd = function(opts)
  return previewers.new_buffer_previewer({
    get_buffer_by_name = function(_, entry)
      return entry.id
    end,
    define_preview = function(self, entry, status)
      local module = require("symfony.commands")
      local cmd = module.find_by_name(entry.value)
      local value = { "echo" }
      if cmd["name"] ~= nil then
        local n = cmd["name"]
        table.insert(value, "name: " .. cmd["name"])
      else
        table.insert(value, "name: ")
      end
      if cmd["description"] ~= nil then
        table.insert(value, "\ndescription: " .. cmd["description"])
      else
        table.insert(value, "\ndescription: ")
      end
      if cmd["usage"] ~= nil then
        table.insert(value, "\nusage: " .. cmd["usage"][1])
      else
        table.insert(value, "\nusage: ")
      end
      if cmd["help"] ~= nil then
        table.insert(value, "\nhelp: " .. cmd["help"])
      else
        table.insert(value, "\nhelp: ")
      end
      putils.job_maker(value, self.state.bufnr, {
        value = entry.value,
        bufname = self.state.bufname,
        cwd = opts.cwd,
      })
    end,
  })
end

M.picker = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "Symfony Commands",
      finder = finders.new_table({
        results = get_list(),
      }),
      previewer = previewer_cmd(opts),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        map("i", "<CR>", function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if not selection then
            return false
          end
          actions.close(prompt_bufnr)
        end, { desc = "Insert command" })
        return true
      end,
    })
    :find()
end

return M
