-- ============================================================
-- SEARCH AND NAVIGATION
-- Telescope, Flash, Yazi, Trouble, and project-wide replacement
-- ============================================================

local gh = require('config.pack').gh
local platform = require 'config.platform'

local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if platform.fzf_build_commands() then telescope_plugins[#telescope_plugins + 1] = gh 'nvim-telescope/telescope-fzf-native.nvim' end

vim.pack.add(telescope_plugins)
vim.pack.add {
  gh 'folke/flash.nvim',
  gh 'mikavilpas/yazi.nvim',
  gh 'folke/trouble.nvim',
  gh 'MagicDuck/grug-far.nvim',
}

-- Telescope is the central picker for files, text, buffers, help, commands,
-- diagnostics, and LSP results. The native FZF extension improves sorting when
-- a local C toolchain is available.
require('telescope').setup {
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sR', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch recent files' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end,
  { desc = 'Fuzzily search the current buffer' }
)

vim.keymap.set(
  'n',
  '<leader>s/',
  function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end,
  { desc = '[S]earch in open files' }
)

vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })

-- Add Telescope-backed LSP navigation only in buffers where a server attached.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local opts = function(desc) return { buffer = event.buf, desc = desc } end
    vim.keymap.set('n', 'grr', builtin.lsp_references, opts '[G]oto [R]eferences')
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, opts '[G]oto [I]mplementation')
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, opts '[G]oto [D]efinition')
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, opts 'Document symbols')
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, opts 'Workspace symbols')
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, opts '[G]oto [T]ype definition')
  end,
})

-- Flash replaces Hop with labeled, multi-window jumps plus Tree-sitter-aware
-- selection and operator-pending support. `s` retains the previous muscle memory.
require('flash').setup {}
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter' })
vim.keymap.set('c', '<C-s>', function() require('flash').toggle() end, { desc = 'Toggle Flash search' })

-- Yazi remains the full external file manager. It is intentionally preferred
-- over adding a second sidebar-style file tree. A fresh machine without the
-- optional executable keeps netrw as a functional directory-browser fallback.
local has_yazi = vim.fn.executable 'yazi' == 1 and vim.fn.executable 'ya' == 1
require('yazi').setup {
  open_for_directories = has_yazi,
  integrations = {
    -- Avoid Yazi's GNU realpath dependency, which is not included with Windows.
    -- vim.fs also keeps drive-letter and separator handling inside Neovim.
    resolve_relative_path_implementation = function(args) return platform.relative_path(args.source_dir, args.selected_file) end,
  },
}
-- Yazi silently clears netrw's optional FileExplorer autocommand. When netrw
-- has not created it, Vim records the suppressed error in v:errmsg. Clear only
-- that exact residue so an unrelated earlier startup error remains visible.
if vim.v.errmsg:match '^E216:.*FileExplorer' then vim.v.errmsg = '' end
vim.keymap.set('n', '<leader>-', function()
  if has_yazi then
    vim.cmd.Yazi()
  else
    vim.notify('Yazi and ya are not both on PATH; opening netrw instead', vim.log.levels.INFO)
    vim.cmd.Explore()
  end
end, { desc = 'Open directory browser' })

-- Trouble presents diagnostics, symbols, references, and list entries as
-- structured, previewable trees instead of transient one-line messages.
require('trouble').setup {}
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Workspace diagnostics' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer diagnostics' })
vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<CR>', { desc = '[C]ode [S]ymbols' })
vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<CR>', { desc = '[C]ode [L]SP list' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<CR>', { desc = 'Location list' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix list' })

-- Grug Far provides previewable project-wide search and replacement. It uses
-- ripgrep by default and keeps the results in a normal, editable Neovim buffer.
require('grug-far').setup {}
vim.keymap.set(
  'n',
  '<leader>sr',
  function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end,
  { desc = '[S]earch and [R]eplace' }
)
