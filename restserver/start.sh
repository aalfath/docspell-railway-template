#!/bin/sh
# Railway wrapper for the Docspell REST server. Fixed settings live here, so
# the template only carries references, secrets and PORT.
set -e

# Listen on Railway's PORT, on all IPv4 and IPv6 interfaces (Railway's private
# network is IPv6).
export DOCSPELL_SERVER_BIND_ADDRESS="${DOCSPELL_SERVER_BIND_ADDRESS:-::}"
export DOCSPELL_SERVER_BIND_PORT="${PORT:-7880}"

# Full-text search in PostgreSQL (no Solr service needed).
export DOCSPELL_SERVER_FULL__TEXT__SEARCH_ENABLED="${DOCSPELL_SERVER_FULL__TEXT__SEARCH_ENABLED:-true}"
export DOCSPELL_SERVER_FULL__TEXT__SEARCH_BACKEND="${DOCSPELL_SERVER_FULL__TEXT__SEARCH_BACKEND:-postgresql}"
export DOCSPELL_SERVER_FULL__TEXT__SEARCH_POSTGRESQL_USE__DEFAULT__CONNECTION="${DOCSPELL_SERVER_FULL__TEXT__SEARCH_POSTGRESQL_USE__DEFAULT__CONNECTION:-true}"

# Sign-up is invite-only by default: create an invitation key at
# /app/newinvite with DOCSPELL_SERVER_BACKEND_SIGNUP_NEW__INVITE__PASSWORD.
export DOCSPELL_SERVER_BACKEND_SIGNUP_MODE="${DOCSPELL_SERVER_BACKEND_SIGNUP_MODE:-invite}"

# Addons need Docker or Nix inside the container, which Railway doesn't offer.
export DOCSPELL_SERVER_BACKEND_ADDONS_ENABLED="${DOCSPELL_SERVER_BACKEND_ADDONS_ENABLED:-false}"

# Other Docspell nodes reach this one at this URL. If Railway's private domain
# wasn't rendered (empty host), fall back to <service>.railway.internal.
case "${DOCSPELL_SERVER_INTERNAL__URL:-}" in
  ""|*"://:"*)
    _host="${RAILWAY_PRIVATE_DOMAIN:-}"
    if [ -z "$_host" ] && [ -n "${RAILWAY_SERVICE_NAME:-}" ]; then
      _host="$(echo "$RAILWAY_SERVICE_NAME" | tr '[:upper:]' '[:lower:]').railway.internal"
    fi
    if [ -n "$_host" ]; then
      export DOCSPELL_SERVER_INTERNAL__URL="http://$_host:${PORT:-7880}"
      echo "railway-start: DOCSPELL_SERVER_INTERNAL__URL set to $DOCSPELL_SERVER_INTERNAL__URL"
    fi
    ;;
esac

# Docspell removes a node's pub/sub registration when that node shuts down.
# Railway starts the new deployment before it stops the old one, so with a
# fixed id the old instance would delete the new one's registration. Use one
# id per deployment instead.
if [ -z "${DOCSPELL_SERVER_APP__ID:-}" ] && [ -n "${RAILWAY_DEPLOYMENT_ID:-}" ]; then
  export DOCSPELL_SERVER_APP__ID="rest-$(echo "$RAILWAY_DEPLOYMENT_ID" | cut -c1-8)"
fi

export TZ="${TZ:-UTC}"

exec /opt/docspell-restserver/bin/docspell-restserver "$@"
