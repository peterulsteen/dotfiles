# Shared POSIX environment for zsh AND bash.
#
# Sourced by ~/.zprofile (zsh login) and ~/.profile / ~/.bashrc (bash servers),
# so PATH and tool env are identical across shells and machines. Keep this file
# STRICTLY POSIX -- no zsh/fish-isms (no `typeset`, no arrays, no `fish_add_path`).

# Source-once guard (per shell process; not exported, so children re-derive).
[ -n "${__ENV_SH_DONE:-}" ] && return
__ENV_SH_DONE=1

# --- Homebrew (macOS or Linuxbrew). Sets HOMEBREW_PREFIX/MANPATH + brew bin. ---
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- PATH: ~/.local/bin > mise shims > cargo > everything else. ---
# Iterate lowest-priority first; each prepend pushes earlier entries ahead.
for _dir in "$HOME/.cargo/bin" "$HOME/.local/share/mise/shims" "$HOME/.local/bin"; do
  case ":$PATH:" in
    *":$_dir:"*) ;;                                  # already present
    *) [ -d "$_dir" ] && PATH="$_dir:$PATH" ;;
  esac
done
unset _dir
export PATH

# uv writes ~/.local/bin/env (POSIX) with its own PATH wiring.
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# LM Studio CLI (lms).
[ -d "$HOME/.lmstudio/bin" ] && PATH="$PATH:$HOME/.lmstudio/bin" && export PATH

# pnpm global bin (different default path per OS; corepack honors PNPM_HOME).
if [ -z "${PNPM_HOME:-}" ]; then
  case "$(uname -s)" in
    Darwin) PNPM_HOME="$HOME/Library/pnpm" ;;
    *)      PNPM_HOME="$HOME/.local/share/pnpm" ;;
  esac
fi
export PNPM_HOME
if [ -d "$PNPM_HOME" ]; then
  case ":$PATH:" in *":$PNPM_HOME:"*) ;; *) PATH="$PNPM_HOME:$PATH"; export PATH ;; esac
fi

# --- 1Password SSH agent.
# Prefer the 1Password agent over the GNOME keyring agent so that git commit
# signing (via ssh-keygen -> SSH agent) can trigger the system-auth unlock
# dialog when the app is locked, rather than failing silently.
# Guarded: only override if the socket actually exists (1Password installed).
[ -S "$HOME/.1password/agent.sock" ] && SSH_AUTH_SOCK="$HOME/.1password/agent.sock" && export SSH_AUTH_SOCK

# --- Google Cloud CLI ---
# CLOUDSDK_* env OVERRIDES ~/.config/gcloud, so config lives here as code (that
# dir holds credentials and is .chezmoiignore'd). Opt out of usage reporting
# (also suppresses the first-run prompt).
export CLOUDSDK_CORE_DISABLE_USAGE_REPORTING=true
# macOS cask puts core binaries on PATH, but `gcloud components install` extras
# (e.g. gke-gcloud-auth-plugin) land in the SDK's own bin. Add when present;
# no-op on Linux (there components ship as separate OS packages).
[ -d /opt/homebrew/share/google-cloud-sdk/bin ] && \
  PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH" && export PATH

# --- Rootless Podman socket (Pop!_OS / Linux) ---
# Point Docker-expecting tools (Testcontainers, kind) at the rootless podman
# socket without running as root. Guarded on the socket, so it's a no-op on
# macOS (podman machine uses a different socket) and on boxes without podman.
if [ -S "${XDG_RUNTIME_DIR:-}/podman/podman.sock" ]; then
  export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
  export KIND_EXPERIMENTAL_PROVIDER=podman
fi

# --- Editor + tooling env ---
export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME="TwoDark"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
