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

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave' }, {
  desc = 'Refresh files changed by external tools without overwriting unsaved edits',
  group = vim.api.nvim_create_augroup('kickstart-checktime', { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == '' and vim.fn.mode() == 'n' then vim.cmd.checktime() end
  end,
})
