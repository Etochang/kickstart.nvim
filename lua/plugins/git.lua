-- ============================================================
-- GIT WORKFLOWS
-- Buffer hunks, repository operations, diffs, history, conflicts
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add {
  gh 'lewis6991/gitsigns.nvim',
  gh 'sindrets/diffview.nvim',
  gh 'NeogitOrg/neogit',
}

-- Gitsigns owns buffer-local Git information: changed-line signs, hunk actions,
-- inline previews, blame, and hunk text objects. Keep all setup in this one call
-- so a later setup does not silently replace the custom signs.
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'
    local function map(mode, lhs, rhs, description) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = description }) end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, 'Next Git change')
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, 'Previous Git change')

    map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Git [S]tage hunk')
    map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Git [R]eset hunk')
    map('n', '<leader>hs', gitsigns.stage_hunk, 'Git [S]tage hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Git [R]eset hunk')
    map('n', '<leader>hS', gitsigns.stage_buffer, 'Git [S]tage buffer')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'Git [R]eset buffer')
    map('n', '<leader>hp', gitsigns.preview_hunk, 'Git [P]review hunk')
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'Git preview hunk [I]nline')
    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, 'Git [B]lame line')
    map('n', '<leader>hd', gitsigns.diffthis, 'Git [D]iff against index')
    map('n', '<leader>hD', function() gitsigns.diffthis '@' end, 'Git [D]iff against last commit')
    map('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, 'Git hunks in repository')
    map('n', '<leader>hq', gitsigns.setqflist, 'Git hunks in buffer')
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle Git [B]lame')
    map('n', '<leader>tw', gitsigns.toggle_word_diff, '[T]oggle Git [W]ord diff')
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Git hunk text object')
  end,
}

-- Diffview handles repository-wide diffs, file history, and three-way conflict
-- resolution. Neogit delegates full-screen diff operations to it.
require('diffview').setup {}
vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff view' })
vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it file [H]istory' })

-- Neogit is the repository-level interface for staging, commits, branches,
-- rebases, stashes, worktrees, and other Git porcelain operations.
require('neogit').setup {
  integrations = { telescope = true, diffview = true },
}
vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { desc = 'Open Neo[g]it' })
