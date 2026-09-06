# Neovim Workflow Reference

This is the practical operating guide for this Neovim configuration. It is
organized around tasks you perform, not around plugin names. Use it to build a
small set of repeatable habits and consult the command index when you forget a
less frequent action.

`<Leader>` is the Space key. For example, `<Leader>sf` means press Space, then
`s`, then `f`. Pause after Space at any time to let WhichKey show the available
continuations.

## The default daily loop

Start Neovim from the project root so search, test discovery, Git, and AI tools
all agree about the workspace:

```sh
cd /path/to/project
nvim .
```

In PowerShell, the equivalent is:

```powershell
Set-Location C:\path\to\project
nvim .
```

Then repeat this loop:

1. Find a file with `<Leader>sf` or search code with `<Leader>sg`.
2. Navigate definitions and references with `grd` and `grr`.
3. Edit directly, using completion with `<C-n>`, `<C-p>`, and `<C-y>`.
4. Format with `<Leader>f`; saving also formats supported filetypes.
5. Check current-buffer diagnostics with `<Leader>xX`.
6. Build or run the nearest test.
7. Review Git hunks with `]c`, `<Leader>hp`, and `<Leader>gd`.
8. Stage, commit, and push through `<Leader>gg`.

Use AI only at the level the task needs:

- Completion for finishing the line already in your head.
- Inline edit for one selected region.
- Chat for explanations, design discussion, and diagnosis.
- Copilot CLI agent for repository-aware, multi-file implementation.

## Files, directories, buffers, and windows

### Find and open things

| Action | Key or command |
| --- | --- |
| Find a project file | `<Leader>sf` |
| Search text across the project | `<Leader>sg` |
| Search the word under the cursor | `<Leader>sw` |
| Search Neovim help | `<Leader>sh` |
| Search configured keymaps | `<Leader>sk` |
| Choose another Telescope picker | `<Leader>ss` |
| Search only open files | `<Leader>s/` |
| Search inside the current buffer | `<Leader>/` |
| List open buffers | `<Leader><Leader>` |
| Open a recent file | `<Leader>s.` |
| Resume the previous Telescope search | `<Leader>sR` |
| Search available commands | `<Leader>sc` |
| Search this Neovim configuration | `<Leader>sn` |
| Open the Yazi directory browser | `<Leader>-` |
| Delete the current buffer but preserve the layout | `<Leader>bd` |

You do not need to return to a directory listing after opening a file. Usually
`<Leader>sf`, `<Leader>sg`, and `<Leader><Leader>` are faster. When a visual file
browser is useful, press `<Leader>-`; leave Yazi with `q`.

Useful built-in commands:

```vim
:pwd                  " Show Neovim's working directory
:cd /path/to/project  " Change the workspace root for this session
:edit path/to/file    " Open a known path
:vsplit path/to/file  " Open it in a vertical split
:split path/to/file   " Open it in a horizontal split
:terminal             " Open a terminal buffer
```

Move among splits with `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>`. In a terminal,
press `<Esc><Esc>` to return to Normal mode. In a normal file buffer, `<Esc>`
also clears highlighting left by the previous search.

### Jump instead of scrolling

| Action | Key |
| --- | --- |
| Jump to a visible label | `s` |
| Tree-sitter-aware jump/selection | `S` |
| Next/previous buffer | `]b` / `[b` |
| Next/previous diagnostic | `]d` / `[d` |
| Next/previous diagnostic from the keyboard layer | `<F8>` / `<S-F8>` |
| Next/previous quickfix item | `]q` / `[q` |
| Next/previous Git hunk | `]c` / `[c` |

## Direct editing and completion

### Completion, snippets, and Copilot suggestions

Blink presents LSP, path, snippet, buffer, LazyDev, and Copilot results in one
menu. Copilot does not use separate ghost text in this configuration.

| Insert-mode action | Key |
| --- | --- |
| Open completion and documentation | `<C-Space>` |
| Select next candidate | `<C-n>` |
| Select previous candidate | `<C-p>` |
| Accept selected candidate | `<C-y>` |
| Show/hide function signature | `<C-k>` |

