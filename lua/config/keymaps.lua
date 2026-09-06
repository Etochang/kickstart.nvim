-- ============================================================
-- CORE KEYMAPS
-- Mappings that do not belong to one specific plugin
-- ============================================================

-- Clear search highlighting without changing the search register.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Leave terminal mode with the same doubled Escape gesture used by many modal
-- terminal workflows. Some terminal multiplexers may intercept this sequence.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Move directly among splits with Ctrl+hjkl.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Match VS Code's Problems navigation and the keyboard's layer-2 encoder.
-- The diagnostic jump callback in options.lua opens the message at each stop.
vim.keymap.set('n', '<F8>', function() vim.diagnostic.jump { count = 1 } end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<S-F8>', function() vim.diagnostic.jump { count = -1 } end, { desc = 'Previous diagnostic' })

-- Neovim 0.12 ships an interactive undo-tree UI as an optional builtin plugin.
-- Loading it on demand avoids installing a third-party undo visualizer.
vim.keymap.set('n', '<leader>u', function()
  vim.cmd.packadd 'nvim.undotree'
  vim.cmd.Undotree()
end, { desc = 'Open [U]ndo tree' })
