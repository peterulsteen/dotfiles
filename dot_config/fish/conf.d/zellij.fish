# Auto-attach to a persistent Zellij session on interactive shells, so a fresh
# terminal (or a reboot) drops you back into your running workspace instead of a
# bare prompt. Attach-or-create a single session named "main".
#
# Guarded so it NEVER nests or hijacks where it shouldn't:
#   - $ZELLIJ set                  -> already inside Zellij (no nesting)
#   - TERM_PROGRAM = vscode        -> VS Code / Cursor integrated terminal
#   - $INTELLIJ_ENVIRONMENT_READER -> JetBrains terminal
#   - non-interactive shells       -> Claude Code's Bash tool, scripts, `ssh host cmd`
#   - $ZELLIJ_NO_AUTOSTART set     -> manual opt-out for a given shell/session
if status is-interactive
    and not set -q ZELLIJ
    and not set -q ZELLIJ_NO_AUTOSTART
    and not set -q INTELLIJ_ENVIRONMENT_READER
    and test "$TERM_PROGRAM" != vscode
    zellij attach --create main
end
