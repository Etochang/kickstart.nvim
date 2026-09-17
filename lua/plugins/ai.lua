-- ============================================================
-- AI ASSISTANCE
-- File references for external CLI agents and local diff review
-- ============================================================

local function copy_reference(with_range)
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' or vim.bo.buftype ~= '' then
    vim.notify('Open a file before copying an agent reference', vim.log.levels.WARN)
    return
  end

  local reference = require('config.platform').relative_path(vim.fn.getcwd(), path)
  if with_range then
    local anchor, cursor = vim.fn.line 'v', vim.fn.line '.'
    reference = ('%s:%d-%d'):format(reference, math.min(anchor, cursor), math.max(anchor, cursor))
  end

  vim.fn.setreg('+', reference)
  local message = 'Copied: ' .. reference
  if vim.bo.modified then message = message .. ' (unsaved changes are not visible to the CLI; use :write first)' end
  vim.notify(message)
end

vim.keymap.set('n', '<leader>ac', function() copy_reference(false) end, {
  desc = '[A]I [C]opy file reference',
})
vim.keymap.set('x', '<leader>ac', function() copy_reference(true) end, {
  desc = '[A]I [C]opy selection reference',
})

vim.keymap.set('n', '<leader>ar', '<cmd>DiffviewOpen<CR>', {
  desc = '[A]I [R]eview changed files',
})
