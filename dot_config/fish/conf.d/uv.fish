# uv's installer writes ~/.local/bin/env.fish with PATH setup; source it if present.
if test -f "$HOME/.local/bin/env.fish"
    source "$HOME/.local/bin/env.fish"
end
