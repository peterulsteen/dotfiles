# Google Cloud CLI — declarative, secret-safe config.
#
# The native package (brew cask / apt / dnf / pacman) already puts the core
# gcloud/gsutil/bq binaries on PATH. Google ships no official fish completions,
# so there's nothing to source either.
#
# CLOUDSDK_* env vars OVERRIDE ~/.config/gcloud — which is why gcloud settings are
# managed here as code rather than by syncing that directory. ~/.config/gcloud
# holds credentials (auth tokens, ADC) and is intentionally .chezmoiignore'd;
# active account/project selection lives there and stays machine-local.

# Opt out of anonymous usage reporting (also suppresses the first-run prompt).
set -gx CLOUDSDK_CORE_DISABLE_USAGE_REPORTING true

# The macOS cask symlinks core binaries into the brew prefix, but extra
# components (`gcloud components install …`, e.g. gke-gcloud-auth-plugin) land in
# the SDK's own bin dir, which is not on PATH. Add it when present. Guarded, so
# it's a no-op on Linux (there components ship as separate OS packages).
if test -d /opt/homebrew/share/google-cloud-sdk/bin
    fish_add_path /opt/homebrew/share/google-cloud-sdk/bin
end
