-- ============================================================
-- AI COMPLETION BACKEND
-- GitHub Copilot client configured for presentation through Blink
-- ============================================================

local gh = require('config.pack').gh

-- copilot.lua manages authentication and the Copilot language server, while
-- blink-cmp-copilot translates its responses into normal Blink candidates.
-- Keep this module before plugins.completion in init.lua so the provider is on
-- runtimepath when Blink evaluates its source configuration.
vim.pack.add {
  gh 'zbirenbaum/copilot.lua',
  gh 'giuxtaposition/blink-cmp-copilot',
}

require('copilot').setup {
  -- Blink owns presentation and acceptance. Enabling Copilot's separate ghost
  -- text or panel at the same time can display competing suggestions.
  suggestion = { enabled = false },
  panel = { enabled = false },
}

-- Authentication is intentionally interactive and account-specific. After the
-- first installation, run `:Copilot auth`, then verify with `:Copilot auth info`.
