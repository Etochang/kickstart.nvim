-- ============================================================
-- REFACTORING
-- Tree-sitter/LSP-powered extraction, inlining, and debug-print helpers
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add {
  gh 'lewis6991/async.nvim',
  gh 'ThePrimeagen/refactoring.nvim',
}

require('refactoring').setup {}

-- The selector exposes only operations supported by the current language and
-- selection, keeping the keymap surface small while retaining discoverability.
vim.keymap.set({ 'n', 'x' }, '<leader>rs', function() require('refactoring').select_refactor() end, { desc = '[R]efactor [S]elect' })
