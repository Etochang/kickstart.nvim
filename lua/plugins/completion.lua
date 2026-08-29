-- ============================================================
-- COMPLETION AND SNIPPETS
-- LuaSnip, community snippets, Blink, and Lua plugin completion
-- ============================================================

local gh = require('config.pack').gh

-- Dependencies are added before Blink so their Lua modules are on runtimepath
-- when Blink evaluates its snippet and LazyDev completion providers.
vim.pack.add {
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
  gh 'rafamadriz/friendly-snippets',
  gh 'folke/lazydev.nvim',
}
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }

-- LuaSnip handles expansion and navigation. friendly-snippets supplies a broad
-- VS Code-compatible library; project or personal snippets can extend it later.
require('luasnip').setup {}
require('luasnip.loaders.from_vscode').lazy_load()

-- LazyDev teaches LuaLS about required Neovim plugins without eagerly adding the
-- entire runtimepath to every Lua workspace.
require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

local blink = require 'blink.cmp'
blink.setup {
  keymap = {
    -- The default preset mirrors built-in insert completion: Ctrl+y accepts,
    -- Ctrl+n/p select, Ctrl+Space opens details, and Ctrl+k shows signatures.
    preset = 'default',
  },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { 'lazydev', 'lsp', 'copilot', 'path', 'snippets', 'buffer' },
    providers = {
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100,
      },
      -- Copilot requests are asynchronous, so ordinary LSP/path/snippet
      -- completion remains responsive while the network result is pending.
      copilot = {
        name = 'Copilot',
        module = 'blink-cmp-copilot',
        score_offset = 100,
        async = true,
      },
    },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
}

-- Advertise completion-item and snippet capabilities to every subsequently
-- configured language server.
vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() })
