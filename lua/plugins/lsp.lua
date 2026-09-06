-- ============================================================
-- LANGUAGE SERVER PROTOCOL
-- LSP behavior, server definitions, Mason installation, LSP mappings
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add {
  gh 'j-hui/fidget.nvim',
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

-- Fidget reports language-server startup and long-running progress without
-- requiring the command line to remain visible.
require('fidget').setup {}

-- Buffer-local LSP mappings exist only where they can do useful work.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local function map(keys, func, desc, mode) vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(detach_event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = detach_event.buf }
        end,
      })
    end

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle inlay [H]ints')
    end
  end,
})

-- Language servers provide definitions, references, actions, diagnostics, and
-- semantic knowledge. Formatters and linters are intentionally listed later as
-- separate tools; Stylua and Ruff are not LSP servers.
---@type table<string, vim.lsp.Config>
local servers = {
  clangd = {},
  pyright = {},
  lua_ls = {
    on_init = function(client)
      -- Formatting is delegated to Stylua through Conform.
      client.server_capabilities.documentFormattingProvider = false

      if client.workspace_folders then
        local workspace = client.workspace_folders[1].name
        local path = vim.fs.normalize(vim.uv.fs_realpath(workspace) or workspace)
        local config_root = vim.fn.stdpath 'config'
        config_root = vim.fs.normalize(vim.uv.fs_realpath(config_root) or config_root)
        local luarc = vim.fs.joinpath(path, '.luarc.json')
        local luarc_jsonc = vim.fs.joinpath(path, '.luarc.jsonc')
        if path ~= config_root and (vim.uv.fs_stat(luarc) or vim.uv.fs_stat(luarc_jsonc)) then return end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
        runtime = { version = 'LuaJIT' },
        workspace = { checkThirdParty = false },
      })
    end,
    settings = { Lua = { format = { enable = false } } },
  },
}

-- Mason installs external developer tools inside Neovim's data directory.
-- mason-lspconfig accepts LSP names, while mason-tool-installer accepts package
-- names for formatters and linters.
require('mason').setup {}
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = false,
}
require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua',
    'ruff',
    'clang-format',
    'markdownlint-cli2',
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
