# dotfiles

Cross-platform CLI environment for macOS, Pop!_OS, Arch (Omarchy), and Fedora — managed with [chezmoi](https://www.chezmoi.io), [mise](https://mise.jdx.dev), and a thin OS-native package layer. Goal: `git clone → bootstrap → done` in under 10 minutes on a fresh machine.

## Quickstart on a new machine

```sh
# 1. Install chezmoi (only prerequisite)
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 2. Initialize, fetch, and apply this repo
~/.local/bin/chezmoi init --apply peterulsteen/dotfiles

# 3. On first run, you'll be prompted for: name, email, signingkey path, isPersonal.
#    Those values are stored in ~/.config/chezmoi/chezmoi.toml (NOT in this repo).

# 4. Set fish as the login shell
echo (which fish) | sudo tee -a /etc/shells
chsh -s (which fish)
```

That's it. Chezmoi runs the bootstrap scripts automatically — installing the OS-native package manager (or its packages on Linux), the self-managing tools (`mise`, `uv`, `rustup`, `claude`), and then `mise install` to materialize every CLI tool and language runtime, plus `codex` via `npm install -g`.

## Architecture: the three-layer ownership model

Tools fall into exactly one of three layers, picked by who owns *upgrades*:

| Layer | Owner | Examples | Why |
|---|---|---|---|
| **1. Self-managing** | The tool's own installer / `<tool> self update` | `mise`, `uv`, `rustup`, `claude`, `codex` | Tools that ship fast and have first-class self-update. Bootstrapped once, then left alone. |
| **2. Mise** | `~/.config/mise/config.toml` | `node`, `go`, `terraform`, `opentofu`, `gh`, `lazygit`, `neovim`, `fzf`, `ripgrep`, `jq`, `fd`, `bat`, `eza`, `zoxide`, `atuin`, `starship`, `zellij`, `just`, `direnv`, `delta`, `stylua`, `selene`, `tree-sitter`, `shellcheck`, `actionlint`, `tealdeer` | Cross-platform single-binary tools and language runtimes. One declarative file works on all four OSs. |
| **3. Native pkg mgr** | `brew` / `apt` / `pacman` / `dnf` | `fish` (login shell), `ghostty`, `gnupg`, `podman`, `podman-compose`, fonts, `coreutils`, `gnu-getopt`, `vault`, `awscli`, `pass` | Tools that need OS integration: login shells, terminal emulators, system crypto, daemons, GUI apps, fonts. |

The hard rule: **a tool gets exactly one layer.** Never `claude` in both `~/.local/bin` and a Brewfile. Never `node` in both mise and brew. Never `rust` in mise (rustup owns it).

### Per-language runtime managers

| Language | Manager | Notes |
|---|---|---|
| TypeScript / JavaScript | `mise` for Node; `corepack` for pnpm/yarn/npm | `corepack enable` after Node install — pnpm version follows each repo's `packageManager` field |
| Python | `uv` | Owns Python install, venvs, packages, and CLI tools (`uv tool install` replaces pipx) |
| Go | `mise` | |
| Rust | `rustup` | Per-project pinning via `rust-toolchain.toml` |
| Lua | None | Use the LuaJIT shipped with Neovim; install Lua dev tools (stylua, selene, lua-language-server) via mise |

## Containers

| Machine | Engine | Compose |
|---|---|---|
| All | `podman` | `podman compose` |

A `docker` → `podman` alias is set in fish so muscle-memory `docker` commands work. On macOS, `podman machine init && podman machine start` is a one-time setup the bootstrap handles for you.

## Terminal sessions (Zellij)

[Zellij](https://zellij.dev) (Layer 2 / mise) is the terminal multiplexer, configured for **session resurrection** so a reboot doesn't lose your workspace:

- `config.kdl` is a *minimal override* (not a `clear-defaults` dump) — upstream default improvements still flow through on upgrade.
- `session_serialization` + `serialize_pane_viewport` persist each session's tabs, panes, cwds, running commands, and on-screen scrollback to the local cache dir. After a reboot, `zellij ls` shows the session as `EXITED`; resurrect it from the session manager (`Ctrl+o` then `w`) to rebuild the layout and re-run each pane's command.
- fish auto-attaches to a persistent `main` session on interactive shells (guarded against nesting inside Zellij, VS Code/Cursor, JetBrains, and non-interactive shells; opt out per-shell with `set -gx ZELLIJ_NO_AUTOSTART 1`).
- `layouts/claude.kdl` (`zellij --layout claude`) opens a Claude Code pane via `claude --continue` so resurrection resumes the prior conversation; plus `edit` (nvim) and `shell` tabs.
- **Neovim ⇄ Zellij navigation:** `Ctrl+h/j/k/l` moves across both Neovim splits and Zellij panes via [vim-zellij-navigator](https://github.com/hiasr/vim-zellij-navigator) (Zellij side, fetched by URL) + [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) (Neovim side).

> **Privacy note:** `serialize_pane_viewport true` writes terminal *contents* to the local cache dir (`~/.cache/zellij` on Linux, `~/Library/Caches/org.Zellij-Contributors.Zellij` on macOS). It is local-only — never synced, never in this repo — but it is plaintext on disk; `scrollback_lines_to_serialize` caps how much.

## What's in this repo

```
.
├── README.md                                  This file
├── CLAUDE.md                                  Instructions for Claude Code working in this repo
├── .chezmoiignore                             Per-OS file exclusions (templated)
├── Brewfile.darwin.tmpl                       macOS Homebrew formulas + casks
├── packages/
│   ├── arch.txt                               pacman package list
│   ├── debian.txt                             apt package list (Pop!_OS, Ubuntu)
│   └── fedora.txt                             dnf package list
├── dot_config/                                → ~/.config/
│   ├── fish/                                  fish shell config (config.fish + conf.d/)
│   ├── ghostty/                               terminal emulator config
│   ├── git/
│   │   ├── config.tmpl                        git config (templated for per-machine email/signing)
│   │   └── ignore                             global gitignore
│   ├── mise/config.toml.tmpl                  mise tools manifest
│   ├── nvim/                                  Neovim (LazyVim)
│   ├── starship/starship.toml                 prompt config
│   └── zellij/                                terminal multiplexer (config.kdl + layouts/)
├── run_once_before_10-install-package-managers.sh.tmpl
├── run_once_before_20-install-self-managers.sh.tmpl
├── run_onchange_30-mise-install.sh.tmpl
└── run_once_after_40-macos-defaults.sh.tmpl   (mac-only)
```

## OS support matrix

| OS | Package manager | Status |
|---|---|---|
| macOS (Apple Silicon, work-issued) | Homebrew | Primary |
| Pop!_OS (Linux, personal ThinkPad) | apt | Supported |
| Omarchy / Arch Linux | pacman | Supported |
| Fedora | dnf | Supported |

Per-OS divergence is handled with chezmoi templates (`{{ if eq .chezmoi.os "darwin" }}`) and `.chezmoiignore` rules. The list is intentionally small — most config and most tools are identical across OSs.

## Secrets

This repo is public. **No secrets, credentials, or private keys live in here.** SSH keys, AWS configs, GnuPG keyrings, and 1Password vaults are managed out-of-band. Per-machine bits that vary (git signing-key path, work email vs. personal email) are handled by chezmoi templates that read from prompted values stored in `~/.config/chezmoi/chezmoi.toml`, not committed to the repo.

On personal Linux machines, `1password-cli` is installed and used as the secrets source. On the work-issued macOS laptop, secrets are managed manually with strict separation from personal accounts.

## Updating

```sh
# Pull latest dotfiles changes from GitHub
chezmoi update

# Update self-managing tools
mise self-update
uv self update
rustup update
claude update
codex update     # if applicable

# Update mise-managed tools
mise upgrade

# Update OS-native packages
brew upgrade                     # macOS
sudo apt update && sudo apt upgrade   # Pop!_OS
sudo pacman -Syu                 # Arch / Omarchy
sudo dnf upgrade                 # Fedora
```

## Customizing for forkers

This repo reflects one person's preferences. If you fork it:
- Edit `dot_config/mise/config.toml.tmpl` to change the tool list
- Edit `Brewfile.darwin.tmpl` and `packages/*.txt` to change OS-native packages
- The three-layer model (above) is the principle worth keeping; the specific tools are personal taste

## Inspiration

- chezmoi's [docs](https://www.chezmoi.io/quick-start/)
- mise's [cookbook](https://mise.jdx.dev/configuration.html)
- The [dotfiles community](https://dotfiles.github.io/)

## License

MIT — see `LICENSE`.
