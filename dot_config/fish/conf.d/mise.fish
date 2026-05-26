# Activation gives per-directory auto-loading from .mise.toml / .tool-versions
# (slightly slower than pure shims, but more accurate).
if command -v mise >/dev/null 2>&1
    mise activate fish | source
end
