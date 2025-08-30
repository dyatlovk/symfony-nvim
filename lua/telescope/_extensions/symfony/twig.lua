local M = {}

local symfony_ok, _ = pcall(require, "symfony")
if not symfony_ok then
  error("Symfony plugin not loaded")
  return
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local twig = require("symfony.twig")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

local get_list = function()
  local list = {}
  local data = twig.get_list()
  for name, _ in pairs(data["functions"]) do
    table.insert(list, name)
  end
  return list
end

local previewer = function(opts)
  return previewers.new_buffer_previewer({
    get_buffer_by_name = function(_, entry)
      return entry.id
    end,
    define_preview = function(self, entry, status)
      local module = require("symfony.twig")
      local twig_info = module.find_one_function(entry.value)
      local value = { "echo" }
      if twig_info["name"] ~= nil then
        table.insert(value, "name: " .. twig_info["name"])
      else
        table.insert(value, "name: ")
      end
      if twig_info["data"] ~= nil then
        table.insert(value, "\nargs: ")
        if type(twig_info["data"]) == "table" then
          for _, v in pairs(twig_info["data"]) do
            table.insert(value, "\n - " .. v)
          end
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
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "Symfony Templates",
      finder = finders.new_table({
        results = get_list(),
      }),
      previewer = previewer(opts),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        return true
      end,
    })
    :find()
end

return M
