# Native Windows setup and compatibility notes

This configuration is designed to support native Windows as well as
macOS/Linux. The most predictable Windows setup is Windows 11, Windows
Terminal, PowerShell 7, and a recent Neovim installed directly on Windows. WSL
also works, but it is a separate Linux installation; see
[Native Windows versus WSL](#native-windows-versus-wsl).

## What the configuration handles automatically

- Paths used by the Lua configuration are joined and normalized with Neovim's
  path APIs, including drive letters and Windows separators.
- `telescope-fzf-native.nvim` builds with CMake on Windows. If neither CMake
  nor Make exists, Telescope keeps its portable Lua sorter instead.
- `<Leader>-` opens Yazi only when both `yazi` and `ya` are available. It falls
  back to Neovim's built-in netrw directory browser on a minimal machine.
- Yazi relative-path copying uses Neovim instead of the GNU `realpath` program.
- LuaSnip skips its optional Make-built JavaScript-regexp library on Windows.
  Ordinary snippets still work; only snippets requiring complex regexp
  transformations lose that optional capability.
- `:checkhealth kickstart` reports Windows capabilities and the versions needed
  by Tree-sitter and Copilot.
- Tracked Lua, Markdown, JSON, TOML, and YAML files are pinned to LF in
  `.gitattributes`, preventing line-ending-only diffs between hosts.

## 1. Install the host tools

Run the baseline installs from a normal PowerShell window. `winget` may report
that a package is already installed, which is harmless.

```powershell
winget install --id Microsoft.PowerShell -e --source winget
winget install --id Neovim.Neovim -e --source winget
winget install --id Git.Git -e --source winget
winget install --id BurntSushi.ripgrep.MSVC -e --source winget
winget install --id 7zip.7zip -e --source winget
winget install --id OpenJS.NodeJS.LTS -e --source winget
winget install --id Python.Python.3.14 -e --source winget
winget install --id tree-sitter.tree-sitter-cli -e --source winget
```

Install the feature-specific tools for the workflows you intend to use:

```powershell
winget install --id sharkdp.fd -e --source winget
winget install --id Kitware.CMake -e --source winget
winget install --id Ninja-build.Ninja -e --source winget
winget install --id SQLite.SQLite -e --source winget
winget install --id GitHub.Copilot -e --source winget
winget install --id sxyazi.yazi -e --source winget
```

Close and reopen Windows Terminal afterward, select its PowerShell 7 (`pwsh`)
profile, and verify the important commands:

```powershell
nvim --version
git --version
rg --version
fd --version
curl.exe --version
tar --version
7z --help
cmake --version
ctest --version
ninja --version
node --version
npm --version
py --version
python --version
python -m pip --version
pwsh --version
copilot --version
yazi --version
ya --version
sqlite3 --version
tree-sitter --version
```

Run checks only for the optional tools you installed. If `7z` is not found but
7-Zip exists at `C:\Program Files\7-Zip\7z.exe`, add that directory to your
user `PATH` in Windows Settings and restart the terminal.

Mason documents **GNU tar** as a Windows requirement, while the `tar.exe`
bundled with Windows identifies itself as `bsdtar`. Run `:checkhealth mason`
after first launch. If Mason extraction fails, install GNU tar through your
preferred Windows package manager and make its `gtar.exe` or `tar.exe` visible
before the built-in one. Avoid adding Git's entire `usr\bin` directory ahead of
Windows system directories merely to solve this one command, because it can
shadow unrelated tools.

This configuration currently requires Neovim 0.12 or newer because it uses
`vim.pack` and the `main` branch of
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).
[Copilot completion](https://github.com/zbirenbaum/copilot.lua) uses the
default Node.js server and therefore requires Node.js 22 or newer.

### Compiler and Tree-sitter CLI

Install one native C/C++ compiler. The recommended choice is the
[Microsoft C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
with the **Desktop development with C++** workload. LLVM or a complete MinGW
toolchain can also compile parsers, but the CMake plus Microsoft Build Tools
route is the
[upstream-supported Windows path](https://github.com/nvim-telescope/telescope-fzf-native.nvim#cmake-windows-linux-macos)
for Telescope's native sorter.

The WinGet command above installs `tree-sitter-cli`; confirm it is 0.26.1 or
newer. An official prebuilt release or Cargo is a fallback when that package is
unavailable. Do not install the CLI from npm for this nvim-treesitter version.
If Rust is already installed, the Cargo fallback is:

```powershell
cargo install --locked tree-sitter-cli
tree-sitter --version
```

The compiler environment must be visible to Neovim. If `cl.exe` is not found
in ordinary PowerShell, either launch Neovim from a **Developer PowerShell for
VS** prompt or use LLVM/MinGW executables that are permanently on `PATH`.

## 2. Install this configuration

Back up an existing configuration rather than overwriting it in place. The
timestamp prevents an older backup from being overwritten:

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
if (Test-Path "$env:LOCALAPPDATA\nvim") {
  Rename-Item "$env:LOCALAPPDATA\nvim" "nvim.backup-$stamp"
}
if (Test-Path "$env:LOCALAPPDATA\nvim-data") {
  Rename-Item "$env:LOCALAPPDATA\nvim-data" "nvim-data.backup-$stamp"
}
```

Then clone your configuration repository:

```powershell
git clone https://github.com/USER/kickstart.nvim.git "$env:LOCALAPPDATA\nvim"
Set-Location "$env:LOCALAPPDATA\nvim"
nvim
```

Replace `USER` with the account containing this configuration repository.

On first launch, `vim.pack` downloads the plugins and Mason installs the
configured language/debug/formatting tools. Let those jobs finish, then run:

```vim
:TSUpdate
:checkhealth kickstart
:checkhealth mason
:checkhealth vim.provider
:checkhealth telescope
:checkhealth yazi
:checkhealth codecompanion
:checkhealth copilot
```

Use `:Mason` to inspect any package that failed. Mason packages may contain
OS-specific executables or command wrappers, so install them again on Windows
even if you copied the configuration from a Mac.

## 3. Authenticate Copilot

There are two related integrations:

1. `copilot.lua` supplies Blink completions and the regular CodeCompanion HTTP
   chat. In Neovim, run `:Copilot auth` and then `:Copilot auth info`.
2. GitHub Copilot CLI supplies the repository-aware ACP agent started with
   `<Leader>aA`. In PowerShell, run `copilot`, enter `/login`, and complete the
   device flow.

The logins may be stored separately, so authenticate both. CodeCompanion can
read Copilot's newer `auth.db` token store through `sqlite3.exe`; that is why
SQLite is in the install list. GitHub's native WinGet Copilot package is
preferred here because it exposes a directly executable `copilot` program.
See GitHub's
[Copilot CLI installation guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli)
for alternative installation and authentication methods.

If Copilot is supplied by an organization or enterprise, its administrator
must also enable the Copilot CLI policy. A personal subscription alone is not
what controls that organization-level policy.

## 4. Configure Yazi on Windows

[The Neovim plugin](https://github.com/mikavilpas/yazi.nvim#-installation)
requires Windows 11 and a recent Yazi release, which supplies both `yazi` and
`ya`. The
[Yazi Windows guide](https://yazi-rs.github.io/docs/installation/#windows)
recommends using the `file.exe` bundled with Git for Windows for correct MIME
detection. Set it once for your user account:

```powershell
[string] $gitFile = 'C:\Program Files\Git\usr\bin\file.exe'
if (-not (Test-Path $gitFile)) {
  throw 'Adjust $gitFile to the file.exe location in your Git installation.'
}
[Environment]::SetEnvironmentVariable(
  'YAZI_FILE_ONE',
  $gitFile,
  'User'
)
```

Restart Windows Terminal. If you do not want Yazi, uninstalling or omitting it
is safe: `<Leader>-` will open netrw instead.

This is enough for directory navigation. Rich previews for archives, PDFs,
images, and video need Yazi's optional Windows dependencies such as 7-Zip,
Poppler, ImageMagick, and FFmpeg; install only the preview types you use.

## 5. Python and C/C++ projects

Create Python environments without depending on PowerShell's script-execution
policy:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install pytest
.\.venv\Scripts\python.exe -m pytest
nvim .
```

Activation is optional. If desired, use
`.\.venv\Scripts\Activate.ps1`; a restrictive execution policy can block that
script but does not block calling the environment's Python executable directly.

For portable CMake projects, Ninja gives the same single-configuration workflow
on macOS, Linux, and Windows:

```powershell
cmake -S . -B build-ninja -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build-ninja
ctest --test-dir build-ninja --output-on-failure
```

Ninja is the preferred default because CMake can generate the
`compile_commands.json` database used by clangd. CMake implements that export
for Makefile and Ninja generators, not Visual Studio generators.

If a project uses the Visual Studio generator, it is multi-configuration. Pick
the configuration at build and test time instead:

```powershell
cmake -S . -B build-vs
cmake --build build-vs --config Debug
ctest --test-dir build-vs -C Debug --output-on-failure
```

Run either set through `:OverseerShell` inside Neovim exactly as described in
`WORKFLOWS.md`. It uses Neovim's `'shell'`, which defaults to `cmd.exe` on
native Windows even when Neovim was launched from PowerShell. Inspect it with
`:set shell?`. The CMake commands above work in either shell; invoke
`pwsh -NoProfile -Command ...` explicitly for a PowerShell-only task. If you
want to change Neovim's default, configure the complete option set documented
under `:help shell-pwsh`, not only `'shell'`.

For embedded development, the host editor setup does not install an MCU
toolchain, debug probe driver, OpenOCD/J-Link server, or vendor SDK. Install
those for the specific target. `codelldb` is useful for host-side LLVM/MinGW
binaries; MSVC/PDB and on-device debugging may need a different adapter and a
project-specific DAP configuration.

## Native Windows versus WSL

Choose one environment for each project:

| Native Windows | WSL |
| --- | --- |
| Config: `%LOCALAPPDATA%\nvim` | Config: `~/.config/nvim` |
| Data: `%LOCALAPPDATA%\nvim-data` | Data: `~/.local/share/nvim` |
| Windows toolchains and paths | Linux toolchains and paths |
| Windows SDKs and native USB tools | Linux-first command-line projects |

Do not share `nvim-data`, Mason packages, Tree-sitter parsers, or compiled
Telescope artifacts between the two environments. They contain OS-specific
binaries. The Git-tracked configuration source can be shared safely.

In WSL, keep active projects under the Linux filesystem for better file-system
performance. Clipboard bridging is also separate; diagnose it with
`:checkhealth vim.provider` and use Neovim's documented `clip.exe`/PowerShell
bridge or OSC 52 if automatic detection is insufficient.

## Remaining caveats

- **Keyboard modifiers:** the BCORNE mappings that send `LGui` behave as
  Command shortcuts on macOS but as Windows-key shortcuts on Windows. Create a
  Windows Vial layer/profile using Ctrl for VS Code actions, or enable QMK's
  Ctrl/GUI swap when changing hosts.
- **Terminal keycodes:** Alt mappings, `<C-Space>`, `<S-F8>`, and some function
  keys depend on the terminal. Windows Terminal is recommended; inspect a key
  with `:map <key>` if it is swallowed by the terminal or operating system.
- **Fonts and visuals:** install the same Nerd Font in Windows Terminal and set
  it on that terminal profile. Cursor animations can look different with a slow
  renderer or remote session.
- **Clipboard:** native Windows normally uses `win32yank` or
  `clip.exe`/PowerShell automatically. `:checkhealth vim.provider` is the source
  of truth for the current terminal.
- **LuaSnip regexp transforms:** the optional `jsregexp` Make build is skipped
  on Windows. Normal snippets, choices, and tabstops are unaffected.
- **Native builds and antivirus:** Windows security software can quarantine or
  delay freshly built DLLs and downloaded Mason/Blink binaries. Inspect the
  plugin/Mason logs before assuming the Lua configuration failed.
- **ARM64 Windows:** some Mason packages and native plugins do not publish
  ARM64 artifacts. A native compiler may cover source-built plugins, but each
  external language/debug tool must be checked individually.
- **Line endings:** `.gitattributes` keeps configuration sources at LF. A
  particular Windows project can define its own line-ending policy in its own
  repository.

When something differs between machines, start with `:checkhealth kickstart`,
`:checkhealth`, `:Mason`, and `$env:PATH` from the same terminal that launches
Neovim. A GUI launcher may inherit an older or different environment.
