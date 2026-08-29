-- ============================================================
-- CORE AUTOCOMMANDS
-- Small event-driven editor behaviors shared by all filetypes
-- ============================================================

-- Briefly highlight copied text. This gives visual confirmation that a yank
-- selected the intended region without changing registers or messages.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight text after yanking',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
