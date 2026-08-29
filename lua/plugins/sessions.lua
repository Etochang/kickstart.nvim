-- ============================================================
-- SESSION MANAGEMENT
-- Automatic project/branch saves with explicit, predictable restoration
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add { gh 'folke/persistence.nvim' }

-- Sessions are saved when at least one real buffer is open. Git branches receive
-- separate sessions, preventing feature-branch layouts from replacing each other.
require('persistence').setup {
  need = 1,
  branch = true,
}

-- Restoration is deliberately explicit: opening Neovim with a one-off file should
-- not unexpectedly replace it with a prior workspace.
vim.keymap.set('n', '<leader>qs', function() require('persistence').load() end, { desc = 'Restore current [S]ession' })
vim.keymap.set('n', '<leader>qS', function() require('persistence').select() end, { desc = '[S]elect session' })
vim.keymap.set('n', '<leader>ql', function() require('persistence').load { last = true } end, { desc = 'Restore [L]ast session' })
vim.keymap.set('n', '<leader>qd', function() require('persistence').stop() end, { desc = '[D]o not save session' })
