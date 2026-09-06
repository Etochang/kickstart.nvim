-- ============================================================
-- PLATFORM CAPABILITIES
-- Operating-system detection and external build-tool selection
-- ============================================================

-- Keep platform decisions in one small module instead of scattering win32
-- branches through plugin configuration. Prefer capability checks whenever a
-- tool can work on more than one operating system.
local M = {
  is_windows = vim.fn.has 'win32' == 1,
}

---@param names string[]
---@return string?
function M.first_executable(names)
  for _, name in ipairs(names) do
    if vim.fn.executable(name) == 1 then return name end
  end
end

---Return a path relative to a directory or file, without an external `realpath`.
---Falls back to the absolute target when the paths have no common root, as can
---happen with two different drive letters on Windows.
---@param source string
---@param target string
---@return string
function M.relative_path(source, target)
  source = vim.fs.normalize(vim.uv.fs_realpath(source) or source)
  target = vim.fs.normalize(vim.uv.fs_realpath(target) or target)

  local stat = vim.uv.fs_stat(source)
  if not stat or stat.type ~= 'directory' then source = vim.fs.dirname(source) end

  -- vim.fs.relpath handles descendants. Walk toward the common ancestor to
  -- cover siblings and parents too, matching `realpath --relative-to`.
  local parent_count = 0
  while source do
    local descendant = vim.fs.relpath(source, target)
    if descendant then
      local relative = descendant == '.' and '' or descendant
      for _ = 1, parent_count do
        relative = relative == '' and '..' or vim.fs.joinpath('..', relative)
      end
      return relative == '' and '.' or relative
    end

    local parent = vim.fs.dirname(source)
    if not parent or parent == source then break end
    source = parent
    parent_count = parent_count + 1
  end

  return target
end

---@param opts? { is_windows?: boolean, executable?: fun(name: string): boolean }
---@return string[][]?
function M.fzf_build_commands(opts)
  opts = opts or {}
  local is_windows = opts.is_windows
  if is_windows == nil then is_windows = M.is_windows end

  local executable = opts.executable or function(name) return vim.fn.executable(name) == 1 end
  local function cmake_commands()
    return {
      { 'cmake', '-S', '.', '-B', 'build', '-DCMAKE_BUILD_TYPE=Release' },
      { 'cmake', '--build', 'build', '--config', 'Release', '--target', 'install' },
    }
  end

  -- Native Windows commonly has Visual Studio Build Tools and CMake but no
  -- GNU Make. CMake is also the upstream-supported Windows build route.
  if is_windows and executable 'cmake' then return cmake_commands() end
  if executable 'make' then return { { 'make' } } end
  if executable 'cmake' then return cmake_commands() end
end

return M
