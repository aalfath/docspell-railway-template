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

export TZ="${TZ:-UTC}"

exec /opt/docspell-restserver/bin/docspell-restserver "$@"
