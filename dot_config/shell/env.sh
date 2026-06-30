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

# --- Editor + tooling env (mirrors the fish config). ---
export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME="TwoDark"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
