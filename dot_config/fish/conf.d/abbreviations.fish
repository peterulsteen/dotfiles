# Abbreviations expand inline at the prompt (you see the real command before Enter).
# Preferred over aliases because they're transparent — good for pairing, recordings,
# and for muscle-memory learning.

# --- Listings ---
abbr --add ll  'eza -lah --icons --git --group-directories-first'
abbr --add la  'eza -lah --icons --git'
abbr --add ltr 'eza --tree --icons --level 2'

# --- Cat / bat ---
abbr --add bcat 'bat --paging=never'

# --- Git ---
abbr --add gst 'git status'
abbr --add gd  'git diff'
abbr --add gds 'git diff --staged'
abbr --add gl  'git pull'
abbr --add gp  'git push'
abbr --add gco 'git checkout'
abbr --add gcm 'git commit -m'
abbr --add gca 'git commit --amend --no-edit'
abbr --add glo 'git log --oneline --graph --decorate'
abbr --add lg  'lazygit'

# --- Container engine ---
# Only shim docker -> podman when there's no real docker binary
# (Podman-only machines, e.g. personal Linux). On the work Mac,
# Dory provides a real `docker`, so leave it alone.
if not command -q docker
    abbr --add docker         'podman'
    abbr --add docker-compose 'podman compose'
end

# --- Mise ---
abbr --add mr  'mise run'
abbr --add mu  'mise upgrade'
abbr --add mls 'mise ls'

# --- AWS quirk: some hands type `aws2` from the v1/v2 transition era. ---
abbr --add aws2 'aws'
