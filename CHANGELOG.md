# Changelog

## 0.43.0-railway.1 (2026-11-16)

- First release of the Railway template: Docspell 0.43.0 (`ghcr.io/docspell/restserver:v0.43.0@sha256:bc8f0c0e…`, `ghcr.io/docspell/joex:v0.43.0@sha256:19c8daf2…`) with Railway PostgreSQL.
- Full-text search in PostgreSQL (no Solr), invite-only sign-up, addons off, IPv4 and IPv6 binding for Railway's private network.
- The start scripts fill in the internal node URLs from the service name when Railway's private domain isn't rendered, so the REST server and joex always find each other.
- The REST server uses one Docspell node id per Railway deployment, so a redeploy no longer removes the new instance's pub/sub registration. joex checks for new jobs every minute as a fallback, and runs without a Railway health check so old and new joex don't overlap.
