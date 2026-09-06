-- ============================================================
-- PLUGIN MANAGEMENT
-- vim.pack helpers and post-install/update build hooks
-- ============================================================

-- `vim.pack` is Neovim's built-in plugin manager. Plugin state is recorded in
-- nvim-pack-lock.json; keep that file in version control for reproducibility.
-- See `:help vim.pack`, `:help vim.pack-examples`, and `:help vim.pack-events`.

local M = {}
local platform = require 'config.platform'

---Expand a GitHub owner/repository pair into the HTTPS clone URL used by vim.pack.
---@param repo string
---@return string
function M.gh(repo) return 'https://github.com/' .. repo end

local function run_build(name, command, cwd)
  local result = vim.system(command, { cwd = cwd }):wait()
  if result.code == 0 then return true end

  local output = result.stderr ~= '' and result.stderr or result.stdout
  if not output or output == '' then output = 'No output from build command.' end
  vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  return false
end

-- Plugins containing native code or generated parsers need a build/update step.
-- Register this before any `vim.pack.add()` so first-time installs are covered.
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Run plugin build hooks after installation or update',
  callback = function(event)
    local name = event.data.spec.name
    local kind = event.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' then
      for _, command in ipairs(platform.fzf_build_commands() or {}) do
        if not run_build(name, command, event.data.path) then break end
      end
      return
    end

    if name == 'LuaSnip' and vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make', 'install_jsregexp' }, event.data.path)
      return
    end

    if name == 'nvim-treesitter' then
      if not event.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd.TSUpdate()
    end
  end,
})

return M
