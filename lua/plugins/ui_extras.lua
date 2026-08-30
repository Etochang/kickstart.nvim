-- ============================================================
-- UI EXTRAS
-- Breadcrumbs, polished prompts, folds, minimap, delimiter depth
-- ============================================================

local gh = require('config.pack').gh

-- nvim-ufo uses promise-async internally. Load its dependency first so a fresh
-- vim.pack installation cannot expose UFO before the promise module exists.
vim.pack.add { gh 'kevinhwang91/promise-async' }
vim.pack.add {
  gh 'Bekaboo/dropbar.nvim',
  gh 'folke/snacks.nvim',
  gh 'HiPhish/rainbow-delimiters.nvim',
  gh 'kevinhwang91/nvim-ufo',
}

-- IDE-like breadcrumbs combine the file path with the current LSP or
-- Tree-sitter symbol. The menu supports keyboard selection and previews.
require('dropbar').setup {}
local dropbar = require 'dropbar.api'
vim.keymap.set('n', '<leader>;', dropbar.pick, { desc = 'Pick breadcrumb [S]ymbol' })
vim.keymap.set('n', '[;', dropbar.goto_context_start, { desc = 'Previous breadcrumb context' })
vim.keymap.set('n', '];', dropbar.select_next_context, { desc = 'Next breadcrumb context' })

-- Enable only the Snacks modules that fill gaps in this config. Telescope,
-- Yazi, indent-blankline, and mini.animate continue to own picking, files,
-- indentation, and scrolling respectively.
require('snacks').setup {
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = ' ', key = 'f', desc = 'Find file', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = ' ', key = 'g', desc = 'Find text', action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = ' ', key = 'r', desc = 'Recent files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = ' ', key = 's', desc = 'Restore session', action = function() require('persistence').load() end },
        { icon = ' ', key = 'c', desc = 'Edit config', action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })" },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    -- The stock startup section reads lazy.nvim statistics. This config uses
    -- vim.pack, so recent files and projects provide useful data instead.
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', limit = 5, indent = 2, padding = 1 },
      { icon = ' ', title = 'Projects', section = 'projects', limit = 5, indent = 2, padding = 1 },
    },
  },
  input = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  statuscolumn = {
    enabled = true,
    folds = { open = true, git_hl = false },
  },
}
vim.keymap.set('n', '<leader>nh', function() Snacks.notifier.show_history() end, { desc = '[N]otification [H]istory' })
vim.keymap.set('n', '<leader>nd', function() Snacks.notifier.hide() end, { desc = '[N]otifications [D]ismiss' })

-- UFO obtains accurate folds from the LSP and falls back to Tree-sitter.
-- Keeping every fold open initially avoids hiding code merely by opening it.
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.opt.fillchars:append {
  fold = ' ',
  foldopen = vim.g.have_nerd_font and '' or 'v',
  foldclose = vim.g.have_nerd_font and '' or '>',
  foldsep = ' ',
}

local ufo = require 'ufo'
ufo.setup {
  provider_selector = function(bufnr, filetype, buftype)
    if buftype ~= '' or filetype == 'bigfile' then return '' end

    -- UFO accepts a primary and one fallback provider. Pick only providers
    -- that can serve this buffer so unnamed buffers and uncommon filetypes do
    -- not produce rejected Tree-sitter requests during startup.
    local has_parser = pcall(vim.treesitter.get_parser, bufnr)
    for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
      if client:supports_method('textDocument/foldingRange', bufnr) then return has_parser and { 'lsp', 'treesitter' } or { 'lsp', 'indent' } end
    end
    return has_parser and { 'treesitter', 'indent' } or 'indent'
  end,
}
vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
vim.keymap.set('n', 'zK', ufo.peekFoldedLinesUnderCursor, { desc = 'Preview folded lines' })

-- A minimap is most useful on demand. It summarizes the buffer and overlays
-- search hits, diagnostics, and Gitsigns hunks without adding another plugin.
local minimap = require 'mini.map'
minimap.setup {
  integrations = {
    minimap.gen_integration.builtin_search(),
    minimap.gen_integration.diagnostic {
      error = 'DiagnosticFloatingError',
      warn = 'DiagnosticFloatingWarn',
      info = 'DiagnosticFloatingInfo',
      hint = 'DiagnosticFloatingHint',
    },
    minimap.gen_integration.gitsigns(),
  },
  window = {
    side = 'right',
    show_integration_count = true,
    width = 10,
    winblend = 20,
  },
}
vim.keymap.set('n', '<leader>mm', MiniMap.toggle, { desc = '[M]inimap toggle' })
vim.keymap.set('n', '<leader>mf', MiniMap.toggle_focus, { desc = '[M]inimap [F]ocus' })
vim.keymap.set('n', '<leader>ms', MiniMap.toggle_side, { desc = '[M]inimap [S]ide' })

-- Rainbow Delimiters starts automatically and uses Tree-sitter to color nested
-- brackets. Its highlight groups are themed alongside Kanagawa in plugins.ui.
