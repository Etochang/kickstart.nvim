-- This health provider reports capabilities rather than assuming one Unix
-- toolchain. Run `:checkhealth kickstart` after setting up a new machine.

local platform = require 'config.platform'

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.12') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

---@param label string
---@param names string[]
---@param optional? boolean
---@return string?
local function check_any(label, names, optional)
  local executable = platform.first_executable(names)
  if executable then
    vim.health.ok(('%s: `%s`'):format(label, executable))
  elseif optional then
    vim.health.info(('%s unavailable (optional; tried %s)'):format(label, table.concat(names, ', ')))
  else
    vim.health.warn(('%s unavailable (tried %s)'):format(label, table.concat(names, ', ')))
  end
  return executable
end

local function check_node()
  local node = check_any('Copilot Node.js runtime', { 'node' })
  if not node then return end

  local result = vim.system({ node, '--version' }, { text = true }):wait()
  local major = result.stdout and tonumber(result.stdout:match 'v?(%d+)')
  if result.code ~= 0 or not major then
    vim.health.warn 'Could not determine the Node.js version; Copilot requires Node.js 22+'
  elseif major < 22 then
    vim.health.warn(('Node.js %d is too old for Copilot; install Node.js 22+'):format(major))
  else
    vim.health.ok(('Node.js major version %d satisfies Copilot'):format(major))
  end
end

local function check_tree_sitter()
  local executable = check_any('Tree-sitter CLI', { 'tree-sitter' })
  if not executable then return end

  local result = vim.system({ executable, '--version' }, { text = true }):wait()
  local major, minor, patch
  if result.stdout then
    major, minor, patch = result.stdout:match '(%d+)%.(%d+)%.(%d+)'
  end
  major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
  local supported = major and (major > 0 or minor > 26 or (minor == 26 and patch >= 1))
  if result.code ~= 0 or not major then
    vim.health.warn 'Could not determine the Tree-sitter CLI version; nvim-treesitter requires 0.26.1+'
  elseif not supported then
    vim.health.warn(('Tree-sitter CLI %d.%d.%d is too old; install 0.26.1+'):format(major, minor, patch))
  else
    vim.health.ok(('Tree-sitter CLI %d.%d.%d satisfies nvim-treesitter'):format(major, minor, patch))
  end
end

---@return boolean
local function copilot_uses_token_database()
  local config_root = os.getenv 'CODECOMPANION_TOKEN_PATH'
  if not config_root or config_root == '' then
    config_root = platform.is_windows and vim.fn.expand '~/AppData/Local' or (os.getenv 'XDG_CONFIG_HOME' or vim.fn.expand '~/.config')
  end

  local auth_root = vim.fs.joinpath(config_root, 'github-copilot')
  local has_json_token = vim.uv.fs_stat(vim.fs.joinpath(auth_root, 'hosts.json')) or vim.uv.fs_stat(vim.fs.joinpath(auth_root, 'apps.json'))
  return not has_json_token and vim.uv.fs_stat(vim.fs.joinpath(auth_root, 'auth.db')) ~= nil
end

local function check_gnu_tar()
  local executable = platform.first_executable { 'gtar', 'tar' }
  if not executable then return end

  local result = vim.system({ executable, '--version' }, { text = true }):wait()
  local output = (result.stdout or '') .. (result.stderr or '')
  if result.code == 0 and output:find('GNU tar', 1, true) then
    vim.health.ok(('Mason GNU tar: `%s`'):format(executable))
  else
    vim.health.warn 'Mason documents GNU tar as a Windows requirement; the built-in bsdtar may not install every package'
  end
end

local function check_external_reqs()
  vim.health.start 'Core executables'
  check_any('Plugin source control', { 'git' })
  check_any('Project text search', { 'rg' })
  check_any('File finder accelerator', platform.is_windows and { 'fd' } or { 'fd', 'fdfind' }, true)

  vim.health.start 'Tree-sitter parser toolchain'
  check_any('Download tool', { 'curl' })
  check_any('Archive tool', { 'tar' })
  check_tree_sitter()
  check_any('C/C++ compiler', platform.is_windows and { 'cl', 'clang', 'gcc', 'zig' } or { 'cc', 'clang', 'gcc', 'zig' })

  if platform.is_windows then
    vim.health.start 'Windows host tools'
    check_any('PowerShell for Mason', { 'pwsh', 'powershell' })
    check_any('PowerShell 7 for Copilot CLI', { 'pwsh' }, true)
    check_gnu_tar()
    check_any('Mason archive extractor', { '7z', 'peazip', 'wzunzip', 'winrar', 'arc' })
  end

  vim.health.start 'Optional native plugin build'
  local fzf_commands = platform.fzf_build_commands()
  if fzf_commands then
    vim.health.ok(('Telescope FZF builder: `%s`'):format(fzf_commands[1][1]))
  else
    vim.health.info 'No Make or CMake found; Telescope will use its portable Lua sorter'
  end

  vim.health.start 'Language and AI workflows'
  check_any('Python tests and tools', platform.is_windows and { 'py', 'python' } or { 'python3', 'python' }, true)
  check_node()
  check_any('Node package manager for Mason tools', { 'npm' })
  check_any('CodeCompanion Copilot token database reader', { 'sqlite3' }, not copilot_uses_token_database())
  check_any('Copilot CLI ACP agent', { 'copilot' }, true)

  local yazi = platform.first_executable { 'yazi' }
  local ya = platform.first_executable { 'ya' }
  if yazi and ya then
    vim.health.ok 'Yazi directory browser: `yazi` and `ya`'
  else
    vim.health.info 'Yazi is unavailable; <Leader>- will fall back to netrw'
  end

  return true
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
  end,
}
