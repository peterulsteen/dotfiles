# dotfiles

My cross-platform CLI environment — one `git clone` away from a working setup on macOS, Pop!_OS, Arch (Omarchy), or Fedora. I manage it with [chezmoi](https://www.chezmoi.io) for the dotfiles, [mise](https://mise.jdx.dev) for tools and runtimes, and a thin OS-native package layer for the handful of things that genuinely need it.

I used to run this as a Nix/home-manager flake (it's still here, further down the git history). I bounced off it — I was spending more time fighting Nix than using my tools. This is the pragmatic replacement: boring, fast, and identical on every machine. My bar is **`git clone` → bootstrap → working in ~10 minutes** on a fresh box.

If you're just passing through: help yourself to anything useful. The ideas are more reusable than the specific tool choices, which are entirely my taste.

## Quickstart on a new machine

```sh
# 1. Install chezmoi (the only prerequisite)
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 2. Initialize, fetch, and apply this repo
~/.local/bin/chezmoi init --apply peterulsteen/dotfiles

# 3. Set fish as the login shell
echo (which fish) | sudo tee -a /etc/shells
chsh -s (which fish)
```

On first run chezmoi prompts me for a few per-machine values — name, email, signing-key path, whether the machine is personal, and where my work repos live. They get written to `~/.config/chezmoi/chezmoi.toml` and never touch this repo.

From there chezmoi runs my bootstrap scripts on its own: it installs the OS-native package manager (or just its packages on Linux), then the self-managing tools (`mise`, `uv`, `rustup`, `claude`), then `mise install` to materialize every CLI and language runtime. `codex` comes in last via `npm install -g`, once mise has provided Node.

> One gotcha I hit: a fresh `mise install` pulls ~25 tools from GitHub releases and will blow through the unauthenticated API rate limit. Before bootstrapping a new machine, `export GITHUB_TOKEN=$(gh auth token)` (or any no-scope PAT). If a tool ever resolves to a bogus `vlatest` tag, that's the poisoned-cache symptom — `mise cache clear` and retry.

## How I organize tools: the three-layer model

This is the decision I keep coming back to. Every tool lives in **exactly one** layer, chosen by who owns its *upgrades*:

| Layer | Who owns upgrades | What lives here | Why |
|---|---|---|---|
| **1. Self-managing** | The tool's own installer / `<tool> self update` | `mise`, `uv`, `rustup`, `claude`, `codex` | Things that ship fast and update themselves well. I bootstrap them once and leave them alone. |
| **2. mise** | `~/.config/mise/config.toml` | `node`, `go`, `terraform`, `opentofu`, `gh`, `lazygit`, `neovim`, `fzf`, `ripgrep`, `jq`, `fd`, `bat`, `eza`, `zoxide`, `atuin`, `starship`, `zellij`, `just`, `direnv`, `delta`, `gitleaks`, `stylua`, `selene`, `tree-sitter`, `shellcheck`, `actionlint`, `tealdeer` | Cross-platform single-binary tools and language runtimes. One declarative file, same on all four OSs. |
| **3. Native pkg mgr** | `brew` / `apt` / `pacman` / `dnf` | `fish` (login shell), `ghostty`, `gnupg`, `podman`, `podman-compose`, fonts, `coreutils`, `gnu-getopt`, `vault`, `awscli`, `google-cloud-cli`, `pass` | Things that need real OS integration: login shells, terminal emulators, system crypto, daemons, GUI apps, fonts. |

My one hard rule: **a tool gets exactly one layer.** No `claude` in both `~/.local/bin` and a Brewfile, no `node` in both mise and brew, no `rust` in mise (rustup owns it). When two layers fight over the same tool, I get silent drift — so I don't let them.

### Per-language runtimes

| Language | Manager | Notes |
|---|---|---|
| TypeScript / JavaScript | `mise` for Node; `corepack` for pnpm/yarn/npm | I let each repo's `package.json` `packageManager` field pin the package manager version. |
| Python | `uv` | Owns the interpreter, venvs, packages, and CLI tools — `uv tool install` replaces pipx for me. |
| Go | `mise` | |
| Rust | `rustup` | Per-project pinning via `rust-toolchain.toml`. |
| Lua | none | I use the LuaJIT bundled with Neovim and install the dev tools (stylua, selene, lua-language-server) through mise. |

## Containers

I run **podman** everywhere — `podman compose` for compose files. I alias `docker` → `podman` in fish so the muscle memory still works, and on macOS the bootstrap does the one-time `podman machine init && podman machine start` for me.

## Terminal sessions (Zellij)

I moved to [Zellij](https://zellij.dev) (Layer 2 / mise) after one too many reboots wiped out all my open terminals. It's configured for **session resurrection** so that stops happening:

- `config.kdl` is a *minimal override*, not a `clear-defaults` dump — I want upstream's default improvements to keep reaching me on upgrade.
- `session_serialization` + `serialize_pane_viewport` persist each session's tabs, panes, cwds, running commands, and on-screen scrollback. After a reboot, `zellij ls` shows the session as `EXITED`; I resurrect it from the session manager (`Ctrl+o` then `w`) and it rebuilds the layout and re-runs each pane's command.
- fish auto-attaches to a persistent `main` session on interactive shells — guarded so it never nests inside Zellij, an IDE terminal (VS Code/Cursor, JetBrains), or a non-interactive shell. Opt out for a shell with `set -gx ZELLIJ_NO_AUTOSTART 1`.
- `layouts/claude.kdl` (`zellij --layout claude`) opens a Claude Code pane via `claude --continue`, so a resurrected session drops me back into the prior conversation, plus `edit` (nvim) and `shell` tabs.
- **Neovim ⇄ Zellij navigation:** `Ctrl+h/j/k/l` moves across both Neovim splits and Zellij panes, via [vim-zellij-navigator](https://github.com/hiasr/vim-zellij-navigator) on the Zellij side and [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) on the Neovim side.

> **A privacy trade-off I made consciously:** `serialize_pane_viewport true` writes terminal *contents* to the local cache dir (`~/.cache/zellij` on Linux, `~/Library/Caches/org.Zellij-Contributors.Zellij` on macOS). It's local-only — never synced, never in this repo — but it's plaintext on disk, so I cap how much with `scrollback_lines_to_serialize`.

## What's in this repo

```
.
├── README.md                                  this file
├── CLAUDE.md                                  notes for Claude Code working in this repo
├── .chezmoiignore                             per-OS + secret file exclusions (templated)
├── .github/workflows/gitleaks.yml             CI secret scan
├── Brewfile.darwin.tmpl                        macOS Homebrew formulas + casks
├── packages/
│   ├── arch.txt                               pacman package list
│   ├── debian.txt                             apt package list (Pop!_OS, Ubuntu)
│   └── fedora.txt                             dnf package list
├── dot_config/                                → ~/.config/
│   ├── fish/                                  fish shell (config.fish + conf.d/)
│   ├── ghostty/                               terminal emulator config
│   ├── git/
│   │   ├── config.tmpl                        git config (per-machine email/signing + work includeIf)
│   │   ├── hooks/                             global gitleaks pre-commit hook
│   │   └── ignore                             global gitignore
│   ├── mise/config.toml.tmpl                  mise tools manifest
│   ├── nvim/                                  Neovim (LazyVim)
│   ├── starship/starship.toml                 prompt config
│   └── zellij/                                multiplexer (config.kdl + layouts/)
├── run_once_before_10-install-package-managers.sh.tmpl
├── run_once_before_20-install-self-managers.sh.tmpl
├── run_onchange_30-mise-install.sh.tmpl
└── run_once_after_40-macos-defaults.sh.tmpl   (mac-only)
```

## Which machines this runs on

| OS | Package manager | How much I trust it |
|---|---|---|
| macOS (Apple Silicon, work-issued) | Homebrew | My daily driver — most exercised. |
| Pop!_OS (personal ThinkPad) | apt | My personal machine. |
| Omarchy / Arch | pacman | I run it occasionally; config is OS-correct but less battle-tested. |
| Fedora | dnf | Same — supported, lightly used. |

I keep per-OS divergence small on purpose. The few differences are handled with chezmoi templates (`{{ if eq .chezmoi.os "darwin" }}`) and `.chezmoiignore` rules; the vast majority of the config and tooling is identical across all four.

## Secrets

This repo is **public**, so nothing secret lives in it — no keys, tokens, or credentials. SSH keys, AWS configs, GnuPG keyrings, and 1Password vaults all live out-of-band. The per-machine bits that vary (signing-key path, personal vs. work email) come from values I'm prompted for at `chezmoi init`, stored in `~/.config/chezmoi/chezmoi.toml`, which is never committed.

My git identity is split by directory: commits default to my personal email, and an `includeIf "gitdir:…"` switches to my work email for repos under my work directory. One SSH signing key covers both, since GitHub verifies the signature against my account, not the commit email.

On personal Linux machines I use `1password-cli` as the secrets source. On the work-issued mac I manage secrets by hand, kept strictly separate from my personal accounts.

### Keeping secrets out (defense in depth)

I don't fully trust myself not to fat-finger a token into a commit, so there are four independent guards:

1. **Architecture** — per-machine secrets live outside the repo (above), and secret-bearing paths (`.ssh`, `.aws`, `.config/gh/hosts.yml`, `.netrc`, `.npmrc`, `.config/atuin`, `**/.env`, `**/*.key`, …) are in `.chezmoiignore` so `chezmoi add` refuses them.
2. **Pre-commit hook** — a global [gitleaks](https://github.com/gitleaks/gitleaks) hook (`dot_config/git/hooks/`, wired via `core.hooksPath`) scans staged changes on every commit, in every repo. gitleaks is itself a Layer-2 tool. Repos with their own `core.hooksPath` (Husky/lefthook) override it and are unaffected.
3. **GitHub push protection** — secret scanning + push protection are enabled on this repo (free for public repos). The server-side backstop if a local hook is ever skipped.
4. **CI** — `.github/workflows/gitleaks.yml` scans the full history on every push and PR.

If I ever bypass the hook with `git commit --no-verify`, that's on me — push protection is the last line. **If you fork this, enable push protection on your fork too.**

## How I update

```sh
chezmoi update                        # pull + apply latest dotfiles

mise self-update                      # self-managing tools
uv self update
rustup update
claude update
codex update

mise upgrade                          # mise-managed tools

brew upgrade                          # OS-native packages, per machine
sudo apt update && sudo apt upgrade
sudo pacman -Syu
sudo dnf upgrade
```

## If you want to fork this

It's MIT-licensed — go for it. A few starting points:

- Tool list lives in `dot_config/mise/config.toml.tmpl`.
- OS-native packages live in `Brewfile.darwin.tmpl` and `packages/*.txt`.
- The three-layer model is the part worth stealing; the specific tools are just mine.
- Enable push protection on your fork, and keep the gitleaks hook — a public dotfiles repo is an easy place to leak something.

## Credits

- chezmoi's [docs](https://www.chezmoi.io/quick-start/) and mise's [cookbook](https://mise.jdx.dev/configuration.html).
- The wider [dotfiles community](https://dotfiles.github.io/).

## License

MIT — see [`LICENSE`](LICENSE).
