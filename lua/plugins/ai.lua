-- ============================================================
-- AI ASSISTANCE
-- CodeCompanion chat, inline transformations, and Copilot CLI agent
-- ============================================================

local gh = require('config.pack').gh

-- CodeCompanion changes quickly, so remain within the current major release.
-- Plenary, Tree-sitter, Telescope, Blink, and copilot.lua are loaded by earlier
-- modules and provide the integrations CodeCompanion uses here.
vim.pack.add {
  {
    src = gh 'olimorris/codecompanion.nvim',
    version = vim.version.range '19.*',
  },
}

require('codecompanion').setup {
  interactions = {
    -- Ordinary chat and inline requests reuse the existing copilot.lua login.
    -- The more powerful CLI agent is started only by the explicit mapping below.
    chat = { adapter = 'copilot' },
    inline = { adapter = 'copilot' },
    cmd = { adapter = 'copilot' },
  },
  display = {
    action_palette = { provider = 'telescope' },
  },
}

-- The action palette is the discovery surface for built-in prompts such as
-- explain, fix, tests, diagnostics, and commit-message generation.
vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<CR>', {
  desc = '[A]I [A]ctions',
})

-- Regular Copilot chat is intentionally separate from the ACP agent. It is a
-- good fit for questions and constrained advice that should not modify a project.
vim.keymap.set({ 'n', 'v' }, '<leader>ac', '<cmd>CodeCompanionChat Toggle<CR>', {
  desc = '[A]I toggle [C]hat',
})
vim.keymap.set({ 'n', 'v' }, '<leader>an', '<cmd>CodeCompanionChat<CR>', {
  desc = '[A]I [N]ew chat',
})

-- Inline requests operate on a visual selection and present an editable diff.
-- A selection can instead be attached to the current chat for a longer exchange.
vim.keymap.set('v', '<leader>ai', '<cmd>CodeCompanion<CR>', {
  desc = '[A]I [I]nline edit',
})
vim.keymap.set('v', '<leader>as', '<cmd>CodeCompanionChat Add<CR>', {
  desc = '[A]I add [S]election to chat',
})

-- Start GitHub Copilot CLI through its Agent Client Protocol server. This mode
-- may read/write files and request commands, subject to Copilot's approvals.
vim.keymap.set('n', '<leader>aA', function()
  if vim.fn.executable 'copilot' ~= 1 then
    vim.notify('Copilot CLI is not installed or not on PATH', vim.log.levels.WARN)
    return
  end
  vim.cmd 'CodeCompanionChat adapter=copilot_acp'
end, { desc = '[A]I Copilot [A]gent' })

-- Collect the files changed by the current conversation into the quickfix list
-- for a first review; Diffview remains the final repository-wide review tool.
vim.keymap.set('n', '<leader>ar', '<cmd>CodeCompanionChat Changes<CR>', {
  desc = '[A]I [R]eview changed files',
})
