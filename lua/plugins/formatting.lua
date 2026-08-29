-- ============================================================
-- FORMATTING AND LINTING
-- Conform applies edits; nvim-lint publishes non-LSP diagnostics
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add {
  gh 'stevearc/conform.nvim',
  gh 'mfussenegger/nvim-lint',
}

-- Conform applies formatter output as minimal edits, which preserves extmarks,
-- folds, cursor position, and other editor state better than replacing a buffer.
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local supported = { lua = true, python = true, c = true, cpp = true }
    if supported[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end
  end,
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_format' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
  },
}

vim.keymap.set(
  { 'n', 'v' },
  '<leader>f',
  function() require('conform').format { async = true, lsp_format = 'fallback' } end,
  { desc = '[F]ormat buffer or selection' }
)

-- Ruff complements Pyright with fast Python style/error diagnostics;
-- markdownlint-cli2 checks documentation. Both executables are installed by Mason.
local lint = require 'lint'
lint.linters_by_ft = {
  python = { 'ruff' },
  markdown = { 'markdownlint-cli2' },
}

local lint_group = vim.api.nvim_create_augroup('kickstart-lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_group,
  callback = function()
    -- Skip plugin/help buffers whose displayed Markdown is not an editable file.
    if vim.bo.modifiable and vim.bo.buftype == '' then lint.try_lint() end
  end,
})
