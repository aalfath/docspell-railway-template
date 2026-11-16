#!/bin/sh
# Railway wrapper for the Docspell job executor (joex). Fixed settings live
# here, so the template only carries references and PORT.
set -e

# Listen on Railway's PORT, on all IPv4 and IPv6 interfaces (Railway's private
# network is IPv6). The REST server reaches joex through DOCSPELL_JOEX_BASE__URL.
export DOCSPELL_JOEX_BIND_ADDRESS="${DOCSPELL_JOEX_BIND_ADDRESS:-::}"
export DOCSPELL_JOEX_BIND_PORT="${PORT:-7878}"

export DOCSPELL_JOEX_APP__ID="${DOCSPELL_JOEX_APP__ID:-joex1}"
export DOCSPELL_JOEX_SCHEDULER_NAME="${DOCSPELL_JOEX_SCHEDULER_NAME:-$DOCSPELL_JOEX_APP__ID}"
export DOCSPELL_JOEX_PERIODIC__SCHEDULER_NAME="${DOCSPELL_JOEX_PERIODIC__SCHEDULER_NAME:-$DOCSPELL_JOEX_APP__ID}"

# Full-text search in PostgreSQL (no Solr service needed).
export DOCSPELL_JOEX_FULL__TEXT__SEARCH_ENABLED="${DOCSPELL_JOEX_FULL__TEXT__SEARCH_ENABLED:-true}"
export DOCSPELL_JOEX_FULL__TEXT__SEARCH_BACKEND="${DOCSPELL_JOEX_FULL__TEXT__SEARCH_BACKEND:-postgresql}"
export DOCSPELL_JOEX_FULL__TEXT__SEARCH_POSTGRESQL_USE__DEFAULT__CONNECTION="${DOCSPELL_JOEX_FULL__TEXT__SEARCH_POSTGRESQL_USE__DEFAULT__CONNECTION:-true}"

export DOCSPELL_JOEX_CONVERT_HTML__CONVERTER="${DOCSPELL_JOEX_CONVERT_HTML__CONVERTER:-weasyprint}"
export DOCSPELL_JOEX_ADDONS_EXECUTOR__CONFIG_RUNNER="${DOCSPELL_JOEX_ADDONS_EXECUTOR__CONFIG_RUNNER:-trivial}"

# Other Docspell nodes reach this one at this URL. If Railway's private domain
# wasn't rendered (empty host), fall back to <service>.railway.internal.
case "${DOCSPELL_JOEX_BASE__URL:-}" in
  ""|*"://:"*)
    _host="${RAILWAY_PRIVATE_DOMAIN:-}"
    if [ -z "$_host" ] && [ -n "${RAILWAY_SERVICE_NAME:-}" ]; then
      _host="$(echo "$RAILWAY_SERVICE_NAME" | tr '[:upper:]' '[:lower:]').railway.internal"
    fi
    if [ -n "$_host" ]; then
      export DOCSPELL_JOEX_BASE__URL="http://$_host:${PORT:-7878}"
      echo "railway-start: DOCSPELL_JOEX_BASE__URL set to $DOCSPELL_JOEX_BASE__URL"
    fi
    ;;
esac

# Look for new jobs every minute even if a notification from the REST server
# was missed (Docspell's default is 30 minutes).
export DOCSPELL_JOEX_SCHEDULER_WAKEUP__PERIOD="${DOCSPELL_JOEX_SCHEDULER_WAKEUP__PERIOD:-1 minute}"

export TZ="${TZ:-UTC}"

exec /opt/joex-entrypoint.sh "$@"