Treat a Copilot candidate like any other completion: inspect it, select it, and
accept only when it expresses the code you intended. Authenticate or diagnose
Copilot with:

```vim
:Copilot auth
:Copilot auth info
```

### Editing helpers worth making habitual

| Action | Key/example |
| --- | --- |
| Format buffer or visual selection | `<Leader>f` |
| Move a line or visual selection | `<M-h/j/k/l>` |
| Split/join an argument or collection | `gS` |
| Align interactively | `ga` |
| Preview alignment | `gA` |
| Add surrounding characters | `saiw)` |
| Delete surrounding quotes | `sd'` |
| Replace surrounding `)` with `'` | `sr)'` |
| Select around/inside a function | `af` / `if` |
| Select around/inside a class | `ac` / `ic` |
| Choose a supported refactor | `<Leader>rs` |
| Remove trailing whitespace | `<Leader>cW` |
| Inspect persistent undo history | `<Leader>u` |

The structural `af`, `if`, `ac`, and `ic` objects work in Visual and
operator-pending modes. Examples include `daf` to delete a function and `vif`
to select its body.

### Breadcrumbs, folds, minimap, and notifications

The winbar above each normal editing window shows the current file and nested
LSP or Tree-sitter context. Nested delimiters are colored by depth automatically.

| Action | Key |
| --- | --- |
| Pick a path or symbol from the breadcrumb | `<Leader>;` |
| Jump to the current context's beginning | `[;` |
| Select the next breadcrumb context | `];` |
| Toggle the minimap | `<Leader>mm` |
| Move focus into/out of the minimap | `<Leader>mf` |
| Move the minimap to the other side | `<Leader>ms` |
| Open all folds | `zR` |
| Close all folds | `zM` |
| Preview the closed fold under the cursor | `zK` |
| Show notification history | `<Leader>nh` |
| Dismiss visible notifications | `<Leader>nd` |

Ordinary fold commands still work: `za` toggles the fold under the cursor,
`zo` opens it, and `zc` closes it. The minimap marks search matches,
diagnostics, and Git changes; press `<CR>` after focusing it to return to the
corresponding source location. Files above Snacks' big-file threshold skip
expensive language and animation features automatically.

Starting `nvim` without a file opens a dashboard with file search, text search,
recent files, projects, config access, and session restore. Its single-letter
actions are shown directly on the dashboard; `nvim .` still opens the requested
directory rather than replacing it with the dashboard.

## LSP and diagnostics

These mappings exist when a language server is attached:

| Action | Key |
| --- | --- |
| Go to definition | `grd` |
| Go to declaration | `grD` |
| Find references | `grr` |
| Find implementations | `gri` |
| Go to type definition | `grt` |
| Rename symbol | `grn` |
| Code action | `gra` |
| Search document symbols | `gO` |
| Search workspace symbols | `gW` |
| Toggle inlay hints | `<Leader>th` |

Diagnostics and symbol views:

| View | Key |
| --- | --- |
| Current-buffer diagnostics | `<Leader>xX` |
| Workspace diagnostics | `<Leader>xx` |
| Telescope diagnostics | `<Leader>sd` |
| Current document's symbol tree | `<Leader>cs` |
| LSP definitions/references list | `<Leader>cl` |
| Location list | `<Leader>xL` |
| Quickfix list | `<Leader>xQ` |

`<Leader>cs` is a navigable outline of functions, methods, classes, and other
symbols in the current file. It does not send symbols to CodeCompanion; use
CodeCompanion's `/symbols` command for that.

`grd` answers “where is this symbol defined?” and jumps there through a
Telescope result when needed. `grr` answers “where is this symbol used?” and
lists every reference reported by the attached language server.

If language intelligence seems wrong, start with:

```vim
:LspInfo
:checkhealth vim.lsp
:Mason
```

## Formatting and indentation

The editor default is four spaces with `expandtab` enabled. Pressing Tab inserts
spaces rather than a literal tab character. Existing repositories can override
the width through EditorConfig or detected indentation.

- Lua in this repository uses two spaces through `.editorconfig` and StyLua.
- C/C++ falls back to four spaces through Conform and ClangFormat.
- A project's own `.clang-format` takes precedence over the fallback.

