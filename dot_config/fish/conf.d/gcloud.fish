# Google Cloud CLI — declarative, secret-safe config.
#
# The native package (brew cask / apt / dnf / pacman) already puts gcloud, gsutil
# and bq on PATH, so nothing to add here. Google ships no official fish
# completions, so there's nothing to source either.
#
# CLOUDSDK_* env vars OVERRIDE ~/.config/gcloud — which is why gcloud settings are
# managed here as code rather than by syncing that directory. ~/.config/gcloud
# holds credentials (auth tokens, ADC) and is intentionally .chezmoiignore'd;
# active account/project selection lives there and stays machine-local.

# Opt out of anonymous usage reporting (also suppresses the first-run prompt).
set -gx CLOUDSDK_CORE_DISABLE_USAGE_REPORTING true
