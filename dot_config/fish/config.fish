# Always-on fish config. Per-tool init lives in conf.d/.
# Universal vars and abbreviations also live in conf.d/ — fish_variables is NOT synced.

set -g fish_greeting

# PATH order matters: ~/.local/bin (self-installers) > mise shims > cargo > system.
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/mise/shims
fish_add_path $HOME/.cargo/bin

# Default editor.
set -gx EDITOR nvim
set -gx VISUAL nvim

# Interactive-only initializations (slow at startup, only needed for shells you type into).
if status is-interactive
    starship init fish | source
    atuin init fish | source
    zoxide init fish | source
    direnv hook fish | source
end
