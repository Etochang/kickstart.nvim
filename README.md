# Personal Neovim configuration

## Introduction

A productivity-focused Neovim configuration based on kickstart.nvim that is:

* Small
* Modular
* Completely Documented

**NOT** a Neovim distribution: each plugin and behavior remains explicit and
easy to change.

### Configuration layout

`init.lua` is intentionally a short, ordered entry point. Core editor behavior
lives in `lua/config/`, plugin setup lives in topic-based files under
`lua/plugins/`, and machine- or workflow-specific additions belong in
`lua/custom/plugins/`.

```text
init.lua                 Load order and orientation
lua/config/options.lua   Editor defaults and diagnostics
lua/config/keymaps.lua   Plugin-independent mappings
lua/config/autocmds.lua  Editor events
lua/config/pack.lua      vim.pack helpers and build hooks
lua/config/platform.lua  OS capabilities and native build selection
lua/plugins/*.lua        UI, navigation, Git, LSP, formatting, and tools
lua/custom/plugins/      Personal extensions loaded automatically
```

The files retain descriptive comments so the configuration remains useful as
a learning reference without forcing every subsystem into one large file.

## Installation

### Install Neovim

This configuration requires **Neovim 0.12 or newer** because it uses
`vim.pack` and nvim-treesitter's current `main` branch. Install the current
[stable or nightly release](https://github.com/neovim/neovim/releases) and
verify it with `nvim --version`. If a distribution package is too old, use one
of the [alternative installation methods](#alternative-neovim-installation-methods).

### Install External Dependencies

Core requirements:

* `git`, `curl`, `tar`, a C/C++ compiler, and
  [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
* [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md#installation)
  0.26.1 or newer; install it from a package manager or prebuilt release, not npm
* [fd](https://github.com/sharkdp/fd#installation), which is optional but makes
  file finding faster
* Node.js 22 or newer for Copilot completion and npm-backed Mason tools
* Python 3 with pip/venv for Python-backed Mason tools and tests
* A [Nerd Font](https://www.nerdfonts.com/), which is optional but supplies icons
  (set `vim.g.have_nerd_font` in `init.lua` to `true` after installing one)

Workflow-specific requirements:

* PowerShell plus 7-Zip or an equivalent extractor on Windows for Mason
* CMake/Make for Telescope's optional native sorter; Telescope falls back safely
  when neither exists
* Python/pytest for Python testing, and CMake/Ninja/GoogleTest for C/C++ testing
* `copilot`, `yazi`/`ya`, and `sqlite3` for the corresponding optional workflows

Language-specific servers, debuggers, linters, and formatters are installed
through Mason when available. Other SDKs (`go`, Rust, an embedded cross-
toolchain, and so on) remain project dependencies.

* [Native Windows setup and caveats](WINDOWS.md)
* [Everyday command and workflow reference](WORKFLOWS.md)

> [!NOTE]
> See [Windows setup](WINDOWS.md) or the
> [install recipes](#install-recipes) for platform-specific notes.

### Install Kickstart

> [!NOTE]
> [Back up](#faq) your previous configuration (if any exists).

Neovim's configuration is located under the following paths, depending on the
operating system:

| OS | PATH |
| :- | :--- |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd) | `%localappdata%\nvim\` |
| Windows (PowerShell) | `$env:LOCALAPPDATA\nvim\` |

#### Recommended Step

Create your own copy of this repo using GitHub's
["Use this template"](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
button so that you have your own copy that you can modify, then install by
cloning your new repo to your machine using one of the commands below,
depending on your OS.

Alternatively, you can [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
this repo if you prefer an easy upstream sync path (e.g., keeping your config
on a separate branch and fast-forwarding `master` from upstream). See the
[discussion in #1740](https://github.com/nvim-lua/kickstart.nvim/issues/1740)
for the tradeoffs between the two approaches.

> [!NOTE]
> Your repo's URL will be something like this:
> `https://github.com/<your_github_username>/kickstart.nvim.git`

You likely want to remove `nvim-pack-lock.json` from your repo's `.gitignore`
file too - it's ignored in the kickstart repo to make maintenance easier, but
it's recommended to track it in version control (see `:help vim.pack-lockfile`).

#### Clone kickstart.nvim

> [!NOTE]
> If following the recommended step above (i.e., creating your own repo from
> the template or fork), replace `nvim-lua` with `<your_github_username>`
> in the commands below

<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/nvim-lua/kickstart.nvim.git "%localappdata%\nvim"
```

If you're using `powershell.exe`

```
git clone https://github.com/nvim-lua/kickstart.nvim.git "${env:LOCALAPPDATA}\nvim"
```

</details>

### Post Installation

Start Neovim

```sh
nvim
```

That's it! `vim.pack` will install all the plugins from your config. Use
`:lua vim.pack.update(nil, { offline = true })` to inspect plugin state and
`:lua vim.pack.update()` to fetch updates (`:write` applies updates, `:quit`
cancels them).

#### Read The Friendly Documentation

Start with `init.lua`, then follow the documented modules under `lua/config/`
and `lua/plugins/` for more information about extending and exploring Neovim.

> [!NOTE]
> For more information about a particular plugin check its repository's documentation.


### Getting Started

[The Only Video You Need to Get Started with Neovim](https://youtu.be/m8C0Cq9Uv9o)

### FAQ

* What should I do if I already have a pre-existing Neovim configuration?
  * Rename the existing configuration and data directories so the backup stays
    recoverable. On Unix these are usually `~/.config/nvim` and
    `~/.local/share/nvim`; on Windows they are usually
    `$env:LOCALAPPDATA\nvim` and `$env:LOCALAPPDATA\nvim-data`.
* Can I keep my existing configuration in parallel to kickstart?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, you can install the kickstart
    configuration in `~/.config/nvim-kickstart` and create an alias:

    ```sh
    alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
    ```

    When you run Neovim using `nvim-kickstart` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-kickstart`. You can apply this approach to any Neovim
    distribution that you would like to try out.
    In PowerShell, the equivalent setting lasts for the remainder of that
    PowerShell session:

    ```powershell
    $env:NVIM_APPNAME = 'nvim-kickstart'
    nvim
    Remove-Item Env:NVIM_APPNAME
    ```
* What if I want to "uninstall" this configuration:
  * Remove your config directory and local data directory (for example,
    `~/.config/nvim` and `~/.local/share/nvim`).
* Why is this configuration split into modules?
  * Topic-based modules keep related options, explanations, and mappings close
    together while leaving `init.lua` as a readable map of the whole setup.

### Install Recipes

Below you can find OS specific install instructions for Neovim and dependencies.

After installing all the dependencies continue with the [Install Kickstart](#install-kickstart) step.

#### Windows Installation

Use the dedicated [native Windows guide](WINDOWS.md). It covers WinGet
dependencies, PowerShell, Tree-sitter, Copilot, Yazi, native build tools,
testing, WSL separation, and keyboard/terminal caveats. The configuration now
selects Telescope's CMake build automatically on native Windows; it no longer
needs a Windows-only edit to `init.lua`.

<details><summary>WSL (Windows Subsystem for Linux)</summary>

Treat WSL as a separate Linux machine. Install the config and all generated
plugins, parsers, Mason tools, and Copilot authentication inside WSL; do not
share the native Windows `nvim-data` directory.

```
wsl --install
wsl
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep fd-find unzip git xclip curl tar neovim
```

Package versions vary by WSL distribution. Also install Node.js 22+ and
tree-sitter CLI 0.26.1+ using the verified methods in
[External Dependencies](#install-external-dependencies), then confirm both with
`node --version` and `tree-sitter --version` before the first launch.
</details>

#### Linux Install
<details><summary>Ubuntu Install Steps</summary>

```
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep fd-find tree-sitter-cli unzip git xclip neovim
```
</details>
<details><summary>Debian Install Steps</summary>

```
sudo apt update
sudo apt install make gcc ripgrep fd-find tree-sitter-cli unzip git xclip curl

# Now we install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# make it available in /usr/local/bin, distro installs to /usr/bin
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
```
</details>
<details><summary>Fedora Install Steps</summary>

```
sudo dnf install -y gcc make git ripgrep fd-find tree-sitter-cli unzip neovim
```
</details>

<details><summary>Arch Install Steps</summary>

```
sudo pacman -S --noconfirm --needed gcc make git ripgrep fd tree-sitter-cli unzip neovim
```
</details>

### Alternative neovim installation methods

For some systems it is not unexpected that the [package manager installation
method](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package)
recommended by neovim is significantly behind. If that is the case for you,
pick one of the following methods that are known to deliver fresh neovim versions very quickly.
They have been picked for their popularity and because they make installing and updating
neovim to the latest versions easy. You can also find more detail about the
available methods being discussed
[here](https://github.com/nvim-lua/kickstart.nvim/issues/1583).


<details><summary>Bob</summary>

[Bob](https://github.com/MordechaiHadad/bob) is a Neovim version manager for
all platforms. Simply install
[rustup](https://rust-lang.github.io/rustup/installation/other.html),
and run the following commands:

```bash
rustup default stable
rustup update stable
cargo install bob-nvim
bob use stable
```

</details>

<details><summary>Homebrew</summary>

[Homebrew](https://brew.sh) is a package manager popular on Mac and Linux.
Simply install using [`brew install`](https://formulae.brew.sh/formula/neovim).

</details>

<details><summary>Flatpak</summary>

Flatpak is a package manager for applications that allows developers to package their applications
just once to make it available on all Linux systems. Simply [install flatpak](https://flatpak.org/setup/)
and setup [flathub](https://flathub.org/setup) to [install neovim](https://flathub.org/apps/io.neovim.nvim).

</details>

<details><summary>asdf and mise-en-place</summary>

[asdf](https://asdf-vm.com/) and [mise](https://mise.jdx.dev/) are tool version managers,
mostly aimed towards project-specific tool versioning. However both support managing tools
globally in the user-space as well:

<details><summary>mise</summary>

[Install mise](https://mise.jdx.dev/getting-started.html), then run:

```bash
mise plugins install neovim
mise use neovim@stable
```

</details>

<details><summary>asdf</summary>

[Install asdf](https://asdf-vm.com/guide/getting-started.html), then run:

```bash
asdf plugin add neovim
asdf install neovim stable
asdf set neovim stable --home
asdf reshim neovim
```

</details>

</details>
