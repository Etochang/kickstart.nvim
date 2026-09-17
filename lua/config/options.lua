-- ============================================================
-- CORE OPTIONS
-- Leaders, editing behavior, display, diagnostics, indentation
-- ============================================================

-- Set leaders before any plugin creates mappings. Space keeps leader-based
-- commands comfortable and leaves backslash available for local conventions.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set this to false if the selected terminal font does not contain Nerd Font
-- glyphs. Plugins use it to decide whether icons are safe to display.
vim.g.have_nerd_font = true

-- Line numbers: absolute for the current line and relative elsewhere make both
-- line references and count-based motions convenient.
vim.o.number = true
vim.o.relativenumber = true

-- Mouse support is useful for resizing splits and interacting with occasional
-- plugin UIs without changing the keyboard-first editing workflow.
vim.o.mouse = 'a'

-- The statusline already displays the current mode.
vim.o.showmode = false

-- Clipboard detection can slow startup, so defer it until the UI is ready.
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

vim.o.breakindent = true
vim.o.undofile = true -- Persist undo history between editing sessions.
vim.o.autoread = true

-- Ignore case unless the search contains an uppercase character or `\C`.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep diagnostic, Git, and DAP signs from shifting the text horizontally.
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

-- Make invisible whitespace visible without overwhelming normal text.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions while typing and keep useful context around the cursor.
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10

-- Ask before abandoning modified buffers instead of failing with a terse error.
vim.o.confirm = true

-- Four spaces is a conservative default for new files. guess-indent.nvim and
-- EditorConfig can override these buffer-locally for existing projects.
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

-- Sort severe diagnostics first and keep details available without filling the
-- screen with virtual lines. Jumping to a diagnostic opens its complete message.
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}
