-- ============================================================
-- TREESITTER AND STRUCTURAL TEXT OBJECTS
-- Parser installation, highlighting, indentation, semantic selections
-- ============================================================

local gh = require('config.pack').gh

vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' } }

-- Install common parsers eagerly. The FileType callback below installs other
-- available parsers the first time their language is opened.
local parsers = {
  'bash',
  'c',
  'cpp',
  'diff',
  'html',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'vim',
  'vimdoc',
}
require('nvim-treesitter').install(parsers)

---@param bufnr integer
---@param language string
local function attach(bufnr, language)
  if not vim.treesitter.language.add(language) then return end
  vim.treesitter.start(bufnr, language)

  -- Use Tree-sitter indentation when the parser ships a compatible query;
  -- otherwise Neovim's normal filetype indentation remains in effect.
  if vim.treesitter.query.get(language, 'indents') then vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then return end

    local installed = require('nvim-treesitter').get_installed 'parsers'
    if vim.tbl_contains(installed, language) then
      attach(args.buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      require('nvim-treesitter').install(language):await(function() attach(args.buf, language) end)
    else
      attach(args.buf, language)
    end
  end,
})

-- Structural text objects understand syntax rather than punctuation alone.
-- `af`/`if` select functions and `ac`/`ic` select classes in operator-pending
-- and visual mode, complementing mini.ai's generic text objects.
require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v',
      ['@function.outer'] = 'V',
      ['@class.outer'] = 'V',
    },
  },
}

local function ts_textobject(lhs, capture, description)
  vim.keymap.set(
    { 'x', 'o' },
    lhs,
    function() require('nvim-treesitter-textobjects.select').select_textobject(capture, 'textobjects') end,
    { desc = description }
  )
end
ts_textobject('af', '@function.outer', 'Around function')
ts_textobject('if', '@function.inner', 'Inside function')
ts_textobject('ac', '@class.outer', 'Around class')
ts_textobject('ic', '@class.inner', 'Inside class')
