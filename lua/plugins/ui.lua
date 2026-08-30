-- ============================================================
-- UI AND CORE EDITING
-- Indentation, key discovery, appearance, text editing, statusline
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add {
  gh 'NMAC427/guess-indent.nvim',
  gh 'folke/which-key.nvim',
  gh 'rebelot/kanagawa.nvim',
  gh 'folke/todo-comments.nvim',
  gh 'nvim-mini/mini.nvim',
  gh 'sphamba/smear-cursor.nvim',
  gh 'windwp/nvim-autopairs',
  gh 'lukas-reineke/indent-blankline.nvim',
}

-- Detect indentation from the current file. This takes precedence over the
-- conservative four-space default for repositories with their own style.
require('guess-indent').setup {}

-- Show available continuations after a mapping prefix. Group declarations are
-- documentation only; the real keymaps stay beside the features they invoke.
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>a', group = '[A]I', mode = { 'n', 'v' } },
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>x', group = 'Diagnostics / lists' },
    { '<leader>g', group = '[G]it' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>d', group = '[D]ebug' },
    { '<leader>r', group = '[R]efactor', mode = { 'n', 'v' } },
    { '<leader>m', group = '[M]arkdown / map' },
    { '<leader>n', group = '[N]otifications' },
    { '<leader>t', group = '[T]est / toggle' },
    { '<leader>q', group = 'Session' },
    { '<leader>c', group = '[C]ode / cleanup' },
    { 'gr', group = 'LSP actions' },
  },
}

-- Kanagawa provides broad plugin highlight support while retaining a restrained
-- palette. Transparent floats keep the theme consistent with transparent terminals.
require('kanagawa').setup {
  transparent = true,
  commentStyle = { italic = false },
  overrides = function(colors)
    local palette = colors.palette
    return {
      NormalFloat = { bg = 'none' },
      FloatBorder = { bg = 'none' },
      -- Keep Rainbow Delimiters inside Kanagawa's existing visual language.
      RainbowDelimiterRed = { fg = palette.waveRed },
      RainbowDelimiterYellow = { fg = palette.carpYellow },
      RainbowDelimiterBlue = { fg = palette.crystalBlue },
      RainbowDelimiterOrange = { fg = palette.surimiOrange },
      RainbowDelimiterGreen = { fg = palette.springGreen },
      RainbowDelimiterViolet = { fg = palette.oniViolet },
      RainbowDelimiterCyan = { fg = palette.lightBlue },
    }
  end,
}
vim.cmd.colorscheme 'kanagawa-wave'

-- Give cursor movement a lightweight trail in both Normal and Insert mode.
-- Cursor animation in mini.animate is disabled below so only one plugin draws
-- cursor motion. `:SmearCursorToggle` remains available for distraction-free
-- sessions, screen sharing, or terminals where the effect is too expensive.
require('smear_cursor').setup {
  smear_between_buffers = true,
  smear_between_neighbor_lines = true,
  scroll_buffer_space = true,
  smear_insert_mode = true,
  stiffness = 0.9,
  trailing_stiffness = 0.7,
  damping = 0.95,
  anticipation = 0.3,
  time_interval = 10,
  stiffness_insert_mode = 0.8,
  trailing_stiffness_insert_mode = 0.8,
  damping_insert_mode = 0.95,
  legacy_computing_symbols_support = true,
  legacy_computing_symbols_support_vertical_bars = true,
  use_diagonal_blocks = true,
  matrix_pixel_threshold = 0.5,
}

-- Highlight TODO/FIXME/NOTE-style annotations and expose them to Telescope.
require('todo-comments').setup { signs = true }

-- mini.nvim is a collection of independent modules. Enabling another module is
-- simply another setup call; no additional repository is needed.
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  -- Compatibility for plugins that still ask for nvim-web-devicons.
  MiniIcons.mock_nvim_web_devicons()
end

-- Richer `a`round and `i`nside text objects. The next-object mappings avoid the
-- Neovim 0.12 incremental-selection defaults.
require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' },
  n_lines = 500,
}

-- Add/delete/replace surrounds: `saiw)`, `sd'`, and `sr)'`, for example.
require('mini.surround').setup()

-- Consistent bracket navigation for buffers, diagnostics, quickfix entries,
-- conflicts, undo states, and more. `[c`/`]c` remain reserved for Gitsigns.
require('mini.bracketed').setup { comment = { suffix = '' } }

-- Delete a buffer while preserving the split layout around it.
require('mini.bufremove').setup()
vim.keymap.set('n', '<leader>bd', function() MiniBufremove.delete(0, false) end, { desc = '[B]uffer [D]elete' })

-- Move lines or visual selections with Alt+hjkl and reindent linewise moves.
require('mini.move').setup()

-- `gS` toggles the nearest argument/collection list between one and many lines.
require('mini.splitjoin').setup()

-- `ga` aligns interactively; `gA` previews changes while alignment options change.
require('mini.align').setup()

-- Make accidental trailing whitespace visible and provide an explicit cleanup.
require('mini.trailspace').setup()
vim.keymap.set('n', '<leader>cW', MiniTrailspace.trim, { desc = '[C]lean trailing [W]hitespace' })

-- Smooth large scrolls and window layout changes without making ordinary
-- motions feel delayed. Smear Cursor owns cursor animation; keeping the
-- remaining animations near 100 ms makes them visible but still responsive.
local animate = require 'mini.animate'
animate.setup {
  cursor = { enable = false },
  scroll = {
    timing = animate.gen_timing.linear { duration = 150, unit = 'total' },
    subscroll = animate.gen_subscroll.equal { max_output_steps = 30 },
  },
  resize = {
    timing = animate.gen_timing.linear { duration = 120, unit = 'total' },
  },
  open = {
    timing = animate.gen_timing.linear { duration = 120, unit = 'total' },
  },
  close = {
    timing = animate.gen_timing.linear { duration = 120, unit = 'total' },
  },
}

-- A compact statusline is enough because Telescope and dedicated views expose
-- deeper project state on demand.
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

-- Complete matching delimiters and remove the matching closer when backspacing.
require('nvim-autopairs').setup {}

-- Draw indentation guides, including across blank lines.
require('ibl').setup {}