Inspect the current buffer's effective settings with:

```vim
:setlocal tabstop? shiftwidth? softtabstop? expandtab?
:ConformInfo
```

Temporarily force four-space input in the current buffer with:

```vim
:setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
```

For a real C/C++ project, commit a project-local `.editorconfig` and
`.clang-format` once the team or SDK conventions are known. EditorConfig controls
interactive indentation; ClangFormat controls the final formatted result.

A four-space project policy can start with:

```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{c,cc,cpp,cxx,h,hh,hpp,hxx}]
indent_style = space
indent_size = 4
tab_width = 4
```

```yaml
# .clang-format
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Never
AllowShortFunctionsOnASingleLine: None
```

### Markdown and AI-output rendering

Markdown files and CodeCompanion chats render headings, lists, tables, links,
and code blocks directly inside Neovim. Normal mode shows the rendered view;
enter Insert mode when you need the underlying Markdown source.

| Action | Key/command |
| --- | --- |
| Open a rendered side preview | `<Leader>mp` |
| Toggle rendering in the current buffer | `<Leader>mr` |
| Enable rendering | `:RenderMarkdown buf_enable` |
| Disable rendering | `:RenderMarkdown buf_disable` |
| Diagnose rendering | `:checkhealth render-markdown` |

`<Leader>mp` is the closest equivalent to VS Code's Markdown preview. The
leader mapping is used instead of `<C-S-v>` because many terminal emulators
reserve that chord for paste or cannot distinguish it reliably.

## Searching and project-wide replacement

Use Telescope for finding and Grug Far for deliberate multi-file changes:

1. Put the cursor on the word to replace.
2. Press `<Leader>sr`.
3. Adjust the search, replacement, file glob, and flags in the Grug Far buffer.
4. Inspect the preview before applying replacements.
5. Review the resulting Git diff with `<Leader>gd`.

For a simple in-file substitution, built-in Vim remains quicker:

```vim
:%s/old/new/gc
```

The `c` flag asks for confirmation before each replacement.

## Git workflow

### Understand and stage hunks

A hunk is one contiguous changed region in Git's diff. Hunk staging lets one
file contribute to more than one focused commit.

| Action | Key |
| --- | --- |
| Next/previous hunk | `]c` / `[c` |
| Preview hunk | `<Leader>hp` |
| Preview inline | `<Leader>hi` |
| Stage current hunk | `<Leader>hs` |
| Reset current hunk | `<Leader>hr` |
| Stage all changes in current buffer | `<Leader>hS` |
| Reset all changes in current buffer | `<Leader>hR` |
| Blame current line | `<Leader>hb` |
| Diff buffer against index | `<Leader>hd` |
| Diff buffer against last commit | `<Leader>hD` |
| Put repository hunks in quickfix | `<Leader>hQ` |
| Put buffer hunks in quickfix | `<Leader>hq` |
| Toggle line blame | `<Leader>tb` |
| Toggle word diff | `<Leader>tw` |
| Select a hunk as a text object | `vih` / `dih` |

Reset actions discard work. Preview before using `<Leader>hr` or `<Leader>hR`.
In Visual mode, `<Leader>hs` and `<Leader>hr` operate on the selected lines.

### Review the repository

```text
<Leader>gd   Open Diffview for the repository
<Leader>gH   Show history for the current file
:DiffviewClose
```

Use Diffview before committing agent-generated or broad mechanical changes. It
is the final repository-wide review even if you already inspected individual
hunks.

### Stage, commit, and push with Neogit

1. Press `<Leader>gg` to open Neogit.
2. Move to a file or hunk and press `s` to stage it. Press `u` to unstage.
3. Press `c`, then `c` again to create a commit.
4. Write the commit subject and optional body.
5. Submit from Normal or Insert mode with `<C-c><C-c>`.
6. Back in Neogit, press `P` to open the push popup.
7. Press `p` to push to the push remote/default, or `u` for the configured
   upstream shown in the popup.

For a branch's first push, the push popup exposes `-u` to set the upstream; then
choose the displayed destination. Read the popup labels rather than memorizing
a remote name. Press `?` in Neogit when you need the local keymap help, and `q`
to close a view.

