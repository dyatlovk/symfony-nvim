local M = {}

local symfony_ok, _ = pcall(require, "symfony")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

if not symfony_ok then
  error("Symfony plugin not loaded")
  return
end

local get_list = function()
  local list = {}
  local containers = {}
  if symfony_ok then
    local module = require("symfony.containers")
    containers = module.get_list()
  end
  for name, _ in pairs(containers.definitions) do
    local line = string.format("%s", name)
    table.insert(list, line)
  end
  return list
end

local preview = function(opts)
  return previewers.new_buffer_previewer({
    get_buffer_by_name = function(_, entry)
      return entry.id
    end,
    define_preview = function(self, entry, status)
      local module = require("symfony.containers")
      local container_info = module.find_one_by_name(entry.value)
      local value = { "echo" }
      if container_info["name"] ~= nil then
        table.insert(value, "name: " .. container_info["name"])
      else
        table.insert(value, "name: ")
      end
      if container_info["class"] ~= nil then
        table.insert(value, "\nclass: " .. container_info["class"])
      else
        table.insert(value, "\nclass: ")
      end
      if container_info["description"] ~= nil then
        table.insert(value, "\ndescription: " .. container_info["description"])
      else
        table.insert(value, "\ndescription: ")
      end
      if container_info["public"] ~= nil then
        table.insert(value, "\npublic: " .. tostring(container_info["public"]))
      else
        table.insert(value, "\npublic: ")
      end
      if container_info["synthetic"] ~= nil then
        table.insert(value, "\nsynthetic: " .. tostring(container_info["synthetic"]))
      else
        table.insert(value, "\nsynthetic: ")
      end
      if container_info["lazy"] ~= nil then
        table.insert(value, "\nlazy: " .. tostring(container_info["lazy"]))
      else
        table.insert(value, "\nlazy: ")
      end
      if container_info["shared"] ~= nil then
        table.insert(value, "\nshared: " .. tostring(container_info["shared"]))
      else
        table.insert(value, "\nshared: ")
      end
      if container_info["abstract"] ~= nil then
        table.insert(value, "\nabstract: " .. tostring(container_info["abstract"]))
      else
        table.insert(value, "\nabstract: ")
      end
      if container_info["autowire"] ~= nil then
        table.insert(value, "\nautowire: " .. tostring(container_info["autowire"]))
      else
        table.insert(value, "\nautowire: ")
      end
      if container_info["autoconfigure"] ~= nil then
        table.insert(value, "\nautoconfigure: " .. tostring(container_info["autoconfigure"]))
      else
        table.insert(value, "\nautoconfigure: ")
      end
      if container_info["deprecated"] ~= nil then
        table.insert(value, "\ndeprecated: " .. tostring(container_info["deprecated"]))
      else
        table.insert(value, "\ndeprecated: ")
      end
      if container_info["file"] ~= nil then
        table.insert(value, "\nfile: " .. tostring(container_info["file"]))
      else
        table.insert(value, "\nfile: ")
      end
      if container_info["tags"] ~= nil then
        table.insert(value, "\ntags:")
        for _, tag in ipairs(container_info["tags"]) do
          table.insert(value, "\n  name: " .. tag["name"])
        end
      end
      if container_info["usages"] ~= nil then
        table.insert(value, "\nusages:")
        for _, item in ipairs(container_info["usages"]) do
          table.insert(value, "\n  " .. item)
        end
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
  opt = opt or {}
  pickers
    .new(opts, {
      prompt_title = "Symfony Containers",
      finder = finders.new_table({
        results = get_list(),
      }),
      previewer = preview(opts),
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
