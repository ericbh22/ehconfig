# ehconfig

Eric's portable Mac terminal setup, refreshed from the working Mac on **25 November 2026**. The repo keeps reusable configuration and setup steps; applications, accounts and project data are installed or restored separately.

## New MacBook setup

These commands are intended to run on the **new** MacBook. Keep the checkout at a permanent path because configuration files will link into it.

1. Install Apple's Command Line Tools if `xcode-select -p` reports that they are missing:

   ```sh
   xcode-select --install
   ```

2. Install [Homebrew](https://brew.sh/) using its official instructions. Follow the shell environment instructions printed by its installer. Homebrew normally uses `/opt/homebrew` on Apple Silicon or `/usr/local` on Intel; the shell files support both.

3. Clone and review the configuration:

   ```sh
   mkdir -p "$HOME/dev"
   git clone https://github.com/ericbh22/ehconfig.git "$HOME/dev/ehconfig"
   cd "$HOME/dev/ehconfig"
   cat Brewfile
   brew bundle --file=Brewfile
   ```

   `Brewfile` installs Git/LFS, Starship, zoxide, eza, fzf, tmux, sesh, uv, two zsh plugins, Ghostty, GitHub Desktop and Codex. Homebrew resolves their dependencies. It is a selected daily environment rather than a dump of every installed formula.

4. Install Oh My Zsh and the tmux plugin manager if absent. These clones do not replace existing installations:

   ```sh
   if [ ! -e "$HOME/.oh-my-zsh" ]; then
     git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
   fi
   if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
     git clone https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
   fi
   ```

   Autosuggestions and syntax highlighting come from Homebrew, so separate Oh My Zsh custom-plugin clones are unnecessary.

5. Preview the links, then apply them:

   ```sh
   ./bootstrap.sh --dry-run
   ./bootstrap.sh
   ```

   Existing conflicting files, directories or symlinks are **moved into a backup**, not deleted. The output gives each backup path under `~/.local/state/ehconfig/backups/`. Re-running the script skips correct links. The script does not install packages, start services or reload applications. It writes these seven links:

   | Source | Destination |
   |---|---|
   | `zshrc` | `~/.zshrc` |
   | `zprofile` | `~/.zprofile` |
   | `gitconfig` | `~/.gitconfig` |
   | `tmux.conf` | `~/.tmux.conf` |
   | `starship.toml` | `~/.config/starship.toml` |
   | `aerospace.toml` | `~/.config/aerospace/aerospace.toml` |
   | `ghostyconfig` | `~/Library/Application Support/com.mitchellh.ghostty/config` |

   The historical `ghostyconfig` filename is intentional. On this Mac, that platform-specific Ghostty path already links to the active configuration. The bootstrap uses that same location; it does not create a second XDG Ghostty config.

6. Open a fresh terminal. Start tmux and press its default **Ctrl-b, then Shift-i** to install the declared TPM plugins. The tmux configuration enables mouse support, one-based windows/panes, sesh selection with **Ctrl-b, then Shift-k**, and session restoration through resurrect/continuum. Without TPM installed it still loads its basic settings. Session snapshots are not transferred by this repo.

## Current preferences

- **zsh:** Oh My Zsh's Git plugin, Homebrew autosuggestions/syntax highlighting, Starship and zoxide. The eza `ls` alias is disabled, matching the current Mac.
- **PATH:** Homebrew, `~/.local/bin`, GHCup, optional SplashKit, optional Python.org 3.13 and JetBrains Toolbox scripts. Missing optional tools are skipped. The old username-specific paths have been removed.
- **Ghostty:** Catppuccin Mocha, transparent titlebar, decorations, centered 80% quick terminal on Cmd-backquote, 0.8 opacity, block cursor and Shift-Enter escape/carriage-return sequence. Repeated template fragments and malformed duplicate keybindings from the old tracked file have been removed. Clipboard read/write remain allowed, matching the working configuration.
- **Starship:** the current multicolour Powerline prompt, including Git status, language modules and time. If your terminal font lacks the displayed symbols, install/select a Nerd Font; for example `brew install --cask font-jetbrains-mono-nerd-font`, then select that font in your terminal. No font files are copied into this repo.
- **Git:** current Eric Huang/Monash identity, LFS filters and `submodule.recurse=false`. Review the identity before use. Add work identities or credential helpers to `~/.gitconfig.local`, which is included after the shared settings.
- **AeroSpace:** the existing tiling configuration with 10-pixel gaps and Alt-based focus/workspace bindings; start-at-login remains disabled. The app itself is optional.

### Optional Ghostty cursor shader

The working Mac also uses `cursor_warp.glsl` from [sahaj-b/ghostty-cursor-shaders](https://github.com/sahaj-b/ghostty-cursor-shaders), currently at commit `06d4e90fb5410e9c4d0b3131584060adddf89406`. The shader is not vendored here. To reproduce the effect, clone it on the new Mac:

```sh
git clone https://github.com/sahaj-b/ghostty-cursor-shaders.git \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/shaders"
git -C "$HOME/Library/Application Support/com.mitchellh.ghostty/shaders" \
  checkout 06d4e90fb5410e9c4d0b3131584060adddf89406
```

Then uncomment `custom-shader` and `custom-shader-animation` in `ghostyconfig`. If a shaders directory already exists, inspect/reuse it rather than cloning over it. The base configuration intentionally works without the shader checkout.

## Optional development and desktop packages

Review these manifests and install only the tools needed on the other MacBook:

```sh
brew bundle --file=Brewfile.dev
brew bundle --file=Brewfile.apps
```

`Brewfile.dev` captures explicitly selected course/development tools: Bash, LLVM/CMake, Node 22, MPI, QEMU/RISC-V, GHCup, Python 3.11, Java 21, graphing/document tools and SDL/OpenCV. `Brewfile.apps` records the current optional Homebrew desktop apps. These lists install their current available releases; they are not a byte-for-byte version lock of the old machine.

### Haskell

The current GHCup selections are GHC 9.10.3, HLS 2.14.0.0, Cabal 3.16.1.0, Stack 3.11.1 and Fourmolu 0.20.0.0. After installing GHCup, recreate the course toolchain when needed:

```sh
ghcup config add-release-channel 3rdparty
ghcup install ghc 9.10.3 --set
ghcup install hls 2.14.0.0 --set
ghcup install cabal 3.16.1.0 --set
ghcup install stack 3.11.1 --set
ghcup install fourmolu 0.20.0.0 --set
```

Keep each project's Stack snapshot and package versions in that project. The dotfiles do not replace its lock/config files.

### Python, Node, Conda and applications outside Homebrew

- The current Mac also has Python.org Python 3.13 and Node 22.13.1 from separate installers. `Brewfile.dev` uses the maintained Node 22 Homebrew formula; `zprofile` includes its keg-only path when present.
- For a project requiring Python 3.13, `uv python install 3.13` and `uv venv --python 3.13` create the appropriate local interpreter/environment. Do not assume plain `python3` selects that version. Recreate environments from project dependencies instead of copying `.venv` directories.
- Conda is a separate Anaconda installation on the current Mac. Install a distribution appropriate for the new Mac's architecture if needed; `zshrc` discovers the existing `/opt/anaconda3`, `~/anaconda3` or `~/miniconda3` executable. Recreate Conda environments from their project/environment manifests.
- Reinstall VS Code/JetBrains and restore chosen editor settings/extensions through their normal sync or export mechanisms. This repo does not export editor sessions or credential-bearing settings.
- Obsidian, Herdr and other manually installed apps need their own installers/data migration. Sign into Codex and other apps normally. Recreate their CLI links using their installers; `~/.local/bin` contains generated links into app-managed directories, including a temporary Python 3.12 link that must not be copied to the new machine.

## Local overrides and private migration

Use `~/.zshrc.local`, `~/.zprofile.local` and `~/.gitconfig.local` for local additions. They are not managed by bootstrap. In particular, restore the current Mac's custom SSH host alias through your private `~/.ssh/config` or `.zshrc.local` rather than committing a server address/key path here.

SSH keys/config, account tokens, `.env` files, Codex authentication/history, app state, browser profiles, shell history and tmux session snapshots are deliberately excluded. Authenticate GitHub/GitLab separately and transfer project secrets through your normal private mechanism. LinearMouse's existing rule identifies the old Mac's trackpad hardware, so configure the preferred scrolling direction on the new device instead of blindly copying that rule.

## Verification and updating

```sh
bash -n bootstrap.sh
zsh -n zshrc
zsh -n zprofile
git config --file gitconfig --list
./bootstrap.sh --dry-run
```

With Ghostty installed, validate using its binary (normally `/Applications/Ghostty.app/Contents/MacOS/ghostty`):

```sh
ghostty +validate-config --config-file="$PWD/ghostyconfig"
```

After installation, open a fresh Ghostty window; check prompt glyphs, autosuggestions, highlighting and `z` navigation. Check `command -v brew starship zoxide tmux sesh uv`, `git lfs version`, the quick-terminal shortcut and the tmux session picker. Allow any required macOS accessibility permissions through System Settings.

For isolated bootstrap verification without replacing the current account's files, use `./bootstrap.sh --target-home /absolute/path/to/a/test-directory`. The flag selects only the link/backup destination; it does not rewrite your account's `HOME` environment or simulate installed applications.

Edits made through managed symlinks change this checkout. Review `git diff`, keep secrets in local overrides, then commit/push the intended changes before pulling them on the other Mac. If moving the checkout, rerun bootstrap from its new location to back up and replace the old links. To roll back an installation, restore the desired files from the backup paths printed by bootstrap.
