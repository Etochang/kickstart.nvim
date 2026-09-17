-- ============================================================
-- MARKDOWN RENDERING
-- In-buffer presentation and side-by-side preview for docs
-- ============================================================

local gh = require('config.pack').gh

-- Tree-sitter provides Markdown structure and mini.icons supplies optional
-- code-block icons; both are initialized before this module in init.lua.
vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

-- Render ordinary Markdown buffers.
-- Normal mode presents the document while Insert mode exposes its source, so
-- reading and editing do not require separate buffers.
require('render-markdown').setup {
  file_types = { 'markdown' },
}

-- The side preview most closely matches VS Code's rendered Markdown pane. The
-- buffer toggle is faster when a separate split would consume too much space.
vim.keymap.set('n', '<leader>mp', '<cmd>RenderMarkdown preview<CR>', {
  desc = '[M]arkdown [P]review',
})
vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown buf_toggle<CR>', {
  desc = '[M]arkdown toggle [R]endering',
})
