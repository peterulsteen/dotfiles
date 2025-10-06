# 🧰 Peter’s Cross-Platform Dev Toolbelt

A reproducible, cross-platform CLI toolbelt built with **Nix flakes**, designed to keep your command-line stack identical on **Linux** and **macOS**.

This flake bundles common developer tools — shells, editors, multiplexers, fuzzy-finders, git TUIs, and system utilities — all version-pinned via `nixpkgs-unstable`.

---

## ✨ Features

* **Cross-platform:** works on both macOS and Linux
* **Reproducible:** every package version pinned via flake inputs
* **Self-contained:** install everything with one command
* **Minimal yak-shaving:** no Home-Manager or NixOS required

---

## 🧱 Included Tools

### 🐊 Shell / Prompt

* `fish` — Friendly Interactive Shell
* `starship` — cross-shell prompt
* `zellij`, `tmux` — terminal multiplexers

### 🧭 Navigation & Search

* `fzf`, `fd`, `ripgrep`, `bat`, `eza`, `lazygit`, `zoxide`

### 🌐 Networking & System

* `curl`, `wget`, `socat`, `nmap`, `iftop`, `iotop`, `btop`, `fastfetch`

### ☁️ Cloud / Dev Utilities

* `awscli2`, `aws-vault`, `mise`, `duckdb`, `devbox`, `jq`, `yq-go`

### 🧹 Extras

* `tealdeer` (tldr client), `tree`, `xclip` (Linux only)

---

## 🚀 Quick Start

> Prerequisites: Nix 2.20+ (flakes enabled).
> If you installed via [Determinate Systems Nix installer](https://determinate.systems/posts/determinate-nix-installer/), you’re ready.

### 1. Clone and enter the repo

```bash
git clone https://github.com/peterulsteen/toolbelt.git
cd toolbelt
```

### 2. Install into your Nix profile

```bash
nix profile add path:$(pwd)#toolbelt
```

> Once pushed to GitHub, you can install directly from anywhere:
>
> ```bash
> nix profile add github:peterulsteen/toolbelt#toolbelt
> ```

### 3. Verify installation

```bash
nix profile list
which nvim fish lazygit
```

---

## Using the Toolbelt

All binaries are available in your Nix profile:

```
~/.nix-profile/bin
```

If you don’t see them, ensure your shell sources Nix paths:

**Fish**

```fish
if test -d $HOME/.nix-profile/bin
  fish_add_path $HOME/.nix-profile/bin
end
```

**Bash/Zsh**

```bash
export PATH="$HOME/.nix-profile/bin:$PATH"
```

---

## 🔄 Updating

To pull the latest nixpkgs/tools:

```bash
# Update flake inputs (refresh nixpkgs pin)
nix flake update

# Upgrade installed packages in your profile
nix profile upgrade --all
```

Then commit your new `flake.lock` to keep all machines in sync.

---

## 🧹 Maintenance

```bash
# Show installed items
nix profile list

# Remove one by index
nix profile remove <index>

# Roll back to previous generation
nix profile rollback

# Clean old generations and caches
nix profile wipe-history --older-than 30d
nix store gc
```

---

## 🥪 Run or Build Without Installing

```bash
# Run a package/app directly (ephemeral)
nix run .#nvim

# Build to ./result without adding to your profile
nix build .#toolbelt
```

---

## 💡 Tips

* Keep GUI apps (Ghostty, VS Code, etc.) installed via native package managers (`dnf`, `Flatpak`, `Homebrew`) for simplicity.
* Use this flake purely for CLI tools; it stays fast, portable, and conflict-free.
* On macOS, you can add the same bundle:

  ```bash
  nix profile add github:peterulsteen/toolbelt#toolbelt
  ```

---

## 📦 Adding New Tools

Edit `flake.nix` → add to the `common` list:

```nix
common = with pkgs; [
  fish starship neovim tmux zellij
  # Add here
  htop
];
```

Then:

```bash
nix flake update
nix profile upgrade --all
```

---

## 🧭 Reference Cheat Sheet

| Action              | Modern Command                                          |
| ------------------- | ------------------------------------------------------- |
| Install             | `nix profile add github:peterulsteen/toolbelt#toolbelt` |
| Upgrade all         | `nix profile upgrade --all`                             |
| List installed      | `nix profile list`                                      |
| Remove one          | `nix profile remove <index>`                            |
| Rollback            | `nix profile rollback`                                  |
| Garbage collect     | `nix store gc`                                          |
| Update flake inputs | `nix flake update`                                      |
| Run without install | `nix run .#nvim`                                        |

---

## 📚 License

MIT © [Peter Ulsteen](https://github.com/peterulsteen)

