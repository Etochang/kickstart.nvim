-- ============================================================
-- DEBUGGING
-- DAP engine, adapter installation, debug UI, and lifecycle behavior
-- ============================================================

local gh = require('config.pack').gh

-- nvim-dap-ui requires nvim-nio at module load time. Add it in a separate call
-- before DAP UI so native vim.pack ordering cannot make the dependency invisible.
vim.pack.add { gh 'nvim-neotest/nvim-nio' }
vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'jay-babu/mason-nvim-dap.nvim',
}

local dap = require 'dap'
local dapui = require 'dapui'

-- Install adapters matching the configured Python and C/C++ language servers.
-- mason-nvim-dap uses adapter names (`python`, `codelldb`), translating them to
-- the corresponding Mason packages (`debugpy`, `codelldb`).
require('mason-nvim-dap').setup {
  ensure_installed = { 'python', 'codelldb' },
  automatic_installation = false,
  handlers = {},
}

dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- Open the UI when a session starts and close it after termination. The manual
-- toggle remains useful for inspecting the last session's output.
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle UI' })
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug [B]reakpoint' })
vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = '[D]ebug conditional [B]reakpoint' })
vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = '[D]ebug [R]EPL' })
vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[D]ebug [U]I' })
