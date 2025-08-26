local M = {}
local symfony_ok, _ = pcall(require, "symfony")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")
local utils = require("symfony.utils")
local lsp_client = require("_lsp.clients")

if not symfony_ok then
  error("Symfony plugin not loaded")
  return
end

local get_list = function()
  local list = {}
  local routes = {}
  local routers = require("symfony.routers")
  routes = routers.get_list()
  for name, _ in pairs(routes) do
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
      local module = require("symfony.routers")
      local router_info = module.find_one_by_name(entry.value)
      local value = { "echo" }
      if router_info["name"] ~= nil then
        table.insert(value, "name: " .. router_info["name"])
      else
        table.insert(value, "name: ")
      end
      if router_info["path"] ~= nil then
        table.insert(value, "\npath: " .. router_info["path"])
      else
        table.insert(value, "\npath: ")
      end
      if router_info["pathRegex"] ~= nil then
        table.insert(value, "\npathRegex: " .. router_info["pathRegex"])
      else
        table.insert(value, "\npathRegex: ")
      end
      if router_info["host"] ~= nil then
        table.insert(value, "\nhost: " .. router_info["host"])
      else
        table.insert(value, "\nhost: ")
      end
      if router_info["hostRegex"] ~= nil then
        table.insert(value, "\nhostRegex: " .. router_info["hostRegex"])
      else
        table.insert(value, "\nhostRegex: ")
      end
      if router_info["scheme"] ~= nil then
        table.insert(value, "\nscheme: " .. router_info["scheme"])
      else
        table.insert(value, "\nscheme: ")
      end
      if router_info["method"] ~= nil then
        table.insert(value, "\nmethod: " .. router_info["method"])
      else
        table.insert(value, "\nmethod: ")
      end
      if router_info["class"] ~= nil then
        table.insert(value, "\nclass: " .. router_info["class"])
      else
        table.insert(value, "\nclass: ")
      end
      if router_info["defaults"] ~= nil then
        local def = router_info["defaults"]
        table.insert(value, "\ndefaults:")
        if def["_controller"] ~= nil and type(def["_controller"]) ~= "table" then
          table.insert(value, "\n  controller: " .. def["_controller"])
        end
      end
      if router_info["requirements"] ~= nil then
        table.insert(value, "\nrequirements: " .. "[]")
      else
        table.insert(value, "\nrequirements: ")
      end
      putils.job_maker(value, self.state.bufnr, {
        value = entry.value,
        bufname = self.state.bufname,
        cwd = opts.cwd,
      })
    end,
  })
end

local function mappings(_, map)
  map("i", "<CR>", function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if not selection then
      return false
    end
    local router_name = selection[1]
    local module = require("symfony.routers")
    local router = module.get_controller_by_name(router_name)
    if utils.tableIsEmpty(router) then
      return false
    end
    local controller_ns = router[1]
    local controller_method = router[2]
    local path = module.resolve_namespace_path(controller_ns)
    -- TODO: Get current host dir from config
    local path_abs = vim.fn.getcwd() .. "/" .. path
    actions.close(prompt_bufnr)

    -- open controller in new buffer
    vim.cmd("edit " .. path_abs)

    -- goto method via lsp
    local symbols = lsp_client.request_symbols("phpactor")
    local symbol = lsp_client.filter_symbol_name(symbols, controller_method)
    local line_number = symbol["selectionRange"]["start"]["line"]
    vim.api.nvim_win_set_cursor(0, { line_number, 0 })
  end, { desc = "Goto controller" })
  return true
end

M.picker = function(opt)
  opt = opt or {}
  pickers
    .new(opt, {
      prompt_title = "Symfony Routers",
      finder = finders.new_table({
        results = get_list(),
      }),
      previewer = preview(opt),
      sorter = conf.generic_sorter({}),
      attach_mappings = mappings,
    })
    :find()
end

return M
