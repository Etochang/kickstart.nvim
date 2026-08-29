-- ============================================================
-- TESTING AND TASKS
-- Neotest for test semantics; Overseer for builds and project commands
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add {
  gh 'nvim-neotest/neotest',
  gh 'nvim-neotest/neotest-python',
  gh 'orjangj/neotest-ctest',
  gh 'stevearc/overseer.nvim',
}

-- Neotest discovers tests structurally and provides nearest/file runs, output,
-- diagnostics, watch mode, a summary tree, and DAP-backed debugging. The Python
-- adapter supports both pytest and unittest and infers common virtualenv layouts.
local neotest = require 'neotest'
neotest.setup {
  adapters = {
    require 'neotest-python' { dap = { justMyCode = false } },
    require('neotest-ctest').setup { dap_adapter = 'codelldb' },
  },
}

vim.keymap.set('n', '<leader>tn', function() neotest.run.run() end, { desc = '[T]est [N]earest' })
vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand '%') end, { desc = '[T]est [F]ile' })
vim.keymap.set('n', '<leader>td', function() neotest.run.run { strategy = 'dap' } end, { desc = '[T]est [D]ebug nearest' })
vim.keymap.set('n', '<leader>ts', neotest.summary.toggle, { desc = '[T]est [S]ummary' })
vim.keymap.set('n', '<leader>to', function() neotest.output.open { enter = true } end, { desc = '[T]est [O]utput' })
vim.keymap.set('n', '<leader>tx', neotest.run.stop, { desc = '[T]est stop' })

-- Overseer manages asynchronous Make/npm/Cargo/VS Code and custom tasks. Task
-- output remains available in buffers and can publish parsed errors to diagnostics.
local overseer = require 'overseer'
overseer.setup {}
vim.keymap.set('n', '<leader>tR', '<cmd>OverseerRun<CR>', { desc = '[T]ask [R]un' })
vim.keymap.set('n', '<leader>tT', '<cmd>OverseerToggle<CR>', { desc = '[T]ask [T]oggle list' })
vim.keymap.set('n', '<leader>tl', function()
  local tasks = overseer.list_tasks { recent_first = true }
  if vim.tbl_isempty(tasks) then
    vim.notify('No recent Overseer task to restart', vim.log.levels.INFO)
    return
  end
  overseer.run_action(tasks[1], 'restart')
end, { desc = '[T]ask restart [L]ast' })
