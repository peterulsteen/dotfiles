# CLAUDE.md

Instructions for Claude Code (and other AI coding assistants) working in this dotfiles repo.

## What this repo is

A [chezmoi](https://www.chezmoi.io)-managed dotfiles repo for macOS + Linux (Pop!_OS, Arch/Omarchy, Fedora). The owner has two daily drivers (work mac, personal Linux ThinkPad) and bootstraps additional Linux installs occasionally.

Read `README.md` first for the public-facing overview, then this file for working conventions.

## The three-layer ownership model (load-bearing)

Every tool belongs to exactly **one** of three layers. This is the most important invariant in the repo:

1. **Self-managing** — `mise`, `uv`, `rustup`, `claude`, `codex`. Installed once via `curl ... | sh` in `run_once_before_20-install-self-managers.sh.tmpl`. Updated by themselves. Never put these in `mise.toml` or any package list.
2. **Mise** — language runtimes + cross-platform CLIs. Source of truth: `dot_config/mise/config.toml.tmpl`. Same content on every OS.
3. **Native pkg mgr** — `brew` (macOS), `apt`/`pacman`/`dnf` (Linux). Only for tools needing OS integration: login shells, terminal emulators, system crypto, daemons, fonts. Sources of truth: `Brewfile.darwin.tmpl` and `packages/{arch,debian,fedora}.txt`.

### When adding a new tool

Decision tree:
1. Does the tool have a curl-pipe installer with self-update? → **Layer 1.** Add to `run_once_before_20-install-self-managers.sh.tmpl`.
2. Does it need OS integration (login shell, terminal, daemon, font, GUI app)? → **Layer 3.** Add to `Brewfile.darwin.tmpl` AND each of `packages/{arch,debian,fedora}.txt` (using each pkg manager's name for the tool).
3. Otherwise (single-binary CLI, language runtime, dev utility) → **Layer 2.** Add to `dot_config/mise/config.toml.tmpl`.

If you're tempted to add the same tool to two places — stop. Pick one. PATH order in `dot_config/shell/env.sh` puts `~/.local/bin` first, then `~/.local/share/mise/shims/`, then OS pkg manager paths, but relying on this to mask duplicates causes drift.

## Per-language runtime rules (do not violate)

- **Python:** `uv` owns Python entirely. **Never** add `python` to `mise.toml`. Use `uv python install <version>`, `uv venv`, `uv run`, `uv tool install`. Pyenv, pipx, virtualenv, poetry are all out.
- **Rust:** `rustup` owns Rust entirely. **Never** add `rust` to `mise.toml`. Use `rustup install <channel>`, `rust-toolchain.toml` for per-project pinning.
- **Node:** `mise` installs Node. **`corepack` handles pnpm/yarn/npm**, reading the `packageManager` field from each repo's `package.json`. **Never** install pnpm globally via brew/apt/mise.
- **Go:** `mise` owns Go. Single version is fine; bump in `mise.toml` to upgrade.
- **Lua:** Use the LuaJIT shipped with Neovim. Install dev tools (`stylua`, `selene`, `lua-language-server`) via mise.

## Conventions

- **Templates** end in `.tmpl`. Use chezmoi template syntax (`{{ }}`) for per-OS branching: `{{ if eq .chezmoi.os "darwin" }}...{{ end }}`. Linux distros are detected via `{{ .chezmoi.osRelease.id }}` (`pop`, `ubuntu`, `arch`, `fedora`) and `.idLike`.
- **File naming** follows chezmoi's prefix conventions:
  - `dot_<name>` → `~/.<name>` (e.g., `dot_config/` → `~/.config/`)
  - `private_<name>` → file mode 0600
  - `executable_<name>` → file mode +x
  - `run_once_<name>.sh.tmpl` → script that runs once after `chezmoi apply`, in alphabetical order
  - `run_onchange_<name>.sh.tmpl` → script that re-runs whenever its rendered content changes
- **Bootstrap script ordering** is encoded in the numeric prefix:
  - `10-install-package-managers` — brew on mac, apt update on Linux, install Layer 3 packages
  - `20-install-self-managers` — install Layer 1 tools (mise, uv, rustup, claude, codex)
  - `30-mise-install` — `mise install` to materialize Layer 2 tools (re-runs when `mise.toml` changes)
  - `40-macos-defaults` — macOS system tweaks (skipped on Linux via .chezmoiignore)
- **Shell layout**: `dot_zprofile` (login env, sources `env.sh`) + `dot_zshrc` (interactive: sheldon plugins, guarded aliases, tool init) for zsh; `dot_bashrc`/`dot_profile` for lean servers. All environment + PATH lives in `dot_config/shell/env.sh` (strictly POSIX, sourced by both zsh and bash). Abbreviations are code in `dot_config/zsh-abbr/user-abbreviations`; plugins are declared in `dot_config/sheldon/plugins.toml`.
- **Don't sync sensitive dirs** — `~/.aws/`, `~/.docker/`, `~/.ssh/`, `~/.gnupg/`, `~/.codex/`, `~/.cursor/`, `~/.copilot/`, `~/.cagent/`, `~/.claude.json`. These are listed in `.chezmoiignore` and must stay there.
- **`.chezmoiignore` matches TARGET paths**, not source paths. Use `.config/foo`, never `dot_config/foo`; strip the `.tmpl` suffix (`Brewfile.darwin`, not `Brewfile.darwin.tmpl`). A source-style pattern silently matches nothing — dangerous for a secret ignore list. Verify with `chezmoi managed`.
- **Secret-scanning is defense-in-depth** (this repo is public): `.chezmoiignore` blocks `chezmoi add` of secret-bearing files; a global gitleaks pre-commit hook (`dot_config/git/hooks/executable_pre-commit`, wired via `core.hooksPath`) blocks commits; `.github/workflows/gitleaks.yml` scans history in CI; GitHub push protection is the server-side backstop. gitleaks is a Layer-2 (mise) tool; v8.30+ dropped `protect`/`detect` — use `gitleaks git --staged`. Never weaken these guards to make a commit pass; fix the secret or use an explicit allowlist.
- **Commit `lazy-lock.json`** for Neovim — gives reproducible plugin versions across machines. Update with `:Lazy update` deliberately.
- **Zellij config is a minimal override**, not a `clear-defaults=true` dump. Only put lines you actually want to change in `dot_config/zellij/config.kdl` so upstream default keybinds/plugins keep flowing through on upgrade. Validate edits with `zellij --config dot_config/zellij/config.kdl setup --check`. Zellij plugins (e.g. vim-zellij-navigator) are referenced by release URL in the config and fetched/cached at runtime — there is nothing to add to mise/brew for them. The Neovim half of `Ctrl+h/j/k/l` navigation is `smart-splits.nvim`; its maps live in `dot_config/nvim/lua/config/keymaps.lua` (not the plugin spec) so they override LazyVim's defaults. Zellij's serialized sessions live in the cache dir, never `~/.config/zellij/`, so they're out of chezmoi's scope by construction.

## Common workflows

### Adding a new CLI tool you want everywhere
1. Determine its layer (decision tree above).
2. If Layer 2: add to `dot_config/mise/config.toml.tmpl` under `[tools]`. Run `chezmoi apply` then `mise install`.
3. If Layer 3: add to `Brewfile.darwin.tmpl` *and* each Linux distro file in `packages/`.

### Changing a config file
1. Edit the file in this repo (e.g., `dot_zshrc` or `dot_config/shell/env.sh`).
2. `chezmoi apply` on each machine to push the change to `~/`.
3. `git commit` and push.

### Adding a per-machine value (e.g., a different git email)
1. Convert the file to `.tmpl`.
2. Use chezmoi template syntax referencing `.chezmoi.username`, `.chezmoi.hostname`, or a prompted value defined in `.chezmoidata.yaml` / `chezmoi.toml`.
3. The work-vs-personal distinction is generally derivable from hostname; avoid hardcoding.

## DOs and DON'Ts (quick reference)

**DO:**
- Keep `README.md` user-facing and up to date when adding tools or changing the architecture
- Use `mise` shims as the canonical PATH-resolution mechanism for Layer 2 tools
- Test changes on at least two OSs before committing whenever practical
- Treat the public nature of this repo as a constraint: no secrets, no work-specific identifiers

**DON'T:**
- Don't add `python` or `rust` to `mise.toml` (uv and rustup own them)
- Don't add Layer-1 self-managers (`claude`, `codex`, `uv`, `mise`, `rustup`) to any package list
- Don't sync any credential file (`lazy-lock.json` is a deliberate exception — see above)
- Don't put Linuxbrew anywhere — Linux uses native package managers, not Homebrew
- Don't suggest Nix, ansible, or shell-rc-frameworks (oh-my-zsh, prezto, zinit). The owner has chosen this stack deliberately (zsh + sheldon, minimal) to avoid those layers of abstraction.

## Repo layout reminder

```
~/code/peterulsteen/dotfiles/     ← the chezmoi source dir, also the git repo root
└── (managed by chezmoi)          ← chezmoi reads from here, applies to ~/
~/.local/share/chezmoi/           ← chezmoi's default working dir if you let it clone itself
```

On the current machine the working tree lives at `~/code/peterulsteen/dotfiles/`. Point chezmoi at it by setting `sourceDir` in `~/.config/chezmoi/chezmoi.toml`, or let `chezmoi init <gh-user>/dotfiles` clone into the default `~/.local/share/chezmoi/`. New machines just run the latter.
