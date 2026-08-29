--[[

=====================================================================
====================== MODULAR KICKSTART.NVIM =======================
=====================================================================

This configuration started from kickstart.nvim, but is split into small,
purpose-built modules so each part can be understood and changed independently.

Load order matters:
  1. `config.*` establishes editor behavior and the plugin-manager hooks.
  2. `plugins.*` installs and configures one workflow area per file.
  3. `custom.plugins` loads any personal additions from lua/custom/plugins/.

When adding a plugin, prefer the module matching its purpose. Keep plugin
dependencies in the same module and add dependencies before their consumers.

Useful commands:
  :Tutor                Learn Vim's editing model.
  :checkhealth          Diagnose Neovim and plugin integrations.
  :help <topic>         Read Neovim's excellent built-in documentation.
  :lua vim.pack.update()        Review and apply plugin updates.
  :lua vim.pack.update(nil, { offline = true })  Inspect plugin state offline.

--]]

-- Compile and cache Lua modules for faster subsequent startup.
vim.loader.enable()

-- Core editor behavior must be loaded before plugins so leaders, options,
-- mappings, diagnostics, and autocommands are available during plugin setup.
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- Register vim.pack build hooks before the first `vim.pack.add()` call.
require 'config.pack'

-- Each plugin module owns one coherent workflow. This explicit list makes the
-- startup order visible and avoids a hidden auto-discovery convention.
require 'plugins.ui'
require 'plugins.navigation'
require 'plugins.git'
require 'plugins.copilot'
require 'plugins.completion'
require 'plugins.lsp'
require 'plugins.formatting'
require 'plugins.treesitter'
require 'plugins.refactoring'
require 'plugins.debugging'
require 'plugins.testing'
require 'plugins.sessions'

-- Personal one-off plugins can live in lua/custom/plugins/*.lua. The loader is
-- intentionally last so custom modules may extend or override the base setup.
require 'custom.plugins'

-- vim: ts=2 sts=2 sw=2 et
