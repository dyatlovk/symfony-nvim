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
  'kirilldyatlov/symfony.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  },
}
```

Or with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'kirilldyatlov/symfony.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  }
}
```

## Configuration

Basic setup (add to your Neovim config):

```lua
local symfony = require('symfony')
symfony.setup({
  docker_container = 'your_container_name', -- Docker container name (if using Docker)
})
symfony.init()
local watcher = require('symfony.watcher')
watcher.watch({root .. "/config/", root .. "/src"})

```

- `bin`: Path to the Symfony console (default: `bin/console`)
- `php`: Path to the PHP binary (default: `/usr/bin/php`)
- `docker_container`: Name of the Docker container running Symfony (optional)
- `mapping`: Path mapping for Dockerized environments

## Usage

After installation and setup, the plugin provides commands and UI for:

- Listing and running Symfony console commands
- Viewing routes and controllers
- Inspecting container services and parameters

You can trigger the UI and features via Lua API or custom mappings. Example:

```lua
require('symfony').init()
```

## Dependencies

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
