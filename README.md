# symfony.nvim

A Neovim plugin for enhanced Symfony (PHP framework) development. It provides interactive access to Symfony console commands, routes, and service container information, with Docker support and a modern UI.

## Features

- List and run Symfony console commands from within Neovim
- View and search Symfony routes and controllers
- Inspect service container services and parameters
- Docker integration: run commands inside a specified container
- Symfony icon support via [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

## Installation

Use your favorite Neovim plugin manager. Example with [lazy.nvim](https://github.com/folke/lazy.nvim):

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
-- watch for changes in config and src directories
-- will update routes, containers... automatically
local watcher = require('symfony.watcher')
watcher.watch({root .. "/config/", root .. "/src"})
```

## Api

```lua
local symfony = require('symfony')
local routers = require('symfony.routers')
local containers = require('symfony.containers')
local commands = require('symfony.commands')

-- Manual Refresh
commands.refresh()
routers.refresh()
containers.refresh()

-- Get info
local version = symfony.get_version()

-- Container list
local containers = containers.get_list()

-- Parameters list
local params = containers.get_params()

-- Routers list
local routers = routers.get_list()

-- Commands list
local commands = commands.get_list()
```

## Dependencies

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