## Testing workflow

Neotest owns individual test discovery and results. Overseer owns asynchronous
build commands and general project tasks. They complement rather than replace
each other.

| Test action | Key |
| --- | --- |
| Run nearest test | `<Leader>tn` |
| Run tests in current file | `<Leader>tf` |
| Debug nearest test | `<Leader>td` |
| Toggle test summary | `<Leader>ts` |
| Open test output | `<Leader>to` |
| Stop test | `<Leader>tx` |

| Task action | Key/command |
| --- | --- |
| Choose a registered task template | `<Leader>tR` / `:OverseerRun` |
| Run an arbitrary command as a task | `:OverseerShell {command}` |
| Toggle the task list | `<Leader>tT` |
| Restart the latest task | `<Leader>tl` |

In the Overseer task list, put the cursor on a task and press `<CR>` to see its
actions and output options.

### Write tests that remain useful

Use a short red-green-refactor loop:

1. Write one test describing one observable behavior.
2. Run it and confirm it fails for the expected reason.
3. Implement the smallest behavior that makes it pass.
4. Refactor while keeping the focused test green.
5. Run the containing file and then the broader relevant suite.

Prefer behavior-oriented names and cover the normal case, important boundaries,
and meaningful error paths. Keep host tests deterministic: replace clocks,
randomness, files, networks, and hardware access with controlled inputs or fakes.
Mock hardware at the HAL boundary rather than mocking internal implementation
details.

### Python tests

Create a project environment and install pytest on macOS/Linux:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install pytest
pytest
```

On Windows PowerShell, call the environment's Python directly. This works even
when PowerShell's execution policy prevents activation scripts:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install pytest
.\.venv\Scripts\python.exe -m pytest
```

Open Neovim from that project root. In a `test_*.py` or `*_test.py` file:

1. Put the cursor inside a test and press `<Leader>tn`.
2. Press `<Leader>to` if it fails.
3. Press `<Leader>td` when stepping through it is faster than adding prints.
4. Press `<Leader>tf` before committing the file.

A minimal pytest test is simply:

```python
def test_adds_two_positive_numbers():
    assert calculator_add(2, 3) == 5
```

### C/C++ host tests with CMake, CTest, and GoogleTest

GoogleTest is a per-project dependency declared in `CMakeLists.txt`; it does not
need a global Homebrew installation. Register test executables with CTest using
`enable_testing()` and `gtest_discover_tests(...)`. Name test source files
`*_test.cpp`, `*_test.cc`, or `*_test.cxx` for reliable Neotest discovery.

To test production C from a C++ GoogleTest harness:

```cpp
extern "C" {
#include "calculator.h"
}

#include <gtest/gtest.h>

TEST(Calculator, AddsTwoPositiveNumbers) {
    EXPECT_EQ(calculator_add(2, 3), 5);
}
```

Configure once, and again whenever build definitions change:

