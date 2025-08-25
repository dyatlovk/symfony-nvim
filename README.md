# symfony.nvim

A Neovim plugin for enhanced Symfony (PHP framework) development. It provides interactive access to Symfony console commands, routes, and service container information, with Docker support.


## Demo

https://github.com/user-attachments/assets/ae1c28e7-f46e-4666-b2b7-6bce8f18c886


## Features

- List and run Symfony console commands from within Neovim
- View and search Symfony routes and controllers
- Inspect service container services and parameters
- Docker integration: run commands inside a specified container
- Symfony icon support via [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)


## Installation

Use your favorite Neovim plugin manager. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'dyatlovk/symfony-nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  },
}
```


Or with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'dyatlovk/symfony-nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  }
}
```


## Configuration

Basic setup (add to your Neovim config):

```lua
local root = vim.fn.getcwd()
local symfony = require('symfony')
symfony.setup({
  docker_container = 'your_container_name',
  mapping = {
    { "/var/www/", root },
  },
  php = "/usr/bin/php",
  bin = "bin/console",
})
symfony.init()
```

Setup watcher if you'd like to automatically refresh all data when src changes
```lua
-- Watch for changes in config and src directories.
-- The plugin will automatically update routes, containers, etc. when changes are detected.
local watcher = require('symfony.watcher')
watcher.watch({root .. "/config/", root .. "/src"})
```

Or you can bind for manual refresh

```lua
vim.keymap.set("n", "<leader>r", function() require("symfony").refresh()end, { desc = "Symfony refresh" })
vim.keymap.set("n", "<leader>rc", function() require("symfony.containers").refresh() end, { desc = "Symfony containers refresh" })
vim.keymap.set("n", "<leader>rr", function() require("symfony.routers").refresh() end, { desc = "Symfony routers refrehs" })
vim.keymap.set("n", "<leader>ro", function() require("symfony.commands").refresh() end, { desc = "Symfony commands refresh" })
vim.keymap.set("n", "<leader>rp", function() require("symfony.params").refresh() end, { desc = "Symfony params refresh" })
```


## How it works

All data is collected via Symfony console commands and stored in global variables during runtime.
When the watcher detects changes in source files, the plugin automatically refreshes the data and updates the global variables.


## API examples

Refresh data
```lua
local symfony = require('symfony')
local routers = require('symfony.routers')
local containers = require('symfony.containers')
local commands = require('symfony.commands')
local params = require('symfony.params')

-- Manual Refresh
commands.refresh()
routers.refresh()
containers.refresh()
params.refresh()
```

Get all dump
```lua
local cnt = require('symfony.containers')
--- @type table<string, any>
local list = ctn.get_list()
```

Search
```lua
local params = require('symfony.params')
--- @type table
local list = params.filter_by_name("kernel")

--- @type table|nil
local param = params.find_one_by_name("kernel.bild_dir")
```

## Dependencies

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
