# Prefer the 1Password SSH agent over the platform default (GNOME keyring on
# Linux, launchd agent on macOS) so that git commit signing via ssh-keygen
# routes through 1Password and can trigger a polkit/system-auth unlock dialog
# when the app is locked -- rather than failing with "Could not connect."
# Guarded: no-op if 1Password isn't installed or not yet started this session.
if test -S "$HOME/.1password/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
end