```vim
:OverseerShell cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

Build after code changes:

```vim
:OverseerShell cmake --build build
```

Run the complete suite independently of Neotest:

```vim
:OverseerShell ctest --test-dir build --output-on-failure
```

The Ninja commands above are intentionally portable to Windows. If a project
instead selects Visual Studio's multi-configuration generator, omit
`CMAKE_BUILD_TYPE` while configuring and add `--config Debug` to the build plus
`-C Debug` to CTest. See [WINDOWS.md](WINDOWS.md) for exact commands.

After each command has been created once, `<Leader>tl` restarts the latest one.
A fast inner loop is:

1. Edit production code or a test.
2. `<Leader>tl` to rebuild.
3. `<Leader>tn` to run the nearest test.
4. `<Leader>to` to inspect a failure.
5. `<Leader>td` to debug the failing host test.

Neotest-CTest does not compile tests. A successful build and a discoverable
`CTestTestfile.cmake` under the project root must already exist.

### Embedded testing layers

Keep these separate:

1. **Host unit tests:** algorithms, state machines, parsing, validation, and HAL
   behavior through fakes or mocks. Run constantly on the host workstation.
2. **Cross-build:** compile and link the real firmware to catch toolchain,
   linker-script, memory-size, and target-definition problems.
3. **Simulator/emulator tests:** use them when the SDK provides a useful model.
4. **Hardware-in-the-loop tests:** peripherals, interrupts, DMA, timing, and
   physical interfaces. Run fewer of these because feedback is slower.

Keep portable logic separate from hardware implementations, for example:

```text
src/core/          portable production logic
src/hal/           hardware-facing interfaces
src/target/        MCU-specific implementations
tests/host/        GoogleTest tests and fakes
tests/target/      on-device smoke/integration tests
```

Compile `src/core` once for the host test executable and again with the target
toolchain. Do not put startup code, linker scripts, or direct memory-mapped I/O
inside the host unit-test executable.

Wait to register permanent Overseer templates until the actual stack is known:

- Plain CMake: configure, build, clean, and CTest.
- CMake presets: `cmake --preset ...` and `cmake --build --preset ...`.
- Zephyr: `west build`, `west flash`, and Twister/Ztest.
- PlatformIO: `pio run`, `pio test`, and upload tasks.
- ESP-IDF: `idf.py build`, `flash`, `monitor`, and framework test commands.

## Debugging

For a Neotest-managed test, prefer `<Leader>td`; it supplies the executable and
test filter to DAP. During an active debug session:

| Action | Key |
| --- | --- |
| Start or continue | `<F5>` |
| Step into | `<F1>` |
| Step over | `<F2>` |
| Step out | `<F3>` |
| Toggle debug UI | `<F7>` or `<Leader>du` |
| Toggle breakpoint | `<Leader>db` |
| Conditional breakpoint | `<Leader>dB` |
| Open DAP REPL | `<Leader>dr` |

The installed `codelldb` adapter handles common native macOS/Linux and
LLVM/MinGW C/C++ test binaries on Windows. MSVC/PDB projects may require a
different adapter. An embedded target additionally needs its cross-debugger,
probe/server such as OpenOCD or J-Link, and target-specific DAP launch/attach
configuration.

## CodeCompanion and Copilot workflows

### Choose the right interaction

| Need | Start with | Behavior |
| --- | --- | --- |
| Quick suggestion | Blink completion | No chat or file edits |
| Explain or discuss code | `<Leader>an` | New regular Copilot chat |
| Reopen/hide current chat | `<Leader>ac` | Toggles regular chat window |
| Discover built-in prompts | `<Leader>aa` | Action palette |
| Edit selection | Select, then `<Leader>ai` | Accept/reject inline diff |
| Discuss selected code | Select, then `<Leader>as` | Add to current chat |
| Multi-file autonomous task | `<Leader>aA` | Copilot CLI through ACP |
| Review files touched by AI | `<Leader>ar` | Opens changed files in quickfix |

### Regular chat

Use regular chat for reasoning, questions, reviews, and tightly scoped changes.
Inside a chat buffer:

| Action | Key |
| --- | --- |
| Show all chat mappings | `?` |
| Send from Normal mode | `<CR>` or `<C-s>` |
| Send from Insert mode | `<C-s>` |
| Stop the current response | `q` |
| Close chat | `<C-c>` |
| Regenerate last response | `gr` |
| Change adapter/model | `ga` |
| Inspect messages, adapter settings, and context | `gd` |
| Show Copilot usage statistics | `gS` |
| Add a message while tools are running | `gm` |
| Sync all of a pinned buffer each turn | `gba` |
| Sync only a pinned buffer's diff | `gbd` |
| Reset this chat's cached tool approvals | `gtx` |
| Yank the last code block | `gy` |
| Fold chat code blocks | `gf` |
| Next/previous response header | `]]` / `[[` |
| Next/previous chat | `}` / `{` |
| Clear chat | `gx` |

The meanings of `ga`, `gS`, and similar mappings above are buffer-local to a
CodeCompanion chat. Outside chat, the normal editing mappings still apply.

### Give regular chat explicit context

Type `#` in a chat for editor-context completion, `/` for a context command,
and `@` for HTTP tools or tool groups.

Useful context references:

```text
#{buffer}       Current/most recent code buffer; diff-synced by default
#{buffer}{all}  Keep sharing the complete current buffer
#{buffers}      All currently open normal buffers
#{selection}    Most recent visual selection
#{diagnostics}  Current buffer's LSP diagnostics
#{diff}         Staged and unstaged Git diff
#{quickfix}     Current quickfix contents
#{terminal}     Recent output from the latest terminal
#{viewport}     Code currently visible on screen
```

Useful slash commands:

```text
/file      Select one or several files from the working directory
/buffer    Select one or several already-open buffers
/symbols   Add a compact Tree-sitter outline instead of a full file
/compact   Replace old conversation turns with a summary
/resume    Resume a supported ACP session; use in a fresh chat
/mode      Change a mode advertised by an ACP agent
/acp_session_options  Change advertised ACP model/reasoning options
```

In the Telescope `/file` picker, `<CR>` chooses one file and `<Tab>` marks
multiple files. You do not need to open files as buffers before `/file` can add
them. `#{buffers}`, by definition, only includes buffers that are already open.

Do not manually type XML-like text such as `<file>path</file>` and expect it to
load a file. Use `/file`, `#{buffer:path}`, or an agent with filesystem tools.

The regular Copilot adapter can also become a CodeCompanion tool-agent when the
model supports tool calling:

```text
@{agent} Inspect this repository and explain its configuration structure.
Cite the relevant paths.
```

`@{agent}` provides file search, grep, file reading/editing, diagnostics, and
command tools rooted at Neovim's current working directory. Check `:pwd` if it
cannot find files. This tool group belongs to regular HTTP chat; it is not needed
inside the Copilot CLI ACP chat, which already has its own agent tools.

### Inline edits

1. Select the smallest useful region in Visual mode.
2. Press `<Leader>ai`.
3. Describe the transformation.
4. Inspect the resulting diff.
5. Press `gda` to accept or `gdr` to reject it.
6. Format and test afterward.

Use inline edit for one coherent region. Switch to the ACP agent when a change
requires discovering or coordinating several files.

### Copilot CLI ACP agent

Start Neovim at the repository root, verify it with `:pwd`, then press
`<Leader>aA`. Unlike regular chat, this starts the installed `copilot` CLI as a
stateful Agent Client Protocol session. It can discover files without opening
them as buffers, read and edit the repository, and request commands through its
own approval system.

A strong initial prompt contains four parts:

```text
Goal: Implement <specific outcome>.
Scope: Work only in <directories/components>.
Constraints: Preserve <API/style/behavior>; do not change <excluded areas>.
Verification: Run <formatter/build/tests> and summarize changed files and risks.
First inspect the repository and relevant existing patterns before editing.
```

Use this agent loop:

1. Ask for a concrete outcome, constraints, and verification—not vague
   “improvements.”
2. Read tool approvals before accepting them. Prefer one-time approval when
   learning a workflow.
3. Interrupt with `q` if it is heading in the wrong direction.
4. Ask it to run focused tests, then the relevant broader suite.
5. Press `<Leader>ar` to inspect every file CodeCompanion tracked as changed.
6. Press `<Leader>gd` for the authoritative Git diff.
7. Run formatting, build, and tests yourself.
8. Commit through Neogit only after the diff and tests are satisfactory.

Avoid approval-bypass or “YOLO” modes while learning. Agent access does not
replace Git review, tests, or understanding what will be committed.

### Model, reasoning, and context information

Inside chat:

- `ga` shows the selectable adapter and models exposed to CodeCompanion.
- `/acp_session_options` shows model/reasoning options advertised by an ACP
  agent, when supported.
- `gd` opens the exact chat debug data: adapter, schema/settings, message
  history, and attached context.
- `gS` shows Copilot usage statistics.

The provider may not expose a trustworthy maximum context-window size or every
server-side routing decision. If it is absent from `gd` and the ACP session
options, treat it as provider-managed rather than inferring a number.

### Review AI changes

`<Leader>ar` runs `:CodeCompanionChat Changes`, collecting files touched by
CodeCompanion into quickfix. Navigate them with `]q` and `[q`. This is a useful
first pass, but it is session tracking rather than Git's final truth.

Always finish with:

```text
<Leader>gd   Review all repository changes
<Leader>tR   Choose a configured project task, or use :OverseerShell
<Leader>tn   Run a focused test
<Leader>gg   Stage only intended changes, commit, and push
```

## Sessions

Sessions are saved automatically when at least one real file buffer is open,
with separate layouts per Git branch. Restoration remains explicit:

| Action | Key |
| --- | --- |
| Restore this directory/branch session | `<Leader>qs` |
| Select a saved session | `<Leader>qS` |
| Restore the most recent session | `<Leader>ql` |
| Do not save this session on exit | `<Leader>qd` |

Prefer `<Leader>qs` after starting `nvim .` in a familiar project. Use
`<Leader>qd` for temporary inspections you do not want persisted.

## Configuration maintenance and troubleshooting

| Need | Command |
| --- | --- |
| Search this configuration | `<Leader>sn` |
| Search all mappings | `<Leader>sk` |
| Read help | `:help <topic>` |
| Run built-in tutorial | `:Tutor` |
| Check all integrations | `:checkhealth` |
| Check this config's host requirements | `:checkhealth kickstart` |
| Inspect/install external tools | `:Mason` |
| Check formatter for current buffer | `:ConformInfo` |
| Inspect current filetype | `:set filetype?` |
| Inspect active LSP clients | `:LspInfo` |
| Update plugins interactively | `:lua vim.pack.update()` |
| Inspect plugin state offline | `:lua vim.pack.update(nil,{offline=true})` |

Configuration ownership:

| Area | File |
| --- | --- |
| Defaults and indentation | `lua/config/options.lua` |
| General mappings | `lua/config/keymaps.lua` |
| Platform/build capabilities | `lua/config/platform.lua` |
| Navigation/search | `lua/plugins/navigation.lua` |
| Git | `lua/plugins/git.lua` |
| Copilot completion backend | `lua/plugins/copilot.lua` |
| Completion/snippets | `lua/plugins/completion.lua` |
| LSP and Mason tools | `lua/plugins/lsp.lua` |
| Formatting and linting | `lua/plugins/formatting.lua` |
| Markdown and AI rendering | `lua/plugins/markdown.lua` |
| CodeCompanion/ACP | `lua/plugins/ai.lua` |
| Debugging | `lua/plugins/debugging.lua` |
| Testing/tasks | `lua/plugins/testing.lua` |
| Sessions | `lua/plugins/sessions.lua` |

The same tracked Lua files work on native Windows, macOS, Linux, and WSL, but
generated plugins, parsers, Mason tools, and authentication state are local to
each operating system. Follow [WINDOWS.md](WINDOWS.md) before the first native
Windows launch; it also covers PowerShell, clipboard, Yazi, Copilot, CMake, and
the BCORNE Ctrl-versus-GUI modifier caveat.

## Habit-building plan

Do not try to memorize everything at once.

### Days 1–3: movement and feedback

Use only these until automatic:

```text
<Leader>sf       find file
<Leader>sg       search project
<Leader><Leader> switch buffer
s                jump visibly
grd / grr        definition / references
<Leader>f        format
<Leader>xX       buffer diagnostics
```

### Days 4–7: tests and tasks

Add:

```text
<Leader>tn       nearest test
<Leader>tf       test file
<Leader>to       test output
<Leader>td       debug nearest
<Leader>tR       choose task
<Leader>tl       repeat latest task
```

### Week 2: disciplined Git

Add:

```text
]c / [c          navigate hunks
<Leader>hp       preview hunk
<Leader>hs       stage hunk
<Leader>gd       review full diff
<Leader>gg       commit/push in Neogit
```

### Week 3: deliberate AI use

Practice one interaction at a time:

```text
<C-y>            accept a completion
<Leader>an       ask/discuss in regular chat
<Leader>ai       transform a visual selection
<Leader>aA       delegate a scoped multi-file task
<Leader>ar       inspect AI-touched files
```

End every AI task with the same non-AI review, build, test, and Git loop. That
repetition is what turns the setup into a dependable workflow rather than a
collection of plugins.
